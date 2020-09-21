This tool implements my symlinking scheme for system wide machine specific
configuration files. In effect, it centralizes system config files (typically
found in `/etc`) into the `~/system` directory with a simple scheme for
managing per-machine configuration. See the README in `~/system` for more
details on the scheme.

The typical way in which this utility is run is to first confirm that the
changes look okay:

```
$ setup-system-links --dry-run
```

and then commit them:

```
$ sudo -E setup-system-links
```

Backups are made of each system config file before they are replaced, and the
output of the commands above show where the backup resides.

The main downside of this approach to configuration is that it makes these
config files user editable where as they are normally only configured via root.
But these days, most of my systems are single-user with `NOPASSWD` access to
`sudo`, so this isn't really a main difference maker in my setup. Therefore,
this scheme won't work well in more robust shared systems.
