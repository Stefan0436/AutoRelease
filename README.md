# AutoRelease
AutoRelease is a set of scripts and a post-receive hook, it allows for automatically publishing
projects after a #Release commit has been pushed.

# Installing
First, run `sh prepare.sh` to mark all files as executable.
Then copy all files, except the preparation script into your bare server repository.

After that, create autorelease.users and add usernames (authentication names) that may
release content with AutoRelease. (one username per line)

After that, you need to create the autorelease user, configure it so that it wont be able to log in:

```bash
# Please run this as root

# Create the user:
#
# -r - system user
# -d - set home directory
#
useradd -rd "/tmp/autoreleaseuser" autorelease

# Lock it, this prevents loggin in as this user
usermod -L autorelease
```

That is all you need to do for installation.


# Creating publish scripts
Now that you have AutoRelease installed, you can create the `build.publish.bash` file in your repository.
This file is run as the autorelease user to build the project.

Example:

```bash
#!/bin/bash

#
# This script builds and publishes a gradle project
# if you push a commit with #Release in the message.
#

function build() {
    chmod +x gradlew
    ./gradlew build
}

function publish() {
    ./gradlew publish
}
```
