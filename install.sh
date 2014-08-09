#!/usr/bin/env bash
set -eo pipefail

# Setup parameters
: ${PLUSHU_ROOT:="$(cd "$(dirname "$0")" && pwd)"}
: ${PLUSHU_SCRIPT:="$PLUSHU_ROOT/bin/plushu"}

# Directory to install plushu script to, unset to disable
BIN_DIR="${BIN_DIR-/usr/local/bin}"

# Link the plushu script into the bin dir
if [ -n "$BIN_DIR" ]; then
  ln -sf "$PLUSHU_SCRIPT" "$BIN_DIR"
fi

# If the root is a git clone, set it to ignore new files
if [ -d "$PLUSHU_ROOT/.git/info" ]; then
  printf '*\n' > "$PLUSHU_ROOT/.git/info/exclude"
fi

# Create an initial .plushurc
cat >"$PLUSHU_ROOT/.plushurc" <<"EOF"
PATH=$HOME/bin:$PATH
EOF

# Install the core plugins
mkdir -p "$PLUSHU_ROOT/plugins"
if [ ! -d "$PLUSHU_ROOT/plugins/plugins" ]; then
  git clone https://github.com/plushu/plushu-plugins-plugin \
    "$PLUSHU_ROOT/plugins/plugins"
fi
if [ ! -d "$PLUSHU_ROOT/plugins/help" ]; then
  plushu plugins:install help-plugin
fi

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
