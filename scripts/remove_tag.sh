echo http://nathanhoad.net/how-to-delete-a-remote-git-tag

if [ "$1" == "" ]; then
   echo "  usage: $0  tag"
   echo "example: $0  1.5.0"
   exit 1
fi

git tag $1 --delete
git push origin :refs/tags/$1


