#!/usr/bin/env bash
set -eo pipefail

# Setup parameters
: ${PLUSHU_ROOT:="$(cd "$(dirname "$0")" && pwd)"}
: ${PLUSHU_SCRIPT:="$PLUSHU_ROOT/bin/plushu"}

# Directory to install plushu script to, unset to disable
BIN_DIR="${BIN_DIR-/usr/local/bin}"

# If the root is a git clone, set it to ignore new files
if [ -d "$PLUSHU_ROOT/.git/info" ]; then
  printf '*\n' > "$PLUSHU_ROOT/.git/info/exclude"
fi

# Create an initial .plushurc
cat >"$PLUSHU_ROOT/.plushurc" <<"EOF"
PATH=$HOME/bin:$PATH
EOF

gh_archive () {
  printf '%s\n' "https://github.com/plushu/$1/archive/master.tar.gz"
}

# Install the core plugins
mkdir -p "$PLUSHU_ROOT/plugins"
if command -v git >/dev/null 2>&1; then
  if [ ! -d "$PLUSHU_ROOT/plugins/plugins" ]; then
    git clone https://github.com/plushu/plushu-plugins-plugin \
      "$PLUSHU_ROOT/plugins/plugins"
  fi
  if [ ! -d "$PLUSHU_ROOT/plugins/help" ]; then
    "$PLUSHU_ROOT/bin/plushu" plugins:install help-plugin
  fi
elif command -v git >/dev/null 2>&1; then
  echo 'Git does not appear to be present on your system; falling back to'
  echo 'curl to install the core `plugins` and `help` plugins.'
  echo 'It is recommended that you install Git for managing plugins;'
  echo 'if you do, delete plugins/plugins and plugins/help, then rerun'
  echo 'this installer to re-install these plugins via Git.'
  if [ ! -d "$PLUSHU_ROOT/plugins/plugins" ]; then
    curl `gh_archive plushu-plugins-plugin` |
      tar xzC "$PLUSHU_ROOT/plugins/plugins"
  fi
  if [ ! -d "$PLUSHU_ROOT/plugins/help" ]; then
    curl `gh_archive plushu-help-plugin` |
      tar xzC "$PLUSHU_ROOT/plugins/help"
  fi
else
  echo 'The core `plugins` and `help` plugins were not installed because'
  echo 'Git does not appear to be present on your system (and no `curl`'
  echo 'fallback was present either).'
  echo 'To install the core plugins, install Git, then re-run this installer.'
fi

# If root is performing the installation
if [[ $EUID == 0 ]]; then
  # Create the plushu user if they do not exist
  if ! id -u plushu >/dev/null 2>&1; then
    useradd -Md "$PLUSHU_ROOT" -s "$PLUSHU_SCRIPT" plushu
  fi

  # Initialize the ssh settings
  mkdir -p "$PLUSHU_ROOT/.ssh"
  touch "$PLUSHU_ROOT/.ssh/authorized_keys"
  chmod 0700 "$PLUSHU_ROOT/.ssh"
  chmod 0600 "$PLUSHU_ROOT/.ssh/authorized_keys"

  # Set appropriate ownership and permissions
  chown -R plushu "$PLUSHU_ROOT"
  chmod 0711 "$PLUSHU_ROOT"

  # Link the plushu script into the bin dir
  if [ -n "$BIN_DIR" ]; then
    ln -sf "$PLUSHU_SCRIPT" "$BIN_DIR"
  fi
fi
