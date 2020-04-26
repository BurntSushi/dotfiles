My dotfiles
-----------
This repository contains a my home directory setup, including a large
collection of personal scripts. I've built up this configuration over many
years, but had never intended on making it public. Because of a few
idiosyncracies in my previous setup, and after getting requests to share my
dotfiles, I decided to scrub everything clean and start fresh.

Licensed under the [UNLICENSE](https://unlicense.org).


How it's used
-------------
Other than git and a few helper scripts, there's no tool I used to "manage" my
dotfiles. Namely, my home directory *is* a git clone. That is, `$HOME/.git`
exists. So to set up my dotfiles on a new machine, I usually do something like
this:

```
mkdir -p tmp/old
mv .bashrc .bash_profile other things tmp/old
git init
git remoe add origin https://github.com/BurntSushi/dotfiles
git pull origin master --ff-only
git branch --set-upstream-to origin/master master
chmod 0600 "$HOME/.ssh/config"
```

Then I log out and log back in. Most of this process is automated in my
`bin/setup-home` script. I host the latest version of that script at
https://burntsushi.net/stuff/setup-home for convenience.

In order to manage device specific configuration (e.g., my laptop and my
desktop use a different font size for my terminal configuration), I use a
simple symlinking scheme based on hostname. To create symlinks, run
`setup-home-links`.

Note that some files in this repository, such as my SSH configuration, are
encrypted.


Motivation
----------
In general, I'm making this public for the purposes of edification and easy
sharing. It is not a goal for this setup to be used and supported by others.
With that said, small fixes to existing scripts or suggestions on how to
improve my setup are welcome.


Caveats
-------
I may occasionally rewrite history of this repository and force push. This may
occur if I discover that I have accidentally published sensitive information.
