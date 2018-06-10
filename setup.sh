echo "HOME: $HOME"

# Symlinks all the dotfiles into your home directory
echo "Setting up symlinks to custom dotfiles"

for FILE in `ls -A $PWD/dotfiles/`; do
    if [ -e "$HOME/$FILE" ]
    then
        echo "$HOME/$FILE already exists, renaming it to $FILE.bak"

        if [ -e "$HOME/$FILE.bak" ]
        then
            rm "$HOME/$FILE.bak"
        fi

        mv "$HOME/$FILE" "$HOME/$FILE.bak"
    fi

    echo "Linking $FILE"
    ln -s "$PWD/dotfiles/$FILE" "$HOME/$FILE";
done
echo "Success!"
