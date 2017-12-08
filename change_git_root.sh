# !/bin/bash

#===========
# Custom Variables
#===========

# Home directory where we will do all work (do not add "/" at end. Fow Windows path wood be /c/somefolder/)
home="/d/Git"
# Repository URL (Tested on SSH)
repo="ssh://git@bitbucket.example.com:7999/~d.alekseev/repo.git"
# Move root project to directory (example: .., ../newroot, AndroidStudioProject, src) (do not add / symvol )
newroot=AndroidStudioProject

#===========
# End of Custom Variables
#===========

# Get repository folder name from repository URL
reponame=$(sed 's%^.*/\([^/]*\)\.git$%\1%g' <<< $repo)
#===========
# RTFM:
#===========
echo '   ________                              ________________                    __ '
echo '  / ____/ /_  ____ _____  ____ ____     / ____/  _/_  __/  _________  ____  / /_'
echo ' / /   / __ \/ __ `/ __ \/ __ `/ _ \   / / __ / /  / /    / ___/ __ \/ __ \/ __/'
echo '/ /___/ / / / /_/ / / / / /_/ /  __/  / /_/ // /  / /    / /  / /_/ / /_/ / /_  '
echo '\____/_/ /_/\__,_/_/ /_/\__, /\___/   \____/___/ /_/    /_/   \____/\____/\__/  '
echo '                       /____/                                                   '
sleep 1
echo    
sleep 1
echo "#===========
This script is universall script for change repository root folder
Before use it you must change custom variables in this script: 
home (now set to $home); 
repo (now set to $repo);
newroot (now set to $newroot).
For yours security we create full backup of your repository before
do any changes to it."
sleep 4
echo    
sleep 1
echo "#===========
Your backup will be stored in:
$home/backup/$reponame.git in bare format.
You can restore all if something goes wrong:
Delete your previous repo and create clean repo with same URL,
after it run following commands:
cd $home/backup/$reponame.git
git push --all
git push --tags"
sleep 4
echo    
sleep 1
echo "#===========
Author Dmitriy Alekseev & Roman Rezvov (c) 2017"
#===========
# End of RTFM
#===========

#===========
# Aprove
#===========
sleep 1
echo "Working with repository $reponame"
echo "URL: $repo"
read -p "Are you sure ready to begin (press ""y"" to start)? " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi
#===========
# End of Aprove
#===========
#===========
echo    
echo "CAUTION FOR WINDOWS USERS!!!
Before run this script we need to stop EXPLORER.EXE, explanation:
gitcmd.exe sometimes can't move folders that are created/moved before,
because explorer.exe process locking files in folders and you will see:
mv: cannot move .git to newroot/.git Permission denied"
read -p "Are you want terminate explorer.exe (press ""y"" if you run this on Windows)? " -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
windowsos=true
else
windowsos=false
fi

#===========
# Main Part
#===========
# Check previous backup
if [ -f "$home/backup/$reponame.git/HEAD" ]; then
echo    
sleep 1
echo "#===========
We found previous backup in $home/backup/$reponame.git folder.
If you need it, rename it, or move it elsewhere.
Then run script again!"
read -n1 -r -p "Press any key to continue..." key
exit 1 || return 1
fi
# Check previouse repo
if [ -d "$home/$reponame" ]; then
echo    
sleep 1
echo "#===========
We found previous repo in $home/$reponame folder.
If you need it, rename it, or move it elsewhere.
Then run script again!"
read -n1 -r -p "Press any key to continue..." key
exit 1 || return 1
fi
# Create backup
mkdir -p $home/backup/
cd $home/backup/
git clone --bare $repo
# Check backup
if [ ! -f $home/backup/$reponame.git/packed-refs ]; then
    echo "Backup job was not successful. Stoping script!" && exit 1 || return 1
fi
# Get remote branches from packed-refs (cutting first 53 characters)
remote_branches=$(cut -c 53- $home/backup/$reponame.git/packed-refs)
declare -a remote_branches_array=($remote_branches)

# Kill Explorer
if [ "$windowsos" = true ]
then
cmd "/C taskkill /f /im explorer.exe"
fi

# Working
for branch in "${remote_branches_array[@]}"
do
	echo    
	sleep 3
	echo "#==========="
	echo "Working with $branch"
	cd $home/
	git clone -b $branch $repo
	cd $reponame/
	mv .git $newroot/
	mv .gitignore $newroot/
	cd $newroot/
	git init
	git add .
	git commit -am 'Repository root is fixed'
	git push origin $branch
	cd $home/
	rm -rf $reponame
	echo "End working with $branch"
	echo "#==========="
	read -n1 -r -p "Press any key to continue..." key
done

# Launch Explorer back
if [ "$windowsos" = true ]
then
cmd "/C explorer.exe"
fi
#===========
# End of Main Part
#===========
echo "Thats all, please check the result at yours server,
and don't mess up with git init in future..."
exit
