# TODO Switch with yours
SED=gsed

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
    VERSIONS=$(cat docker-compose.fr.staging.yml | grep release | $SED 's/^.*\/\(.*\):\(.*\)$/\1 \2/g')
    echo $VERSIONS | while read line; do
    (
      submodule=$(echo $line | cut -d' ' -f1 | $SED 's/-2//' ) && \
      version=$(echo $line | cut -d' ' -f2 | $SED 's/-.*//') && \
      cd $submodule && \
      git fetch && \
      gb $version >/dev/null && \
      validate_release && \
      minfra
    )
    done
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
  gh pr list --state merged --json url -q '.[].url' | xargs linear_move "Release Candidate" "In Production"
}

function msub() {
  # Automatic repo release and tag, respecting gitflow + trusk patterns.

  # Requires:
  # - cg (https://www.npmjs.com/package/corgit)
  # - gh (https://github.com/cli/cli)

  reset_branches && \
  touch CHANGELOG.md && \
  cg bump >/dev/null && \
  VER=`get-version` && \
  git add package* CHANGELOG.md && \
  git stash save -q "msub $VER" && \
  git checkout -q -b release/$VER develop && \
  git stash pop -q && \
  git add package* CHANGELOG.md && \
  git commit -q -m "Feature(Version): bump to $VER" --no-verify && \
  git push --no-progress -q -u origin >/dev/null 2>/dev/null && \
  gh pr create -a @me -B master -t$(git rev-parse --abbrev-ref HEAD) -b '' --draft 2>/dev/null && \
  gh pr list --state merged --json url -q '.[].url' | xargs linear_move "Acceptance Test" "Release Candidate"
}

function minfra() {
  # Push repo tagged image to parent repo docker-compose (Helps for RC)
  IMAGE=`pwd | rev | cut -d "/" -f 1 | rev`
  reset_branches
  git checkout -q master
  VERSION=`get-version`
  $SED -i -E "s/$IMAGE(.*):..*/$IMAGE\1:develop/g" ../docker-compose.fr.staging.yml
  $SED -i -E "s/$IMAGE(.*):[0-9]+(\.[0-9]+){2}/$IMAGE\1:$VERSION/g" ../docker-compose.fr.production.yml
  (cd .. && git add $IMAGE docker-compose.* && git commit -m "Feature(Submodule): bump $IMAGE@$VERSION" --no-verify)
}

function minfra_tmp() {
  # Push repo current image to parent repo docker-compose (Helps for TMP Branch)
  IMAGE=`pwd | rev | cut -d "/" -f 1 | rev`
  VERSION=`git rev-parse --abbrev-ref HEAD | $SED "s/[^a-z0-9_]/-/ig"`
  update_parent_compose2 $IMAGE $VERSION
  $SED -i -E "s/$IMAGE(.*):develop/$IMAGE\1:$VERSION/g" ../docker-compose.fr.staging.yml
  #$SED -i -E "s/$IMAGE(.*):[0-9]+(\.[0-9]+){2}/$IMAGE\1:$VERSION/g" ../docker-compose.fr.production.yml
  (cd .. && git add $IMAGE docker-compose.* && git commit -m "TMP(Submodule): bump $IMAGE@$VERSION" --no-verify)
}

function release_candidate() {
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
    npm version -no-git-tag-version $(git rev-parse --abbrev-ref HEAD | cut -d '/' -f2) >/dev/null
    git add package*
    git commit -m "Feature(Version): bump version to $(git rev-parse --abbrev-ref HEAD | cut -d '/' -f2)" --no-verify
  else
    VER=$(git rev-parse --abbrev-ref HEAD | cut -d '/' -f2)
  fi

  TO_BUMP=$(mktemp)
  LINEAR_ISSUES=$(mktemp)
  echo "Linear issues:" > $LINEAR_ISSUES

  for DIR in $(git submodule -q foreach -q sh -c pwd); do
  (
    cd $DIR
    git checkout -q develop 2>/dev/null
    git fetch -q
    git rebase -q origin/develop 2>/dev/null
    git show -q --summary HEAD | grep -q ^Merge || \
    (
      msub >> $LINEAR_ISSUES && echo $DIR >> $TO_BUMP && \
    )
  ) || echo "error on $(basename $DIR) - no action done (Possible local changes)" &
  done
  wait

  while read BUMP; do
    (cd $BUMP && minfra_tmp)
  done < $TO_BUMP
  rm $TO_BUMP

  cat $LINEAR_ISSUES
  rm $LINEAR_ISSUES

  git push --no-progress -q -u origin >/dev/null 2>/dev/null
  gh pr create -a @me -t $(git rev-parse --abbrev-ref HEAD) -b '' --draft 2>/dev/null
}

alias trusk-mongo='dc exec mongo-db mongo trusk'
alias trusk-redis='dc exec redis-server redis-cli'
alias trusk-pgres='dc exec postgres-db psql -U postgres'
