CMD=$(ps aux | grep -c "OS/Xcode")
if  [ $CMD -gt 1 ];
then
  echo "*****Kill Xcode******";
  exit 
fi

branch_name=$(git symbolic-ref -q HEAD)
branch_name=${branch_name##refs/heads/}
branch_name=${branch_name:-HEAD}

echo "rebase on branch:    $branch_name    ? Y/y"
read a
if [[ $a == "Y" || $a == "y" ]]; then
        git checkout master; git pull origin master; git checkout $branch_name; git rebase master;
fi



