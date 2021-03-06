#!/usr/bin/env bash
set -eo pipefail

# Setup parameters
PLUSHU_ROOT="${PLUSHU_ROOT:-"$(cd "$(dirname "$0")" && pwd)"}"

# User to set up for Plushu, unset to disable
PLUSHU_USER="${PLUSHU_USER-plushu}"

# Directory to install plushu script to, unset to disable
BIN_DIR="${BIN_DIR-/usr/local/bin}"

# If the root is a git clone, set it to ignore new files
if [[ -d "$PLUSHU_ROOT/.git/info" ]]; then
  printf '*\n' > "$PLUSHU_ROOT/.git/info/exclude"
fi

# Create an initial .plushurc
cat >"$PLUSHU_ROOT/.plushurc" <<"EOF"
export PATH=$HOME/bin:$PATH
EOF

gh_archive () {
  printf '%s\n' "https://github.com/plushu/$1/archive/master.tar.gz"
}

# Install the core plugins
mkdir -p "$PLUSHU_ROOT/plugins"
if command -v git >/dev/null 2>&1; then
  if [[ ! -d "$PLUSHU_ROOT/plugins/plugins" ]]; then
    git clone https://github.com/plushu/plushu-plugins-plugin \
      "$PLUSHU_ROOT/plugins/plugins"
  fi
  if [[ ! -d "$PLUSHU_ROOT/plugins/help" ]]; then
    git clone https://github.com/plushu/plushu-help-plugin \
      "$PLUSHU_ROOT/plugins/help"
  fi
  if [[ ! -d "$PLUSHU_ROOT/plugins/version" ]]; then
    git clone https://github.com/plushu/plushu-version \
      "$PLUSHU_ROOT/plugins/version"
  fi
  if [[ ! -d "$PLUSHU_ROOT/plugins/git" ]]; then
    git clone https://github.com/plushu/plushu-git \
      "$PLUSHU_ROOT/plugins/git"
  fi
elif command -v curl >/dev/null 2>&1; then
  echo 'Git does not appear to be present on your system; falling back to'
  echo 'curl to install the core `plugins`, `help`, and `version` plugins.'
  echo 'It is recommended that you install Git for managing plugins;'
  echo 'if you do, delete plugins/*, then rerun this installer to re-install'
  echo 'these plugins via Git.'
  if [[ ! -d "$PLUSHU_ROOT/plugins/plugins" ]]; then
    curl $(gh_archive plushu-plugins-plugin) |
      tar xzC "$PLUSHU_ROOT/plugins/plugins"
  fi
  if [[ ! -d "$PLUSHU_ROOT/plugins/help" ]]; then
    curl $(gh_archive plushu-help-plugin) |
      tar xzC "$PLUSHU_ROOT/plugins/help"
  fi
  if [[ ! -d "$PLUSHU_ROOT/plugins/version" ]]; then
    curl $(gh_archive plushu-version) |
      tar xzC "$PLUSHU_ROOT/plugins/version"
  fi
else
  echo 'The core `plugins`, `help`, and `version` plugins were not installed'
  echo 'because neither Git nor curl appears to be present on your system.'
  echo 'To install the core plugins, install Git (or curl), then re-run this'
  echo 'installer.'
fi

# If root is performing the installation
if [[ "$EUID" == 0 ]]; then
  # If we're set to configure a plushu user
  if [[ -n "$PLUSHU_USER" ]]; then
    # Create the plushu user if they do not exist
    if ! id "$PLUSHU_USER" >/dev/null 2>&1; then
      useradd -Md "$PLUSHU_ROOT" -s "$PLUSHU_ROOT/bin/plushush" "$PLUSHU_USER"
    fi

    # Initialize the ssh settings
    mkdir -p "$PLUSHU_ROOT/.ssh"
    touch "$PLUSHU_ROOT/.ssh/authorized_keys"
    chmod 0700 "$PLUSHU_ROOT/.ssh"
    chmod 0600 "$PLUSHU_ROOT/.ssh/authorized_keys"

    # Set appropriate ownership and permissions
    chown -R "$PLUSHU_USER:" "$PLUSHU_ROOT"
    chmod 0711 "$PLUSHU_ROOT"
  fi

  # Link the plushu script into the bin dir
  if [[ -n "$BIN_DIR" ]]; then
    ln -sf "$PLUSHU_ROOT/bin/plushu" "$BIN_DIR"
  fi
fi
