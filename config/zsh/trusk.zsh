# TODO Switch with yours
SED=gsed

function greset() {
  BRANCH="develop"
  if [ ! `git branch --list $BRANCH` ]; then
    BRANCH="master"
  fi

  git checkout $BRANCH && git fetch && git rebase origin/$BRANCH
}

function get-version() {
  if [ $# -eq 0 ]
    then base=.
    else base=$1
  fi
  cat ./$base/package.json | jq -r '.version'
}

function submodule_states() {
  git submodule foreach -q 'echo $(basename $(pwd))@$(git rev-parse --abbrev-ref HEAD)'
}

function reset_branches() {
  git fetch -q
  git checkout -q master && git rebase -q origin/master
  git checkout -q develop && git rebase -q origin/develop
}

LINEAR_ISSUES=/tmp/linear_issues #TODO

function _package_submodule() {
  # Automatic repo release and tag, respecting gitflow + trusk patterns.

  # Requires:
  # - cg (https://www.npmjs.com/package/corgit)
  # - gh (https://github.com/cli/cli)

  VER=`get-version`
  git add package* CHANGELOG.md
  git stash save -q "psub $VER"
  if [ ! `git branch --list release/$VER` ]; then
    git checkout -q -b release/$VER develop && \
    git stash pop -q && \
    git add package* CHANGELOG.md && \
    git commit -q -m "Feature(Version): bump to $VER" --no-verify >/dev/null
  else
    git stash drop -q && \
    git checkout release/$VER >/dev/null && \
    git rebase -q origin/develop >/dev/null 2>/dev/null
  fi
  git push --no-progress -q -u origin >/dev/null 2>/dev/null && gh pr create -a @me -B master -t $(git rev-parse --abbrev-ref HEAD) -b '' --draft >/dev/null 2>/dev/null
  IMAGE=`basename $DIR`
  VERSION=`git rev-parse --abbrev-ref HEAD | $SED "s/[^a-z0-9_]/-/ig"`
  (
    cd .. && \
    $SED -i -E "s/$IMAGE(.*):develop/$IMAGE\1:$VERSION/g" docker-compose.fr.staging.yml && \
    git add $IMAGE docker-compose.*
  )
  gh pr list --state merged --json url -q '.[].url' | xargs linear_move "Acceptance Test" "Release Candidate"
}

function package_submodule() {
  reset_branches && touch CHANGELOG.md && cg bump >/dev/null && _package_submodule
}

function make_release() {
  # Automatic release_candidate creation
  # Only-run while being in a monorepo (not a submodule)

  # Optional command (Will prevent husky warnings):
  # git submodule -q foreach 'npm install --silent && git restore -q package-lock.json'
  setopt LOCAL_OPTIONS NO_NOTIFY

  if [[ $(git rev-parse --abbrev-ref HEAD) != *"release"* ]]; then
    reset_branches
    CURRENT_VER=$(git describe --tags --abbrev=0)
    read "VER?New version for $(basename $(pwd)) (current: $CURRENT_VER) ? "
    git checkout -b release/$VER
    npm version -no-git-tag-version $VER >/dev/null
    git add package*
    git commit -m "Feature(Version): bump version to $VER" --no-verify
  else
    VER=$(git rev-parse --abbrev-ref HEAD | cut -d '/' -f2)
  fi

  LINEAR_ISSUES=$(mktemp)
  echo "Linear moved issue:" > $LINEAR_ISSUES

  for DIR in $(git submodule -q foreach -q sh -c pwd); do
  (
    cd $DIR
    git checkout -q develop 2>/dev/null
    git fetch -q
    if ! git rebase -q origin/develop 2>/dev/null; then
      echo "$(basename $DIR) - ERROR: no action done (Local changes ?)"
    elif ! git show -q --summary HEAD | grep -q ^Merge; then
      touch CHANGELOG.md
      if ! cg bump >/dev/null; then
        echo "$(basename $DIR) - ERROR: no action done (Local changes ?)"
      else
        VER=`get-version`
        echo "`basename $DIR`:"
        gh pr list --state merged --json url -q '.[].url' | xargs linear_list "Acceptance Test" "Release Candidate"
        read -q "REPLY?Bump to $VER? (Y/y) "
        echo ""

        if [[ "$REPLY" = "Y" ]] || [[ "$REPLY" = "y" ]]; then
          _package_submodule >> $LINEAR_ISSUES
          exit
        else
          git restore .
        fi
      fi
    fi
    # Else, apply production version
    IMAGE=`echo $DIR | rev | cut -d "/" -f 1 | rev`
    VERSION=`cat ../docker-compose.fr.production.yml | grep "/.*$IMAGE.*:" | cut -d: -f3 | head -n 1`
    echo $IMAGE:$VERSION
    $SED -i -E "s/$IMAGE(.*):develop/$IMAGE\1:$VERSION/g" ../docker-compose.fr.staging.yml
  )
  done

  git add docker-compose.*
  git commit -m "Feature(Submodule): make_release script" --no-verify

  git push --no-progress -q -u origin >/dev/null 2>/dev/null
  gh pr create -a @me -B master -t $(git rev-parse --abbrev-ref HEAD) -b '' --draft 2>/dev/null

  #submodule_states
  cat $LINEAR_ISSUES
  rm $LINEAR_ISSUES
}

function validate_release() {
  setopt LOCAL_OPTIONS NO_NOTIFY

  VER=$(git rev-parse --abbrev-ref HEAD | cut -d '/' -f2)
  if [[ -z "$VER" ]]; then
    echo "No pending release"
    return 1
  fi

  if [[ $(git tag | grep $VER) ]]; then
    echo "Tag $VER already exists"
    return 1
  fi

  if [[ -f "docker-compose.fr.staging.yml" ]]; then
    IMAGES=$(cat docker-compose.fr.staging.yml | grep release | $SED 's/^.*\/\(.*\):.*$/\1/g')
    echo $IMAGES | while read IMAGE; do
    (
      cd $IMAGE && \
      git fetch && \
      gb release >/dev/null && \
      validate_release && \
      reset_branches && \
      VER=`get-version` && \
      git checkout -q master && \
      $SED -i -E "s/$IMAGE(.*):[0-9]+(\.[0-9]+){2}/$IMAGE\1:$VER/g" ../docker-compose.fr.production.yml && \
      (cd .. && git add $IMAGE) || exit 1
    )
    done
    $SED -i -E "s/trusk-production\/(.*):..*/trusk-production\/\1:develop/g" docker-compose.fr.staging.yml && \
    git add $IMAGE docker-compose.* && \
    git commit -m "Feature(Submodule): validate_release script" --no-verify
  fi

  echo "Bumping $(basename $(pwd)) to $VER"
  #return 1 # uncomment for dry-run

  git checkout -q master && git rebase -q && \
  git merge -q --no-ff release/$VER -m "Feature(Version): merge branch 'release/$VER' into master" --no-verify && \
  git tag $VER && \
  git checkout -q develop && \
  git merge -q --no-ff $VER -m "Feature(Version): merge tag '$VER' into develop" --no-verify && \
  git branch -q -D release/$VER && \
  git push -q origin develop master --tags >/dev/null && \
  gh release create $VER --generate-notes && \
  gh pr list --state merged --json url -q '.[].url' | xargs linear_move "Release Candidate" "In production"
}

HUSKY=0
alias trusk-mongo='dc exec mongo-db mongo trusk'
alias trusk-redis='dc exec redis-server redis-cli'
alias trusk-pgres='dc exec postgres-db psql -U postgres'
alias start-staging='gcloud --project trusk-playground compute instances start'
