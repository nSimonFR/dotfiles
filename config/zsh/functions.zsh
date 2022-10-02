#region git aliases
g() {
  if [ $# -eq 0 ];then
    git status
  else
    git $*
  fi
}
compdef g='git'

gb() {
  BRANCH=$(git branch -r | sed 's/.*origin\///' | grep $1 | head -1)
  git checkout ${BRANCH}
}
#endregion

#region gh tools
pr() {
  gh pr checkout $1
  gh pr view --web
}

issue() {
  IFS="#" read BRANCH ISSUE <<< $(git rev-parse --abbrev-ref HEAD)
  gh issue view --web $ISSUE
}

createpr() {
  IFS="#" read BRANCH ISSUE <<< $(git rev-parse --abbrev-ref HEAD)
  URL=$(gh pr create -t $BRANCH -b "Closes #$ISSUE" -a nSimonFR --draft)
  echo Opening $URL
  open $URL
}
#endregion

#region JWT
decode_base64_url() {
  local len=$((${#1} % 4))
  local result="$1"
  if [ $len -eq 2 ]; then result="$1"'=='
  elif [ $len -eq 3 ]; then result="$1"'='
  fi
  echo "$result" | tr '_-' '/+' | openssl enc -d -base64
}

decode_jwt(){
   decode_base64_url $(echo -n $2 | cut -d "." -f $1) | jq .
}
alias jwth="decode_jwt 1" # Decode JWT header
alias jwtp="decode_jwt 2" # Decode JWT Payload
#endregion

#region macOS
# Use TouchID for sudo on modern MacBook Pro machines
# This script adds a single line to the top of the PAM configuration for sudo
# See: https://apple.stackexchange.com/q/259093/41827 for more info.
touchid_sudo(){
  sudo bash -eu <<'EOF'
  file=/etc/pam.d/sudo
  # A backup file will be created with the pattern /etc/pam.d/.sudo.1
  # (where 1 is the number of backups, so that rerunning this doesn't make you lose your original)
  bak=$(dirname $file)/.$(basename $file).$(echo $(ls $(dirname $file)/{,.}$(basename $file)* | wc -l))
  cp $file $bak
  awk -v is_done='pam_tid' -v rule='auth       sufficient     pam_tid.so' '
  {
    # $1 is the first field
    # !~ means "does not match pattern"
    if($1 !~ /^#.*/){
      line_number_not_counting_comments++
    }
    # $0 is the whole line
    if(line_number_not_counting_comments==1 && $0 !~ is_done){
      print rule
    }
    print
  }' > $file < $bak
EOF
}
#endregion

function stash() {
  git stash save
  sh $@
  git stash pop
}

#region file management
function extract {
  echo Extracting $1 ...
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1  ;;
      *.tar.gz)    tar xzf $1  ;;
      *.bz2)       bunzip2 $1  ;;
      *.rar)       unrar x $1    ;;
      *.gz)        gunzip $1   ;;
      *.tar)       tar xf $1   ;;
      *.tbz2)      tar xjf $1  ;;
      *.tgz)       tar xzf $1  ;;
      *.zip)       unzip $1   ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1  ;;
      *)        echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

function trash () {
  local path
  for path in "$@"; do
    # ignore any arguments
    if [[ "$path" = -* ]]; then :
    else
      local dst=${path##*/}
      # append the time if necessary
      while [ -e ~/.Trash/"$dst" ]; do
        dst="$dst "$(date +%H-%M-%S)
      done
      /bin/mv "$path" ~/.Trash/"$dst"
    fi
  done
}

function strip_diff_leading_symbols {
  local color_code_regex="(\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K])"

  # simplify the unified patch diff header
  sed -r "s/^($color_code_regex)diff --git .*$//g" | \
    sed -r "s/^($color_code_regex)index .*$/\n\1$(rule)/g" | \
    sed -r "s/^($color_code_regex)\+\+\+(.*)$/\1+++\5\n\1$(rule)\x1B\[m/g" |\

  # actually strips the leading symbols
  sed -r "s/^($color_code_regex)[\+\-]/\1 /g"
}

random_file() {
  find ${*:-.} -type f | shuf | head -n 1
}
#endregion

#region other tools
rule () {
  printf "%$(tput cols)s\n"|tr " " "─"
}

sup() {
  su -c "$*"
}

zcode() {
  (z $* && code .)
}

clip() {
  pbcopy
}
#endregion
