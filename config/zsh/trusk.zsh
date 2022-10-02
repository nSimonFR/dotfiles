# TODO Switch with yours
SED=gsed

function get-version() {
  if [ $# -eq 0 ]
    then base=.
    else base=$1
  fi
  cat ./$base/package.json | jq -r '.version'
}

function reset_branches() {
  git fetch -q && \
  git checkout -q master && git rebase -q origin/master && \
  git checkout -q develop && git rebase -q origin/develop
}

function validate_release() {
  if [[ $1 ]]; then
    VER=$1;
  elif [[ $(git rev-parse --abbrev-ref HEAD) == *"release"* ]]; then
    VER=$(git rev-parse --abbrev-ref HEAD | cut -d '/' -f2)
  else
    exit
  fi;

  git checkout -q master && git rebase -q && \
  git merge -q --no-ff release/$VER -m "Feature(Version): merge branch 'release/$VER' into master" --no-verify && \
  git tag $VER && \
  git checkout -q develop && \
  git merge -q --no-ff $VER -m "Feature(Version): merge tag '$VER' into develop" --no-verify && \
  git branch -q -D release/$VER && \
  git push -q origin develop master --tags && \
  gh release create $VER --generate-notes
}

function msub() {
  # Automatic repo release and tag, respecting gitflow + trusk patterns.

  # Requires:
  # - cg (https://www.npmjs.com/package/corgit)
  # - gh (https://github.com/cli/cli)
  reset_branches && \
  touch CHANGELOG.md && \
  cg bump >/dev/null 2>/dev/null && \
  VER=`get-version` && \
  git add package.json package-lock.json CHANGELOG.md && \
  git stash save -q "msub $VER" && \
  git checkout -q -b release/$VER develop && \
  git stash pop -q && \
  git add package.json package-lock.json CHANGELOG.md && \
  git commit -q -m "Feature(Version): bump" --no-verify && \
  validate_release $VER
}

function update_parent_compose() {
  IMAGE=$1 && VERSION=$2 && \
  # $SED -i -E "s/$IMAGE(.*):[0-9]+(\.[0-9]+){2}/$IMAGE\1:$VERSION/g" ../docker-compose.fr.staging.yml && \
  $SED -i -E "s/$IMAGE(.*):[0-9]+(\.[0-9]+){2}/$IMAGE\1:$VERSION/g" ../docker-compose.fr.production.yml && \
  (cd .. && git add $IMAGE docker-compose.* && git commit -m "Feature(Submodule): bump $IMAGE@$VERSION" --no-verify)
}

function minfra() {
  # Push repo tagged image to parent repo docker-compose (Helps for RC)
  IMAGE=`pwd | rev | cut -d "/" -f 1 | rev` && \
  reset_branches && \
  git checkout -q master && \
  VERSION=`get-version` && \
  update_parent_compose $IMAGE $VERSION
}

function minfra_tmp() {
  # Push repo current image to parent repo docker-compose (Helps for TMP Branch)
  IMAGE=`pwd | rev | cut -d "/" -f 1 | rev` && \
  VERSION=`git -q rev-parse --abbrev-ref HEAD | sed "s/[^a-z0-9_]/-/ig"` && \
  update_parent_compose $IMAGE $VERSION
}

function release_candidate() {
  # Automatic release_candidate creation
  # Only-run while being in a monorepo (not a submodule)

  # Optional command (Will prevent husky warnings):
  # git submodule -q foreach 'npm install --silent && git restore -q package-lock.json'

  IFS=$'\n'
  TMPFILE=/tmp/release.tmp
  echo -n "" > $TMPFILE

  if [[ $(git rev-parse --abbrev-ref HEAD) != *"release"* ]]; then
    reset_branches && \
    CURRENT_VER=$(git describe --tags --abbrev=0) && \
    read -p "New version for $(basename $(pwd)) (current: $CURRENT_VER) ? " NEW_VER && \
    git checkout -b release/$NEW_VER && \
    npm version -no-git-tag-version $(git rev-parse --abbrev-ref HEAD | cut -d '/' -f2) >/dev/null && \
    git add package.json package-lock.json && \
    git commit -m "Feature(Version): bump version to $(git rev-parse --abbrev-ref HEAD | cut -d '/' -f2)" --no-verify
  fi
  
  exit

  for DIR in $(git submodule -q foreach -q sh -c pwd); do
      cd $DIR && \
      git checkout -q develop 2>/dev/null && git fetch -q && git rebase -q origin/develop 2>/dev/null && \
      (git show -q --summary HEAD | grep -q ^Merge || (msub && echo $DIR >> $TMPFILE)) \
      || echo "error on $(basename $DIR) - no action done (Possible local changes)" &
  done
  wait

  cat $TMPFILE | while read BUMP; do
    cd $BUMP && minfra
  done

  rm $TMPFILE

  git push
  gh pr create -a @me -t $(git rev-parse --abbrev-ref HEAD) -b '' --draft
}