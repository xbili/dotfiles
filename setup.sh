# TODO: Perform installation of necessary packages/dependencies

# Symlinks all the dotfiles into your home directory
echo "Setting up symlinks to custom dotfiles"
for FILE in .; do
    if [ -e "~/$FILE" ]
    then
        echo "$FILE already exists, renaming it to $FILE.bak"
        mv "~/$FILE" "~/$FILE.bak"
    fi

    echo "Linking $FILE"
    ln "$FILE" "~/$FILE";
done
echo "Success!"
