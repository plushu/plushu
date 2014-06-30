#!/usr/bin/env bash
set -eo pipefail

echofile () {
  # cat file, ensuring newline at EOF
  sed -e '$a\' $@
}

# If a plugin name was specified
if [ -n $2 ]; then

  # If that plugin exists
  if [ -d "$PLUSHU_ROOT/plugins/$2" ]; then

    # Get all README files with a file extension
    readmes=$(shopt -s nullglob; echo "$PLUSHU_ROOT/plugins/$2/README.*")

    # If that plugin has at least 1 README file
    if [ -f "$PLUSHU_ROOT/plugins/$2/README" || -n readmes ]; then

      if [ -f "$PLUSHU_ROOT/plugins/$2/README" ]; then
        echofile "$PLUSHU_ROOT/plugins/$2/README"
      fi
      for readme in readmes; do
        echofile $readme
      done

    # If that plugin does not have any README files
    else
      echo "No README for $2"
      exit 1
    fi

  # If that plugin does not exist
  else
    echo "Plugin \"$2\" not found"
    exit 1
  fi

# If no plugin name was specified (just `plushu help`)
else
  cat <<"EOF"
plushu uses plugins to implement its features. To see the list of plugins
installed in plushu, run `plushu plugins`. To read the documentation for a
specific plugin, run `plushu help <plugin>`.
EOF

fi
