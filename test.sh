#!/bin/sh

CWD=$(cd $(dirname $0); pwd;)
TROOT="$CWD/_tests"
PATH=$CWD:$PATH

mkrepo() {(
  set -e -x
  local name="$1"
  test -d "$TD"
  D="$TD/$name"
  DB="$TD/$name.git"

  # Remote
  mkdir -p "$DB"
  cd -P "$DB"
  git init --bare

  # The repo
  mkdir -p "$D"
  cd -P "$D"
  git init
  (
  for l in `seq 0 1 3` ; do
    if test "$l" != "0" ; then
      mkdir "lvl$l"
      cd -P "lvl$l"
    fi
    for i in `seq 1 1 5` ; do
      echo "File$i of $name" >file${i}
      git add file${i}
    done
  done
  )
  git commit -m 'Initial commit'
  git remote add origin "$DB"
  git push origin master
  git branch --set-upstream-to=origin/master
)}


mkrepoS() {(
  set -e -x
  local base=$1
  local subm=$2
  local path=$3
  test -d "$TD"
  mkrepo "$subm"

  cd -P "$TD/$base"
  mkdir -p $(dirname "$path")
  git submodule add "$TD/$subm.git" "$path"
  git commit -m "Add submodule $subm"
)}

modify() {(
  set -e -x
  cd -P "$TD/$1"
  test -f "$2"
  echo "Modified" >> "$2"
)}

powercommit() {(
  set -e -x
  cd -P "$TD/$1"
  shift
  git powercommit "$@"
)}

test1() {(
  set -e -x
  export TD="$TROOT/test1"
  mkdir -p "$TD"
  mkrepo repo1
  mkrepoS repo1 sub1 modules/sub1
  mkrepoS repo1 sub2 modules/sub2

  modify repo1 'file1'
  modify repo1 'lvl1/file1'
  modify repo1 'lvl1/lvl2/file1'
  modify repo1 'lvl1/lvl2/file2'
  modify repo1 'lvl1/lvl2/lvl3/file1'
  modify repo1 'lvl1/lvl2/lvl3/file2'
  modify repo1 'lvl1/lvl2/lvl3/file3'

  cd -P "$TD/repo1"
  powercommit repo1
  git status --porcelain
  git log --oneline | grep 'Update lvl1$'
  git log --oneline | grep 'Update lvl1/lvl2$'
  git log --oneline | grep 'Update lvl1/lvl2/lvl3$'
)}

test2() {(
  set -e -x
  export TD="$TROOT/test2"
  mkdir -p "$TD"
  mkrepo repo1
  mkrepoS repo1 sub1 modules/sub1
  mkrepoS repo1 sub2 modules/sub2

  modify repo1 'lvl1/file1'
  modify repo1 'modules/sub1/lvl1/file1'
  modify repo1 'modules/sub2/lvl1/file1'

  cd -P "$TD/repo1"
  powercommit repo1
  git status --porcelain
  git log --oneline | grep 'Bump'
)}

set -e -x
rm -rf "$TROOT" || true

test1
test2
echo OK
