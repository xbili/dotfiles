echo "----------------"
echo "BEGIN: Vim setup"
echo "================"

# Symlinks all vim configuration files into home directory.
echo "Symlink vim configurations to: $HOME"

BASEDIR=$(cd "$(dirname "$0")" ; pwd -P)
VIMRC="$BASEDIR/.vimrc"

echo "BASEDIR: $BASEDIR"

# Symlink other vim configurations into .vim folder
for DOTVIM in `find $BASEDIR -name "*.vim"`; do
    BASENAME=$(basename $DOTVIM)
    if [ -e "$HOME/.vim/$BASENAME" ]; then
        # File already exists: rename existing file to $FILE.bak
        if [ -e "$HOME/.vim/$BASENAME.bak" ]; then
            rm "$HOME/.vim/$BASENAME.bak"
        fi
        mv "$HOME/.vim/$BASENAME" "$HOME/.vim/$BASENAME.bak"
    fi

    echo "Linking $BASENAME..."
    ln -s $DOTVIM "$HOME/.vim/$BASENAME"
done

# Symlink .vimrc
echo "Linking .vimrc: $VIMRC..."
if [ -e "$HOME/.vimrc" ]; then
    # File already exists: rename existing file to $FILE.bak
    if [ -e "$HOME/.vimrc.bak" ]; then
        rm "$HOME/.vimrc.bak"
    fi
    mv "$HOME/.vimrc" "$HOME/.vimrc.bak"
fi
ln -s $VIMRC "$HOME/.vimrc"

echo "==================="
echo "COMPLETE: Vim setup"
echo "-------------------"
