for file in "${HOME}"/.bash_aliases.d/*.sh;
do
  . "$file"
done
