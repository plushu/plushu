# plushu core plugin management commands

The "plugins" plugin in plushu contains subcommands for managing other plugins.

## plugins:install

Usage: `plushu plugins:install <remote> [local]`

Installs a plugin by cloning the named remote into the `plugins` directory,
then running the `install` script (if any) for that plugin.

The remote repository can be specified as a GitHub username/project combo, or
as the name of a plushu GitHub organization repo (eg. "example" will be
resolved as "git@github.com:plushu/plushu-example").

By default, the name the plugin will be installed to is the same as the
repository name, minus any "plushu-" prefix or "-plugin" suffix.

## plugins:reinstall

Usage: `plushu plugins:reinstall <plugin>`

Re-runs a plugin's `install` script (if any).

## plugins:uninstall

Usage: `plushu plugins:uninstall <plugin>`

Runs any `uninstall` script for the plugin, and then removes the directory.

The core plugins ("help", "version", and "plugins") cannot be uninstalled.
