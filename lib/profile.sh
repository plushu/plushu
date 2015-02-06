check_plushu_user () {
  # let id fail us out if PLUSHU_USER doesn't exist
  id "$PLUSHU_USER" >/dev/null || exit "$?"

  # If the PLUSHU_ROOT is not explicitly defined
  if [[ -z "$PLUSHU_ROOT" ]]; then
    # use PLUSHU_USER's home directory
    PLUSHU_ROOT=$(getent passwd "$PLUSHU_USER" | cut -d: -f6)
  fi
}

# If the PLUSHU_USER is not explicitly defined
if [[ -z "$PLUSHU_USER" ]]; then
  # If PLUSHU_ROOT is explicitly defined
  if [[ -n "$PLUSHU_ROOT" ]]; then
    # Default to the owner of PLUSHU_ROOT
    PLUSHU_USER=$(ls -ld "$PLUSHU_ROOT" | cut -d' ' -f3)
  # If PLUSHU_ROOT is not explicitly defined
  else
    # If the current user is root
    if [[ "$EUID" == 0 ]]; then
      # Use whatever user is using sudo, or default to "plushu"
      PLUSHU_USER=${SUDO_USER:-plushu}
      check_plushu_user
    # For any non-root user
    else
      # use the current user
      PLUSHU_USER=$(id -un)
      # use the current user's home as the default PLUSHU_ROOT
      PLUSHU_ROOT=${PLUSHU_ROOT:-$HOME}
    fi
  fi
# If PLUSHU_USER is explicitly defined
else
  check_plushu_user
fi

# Export Plushu's config values to commands and hooks
export PLUSHU_USER
export PLUSHU_ROOT

# Set up the root for plugins to use and the plugins dir
export PLUSHU_DIR=${PLUSHU_DIR:-$PLUSHU_ROOT}
export PLUSHU_PLUGINS_DIR=${PLUSHU_PLUGINS_DIR:-$PLUSHU_DIR/plugins}

echo_missing_plushurc_msg () {
cat <<EOF
This file just needs to be present; you can create an empty one with:

\$ sudo -u plushu touch $PLUSHU_ROOT/.plushurc
EOF
}

echo_run_as_plushu_msg () {
cat <<EOF
If you meant to run plushu as the plushu user, try:

\$ sudo -iu plushu $@
EOF
}

# Source configuration variables if the config file is present -
# if the config file is not present, don't trust this as a PLUSHU_ROOT
if [[ -f "$PLUSHU_ROOT/.plushurc" ]]; then
  source "$PLUSHU_ROOT/.plushurc"

  # Ensure this is repeatable
  if [[ ! -f "$PLUSHU_ROOT/.plushurc" ]]; then
    echo "No $PLUSHU_ROOT/.plushurc after sourcing .plushurc" >&2
    exit 1
  fi
else
  echo "No ~/.plushurc found." >&2
  echo >&2
  if [[ "$PLUSHU_USER" == "plushu" ]]; then
    echo_missing_plushurc_msg >&2
  else
    echo_run_as_plushu_msg >&2
  fi
  exit 1
fi

# Echo all commands if PLUSHU_TRACE was set in .plushurc,
# and stop echoing them if it was unset
[[ -n "$PLUSHU_TRACE" ]] && set -x || set +x

# For instances where a glob has no matches we want an empty list
shopt -s nullglob

# Source profiles
for script in "$PLUSHU_PLUGINS_DIR"/*/profile.d/*; do
  plugin_subpath=${script#$PLUSHU_PLUGINS_DIR/}
  plugin_name=${plugin_subpath%%/*}
  PLUSHU_PLUGIN_NAME="$plugin_name" \
  PLUSHU_PLUGIN_PATH="$PLUSHU_PLUGINS_DIR/$plugin_name" \
    source "$script"
done
