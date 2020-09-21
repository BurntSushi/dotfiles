This directory contains machine specific system wide configuration files. The
directory hierarchy follows a convention that permits easily symlinking the
right config file to the right location. Before this scheme, I had just been
maintaining system configuration on an ad hoc basis (and sometimes via
~/bin/arch-install), but this was error prone and inefficient. Namely, I would
frequently need to copy configs from other machines, or worse, would forget
about a config before wiping a machine.

The general scheme is:

```
$HOME/system/etc/path/to/config-file-as-directory/{default,krusty,...}
```

Where `/etc/path/to/config-file-as-directory` is a directory that refers
to a concrete file path in the `/etc` directory. Inside this directory is
an optional file named `default`, along with other optional files named by
hostname, e.g., `krusty`. If a hostname file is present, then that file is
symlinked to the corresponding config file location. Otherwise the `default`
file is. If no files are present, then no symlinks are created. Thus, if you
want to keep a configuration checked into git but disable it, then rename it
from `{name}` to `{name}.disable`.

symlinks are created by `setup-system-links`.
