#!/bin/bash

for i in `env | sed 's/=.*//'` ; do
    if [ "$i" != "PATH" ] && [ "$i" != "dir" ]; then
        unset $i
    fi
done
source /etc/profile

git config user.email "autorelease@localhost"
git config user.name "AutoRelease User"

DEST="/"
BUILDDIR="build/bin"

function destination() {
    DEST="$1"
}

function buildOutput() {
    BUILDDIR="$1"
}

function log() {
    echo [AutoRelease] $@
}

function prepare(){
    true
}


function build() {
    make
}


function install() {
    cp -rf "$BUILDDIR/." "$DEST"
}

function postInstall() {
    true
}

function publish() {
    true
}

source $dir/build.release.bash
log Preparing...
prepare || exit 1
cd "$dir"
log Building...
build || exit 1
echo
log Publishing...
echo
publish || exit 1

REPO_DIR="$(cat "$dir/tmp.repodir")"
if [ -f "$REPO_DIR/autorelease.allow.install" ]; then
    echo "$DEST" > "$dir/tmp.dest"
    echo "$BUILDDIR" > "$dir/tmp.builddir"
    echo "$USER1" > "$dir/tmp.user1"
    echo "$USER2" > "$dir/tmp.user2"
    echo "$USER3" > "$dir/tmp.user3"
    echo "$USER4" > "$dir/tmp.user4"
    echo "$USER5" > "$dir/tmp.user5"
    echo "$(type install | tail -n +4 | head -n -1 | sed "s/^    //g")" > "$dir/tmp.installscript"
    echo "$(type postInstall | tail -n +4 | head -n -1 | sed "s/^    //g")" > "$dir/tmp.postinstallscript"
fi
