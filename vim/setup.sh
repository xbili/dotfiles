echo "----------------"
echo "BEGIN: Vim setup"
echo "================"

# Symlinks all vim configuration files into home directory.
echo "Symlink vim configurations to: $HOME"

BASEDIR=$(cd "$(dirname "$0")" ; pwd -P)
VIMRC="$BASEDIR/.vimrc"

echo "BASEDIR: $BASEDIR"

# Symlink other vim configurations into .vim folder
for DOTVIM in `find $BASEDIR -name *.vim`; do
    BASENAME=$(basename $DOTVIM)
    if [ -e "$HOME/.vim/$BASENAME" ]; then
        # File already exists: rename existing file to $FILE.bak
        # rm "$HOME/.vim/$BASENAME.bak"
        # mv "$HOME/.vim/$BASENAME" "$HOME/.vim/$BASENAME.bak"
    fi

    echo "Linking $BASENAME..."
    # ln -s $DOTVIM "$HOME/.vim/$BASENAME"
done

# Symlink .vimrc
echo "Linking .vimrc: $VIMRC..."
# ln -s $VIMRC "$HOME/.vimrc"

echo "==================="
echo "COMPLETE: Vim setup"
echo "-------------------"
