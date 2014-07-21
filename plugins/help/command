#!/usr/bin/env bash
set -eo pipefail; [[ $PLUSHU_TRACE ]] && set -x

PAGER=${PAGER:-less}

plugin=${2%%[: ]*}
query=$2

runpager () {
  # If there's a query specified (there always is)
  # and its more than just the name of the plugin
  if [[ -n "$2" && "$plugin" != "$2" ]]; then

    # Open the pager to the first line that
    # matches the given query
    case "${PAGER%% *}" in
      more|less|most)
        $PAGER "+/$2" "$1"
        ;;
      pg)
        $PAGER "+/$2/" "$1"
        ;;
      nano|pico)
        $PAGER +`grep -nm1 "$2" "$1" | cut -f1 -d:` "$1"
        ;;
      *)
        $PAGER "$1"
        ;;
    esac

  # If the query is for the name of the plugin
  # (or if there were no query specified)
  else
    # Just open the pager for the given file
    $PAGER "$1"
  fi
}

# If a plugin name was specified
if [[ -n $2 ]]; then

  # If that plugin exists
  if [[ -d "$PLUSHU_ROOT/plugins/$plugin" ]]; then

    # Get all README files with a file extension
    readmes=$(shopt -s nullglob; echo "$PLUSHU_ROOT/plugins/$plugin/README.*")

    # If that plugin has at least 1 README file
    if [[ -f "$PLUSHU_ROOT/plugins/$plugin/README" || -n $readmes ]]; then

      if [[ -f "$PLUSHU_ROOT/plugins/$plugin/README" ]]; then
        runpager "$PLUSHU_ROOT/plugins/$plugin/README" "$query"
      fi
      for readme in $readmes; do
        runpager "$readme" "$query"
      done

    # If that plugin does not have any README files
    else
      echo "No README for $2" >&2
      exit 1
    fi

  # If that plugin does not exist
  else
    echo "Plugin '$2' not found" >&2
    exit 1
  fi

# If no plugin name was specified (just `plushu help`)
else
  runpager "$PLUSHU_ROOT/README.md" "^## Usage"
fi
