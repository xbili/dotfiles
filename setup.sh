echo "HOME: $HOME"

# Symlinks all the dotfiles into your home directory
echo "Setting up symlinks to custom dotfiles"

for FILE in `ls -A ./dotfiles/`; do
    if [ -e "$HOME/$FILE" ]
    then
        echo "$HOME/$FILE already exists, renaming it to $FILE.bak"
        mv "$HOME/$FILE" "$HOME/$FILE.bak"
    fi

    echo "Linking $FILE"
    ln "./dotfiles/$FILE" "$HOME/$FILE";
done
echo "Success!"
