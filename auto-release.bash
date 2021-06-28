#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

function errorExit() {
    rm -rf "$dir"
    echo
    log Script exited with non-zero exit code, cannot continue!
    echo
    exit 1
}

function log() {
    echo [AutoRelease] $@
}

commit="$(git log -1 --pretty=%B)"
if [[ "$commit" =~ "#Release" ]]; then
    echo
    echo [AutoRelease] Release tag detected!
    echo [AutoRelease] Checking author...
    echo [AutoRelease] Real author username : $REMOTE_USER
    echo [AutoRelease] Auther display name  : "$(git log -1 --pretty="%an")"
    echo [AutoRelease] Checking username...
    if [ ! -f "autorelease.users" ]; then
        echo
        echo [AutoRelease] Missing the autorelease.users file in the remote repository directory!
        echo [AutoRelease] Cannot release!
        echo
    else
        echo [AutoRelease] Reading file...
        found=false
        while read line; do
            if [ "$line" == "$REMOTE_USER" ] && [ ! "$line" == "" ] && [ ! "$line" =~ ^"#".*$ ]; then
                found=true
                break
            fi
        done < autorelease.users
        if [ "$found" == "false" ]; then
            echo 
            echo [AutoRelease] Sorry, i am not authorized to release in your name, please contact the system administrator
            echo
        else
            echo
            echo [AutoRelease] Authorization granted, preparing to build...
            echo [AutoRelease] Cloning git...
            dir="/tmp/$(date +%s-%N)"
            rm -rf "$dir"
            export REPO_DIR="$(pwd)"
            git clone . "$dir"
            echo [AutoRelease] Finding build script...
            cd "$dir"
            if [ -f "$dir/build.release.bash" ]; then
                export dir="$dir"
                echo "$REPO_DIR" > "$dir/tmp.repodir"
                if [ "$UID" == "0" ]; then
                    mkdir /tmp/autoreleaseuser &> /dev/null
                    chown autorelease /tmp/autoreleaseuser
                    
                    chown autorelease -R "$dir"
                    runuser --user autorelease -- bash "$SCRIPT_DIR/auto-release-user.bash" || errorExit
                else
                    bash "$SCRIPT_DIR/auto-release-user.bash" || errorExit
                fi
                
                if [ -f "${REPO_DIR}/autorelease.allow.install" ]; then
                    
                    export DEST="$(cat "$dir/tmp.dest")"
                    export BUILDDIR="$(cat "$dir/tmp.builddir")"
                    export USER1="$(cat "$dir/tmp.user1")"
                    export USER2="$(cat "$dir/tmp.user2")"
                    export USER3="$(cat "$dir/tmp.user3")"
                    export USER4="$(cat "$dir/tmp.user4")"
                    export USER5="$(cat "$dir/tmp.user5")"
                    
                    export -f log
                    
                    cd "$dir"
                    log Installing...
                    bash "$dir/tmp.installscript" || errorExit
                    echo
                    log Post-installing...
                    bash "$dir/tmp.postinstallscript" || errorExit
                    echo
                    log Done, release script has completed.
                    echo
                    
                fi
            else
                echo
                echo [AutoRelease] No build script, cannot continue! Please create build.release.bash \(bash cript\)
                echo [AutoRelease] and write your building instructions in it, use buildOutput to set the output directory
                echo [AutoRelease] that will be copied into the output folder. \(set with the destination function\)
                echo
                echo [AutoRelease] The build function will be called to build the program, the publish function will be called to
                echo [AutoRelease] upload the binaries.
                echo [AutoRelease] The prepare function is called to prepare for building, it is called before changing directory.
                echo
                echo [AutoRelease] The install function will run as root, but it is not available unless your system administrator
                echo [AutoRelease] enables it. The postInstall function is called after installation.
                echo
            fi
            
            rm -rf "$dir"
        fi
    fi
fi
