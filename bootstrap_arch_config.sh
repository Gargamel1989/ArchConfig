#!/bin/sh

# 
# Download this file and run it on a fresh Arch install to setup
# the configuration.
#

# PARAMETERS
CONFIG_DIR=$HOME/.config
GIT_REPO_URL="https://github.com/Gargamel1989/ArchConfig.git"

INPUT=/tmp/bootstrap.sh.$$

x=`pacman -Qs ^dialog$`
if [ ! -n "$x" ]; then
  echo "Dialog is required for setup, installing now"
  sudo pacman -S dialog
fi

echo "$EUID"
# Check if the current user is root
if [[ $EUID -eq 0 ]]; then
  dialog --title "Configuration Setup" --yesno "You're currently logged in as root, would you like to create a user before setup?" 14 50
  resp=$?
  case $resp in
  0) 
    dialog --title "Configuration Setup" --inputbox "Please enter a username" 14 50 2> "${INPUT}"
    exec_user=$(<"${INPUT}")
    useradd -m -G wheel -s /bin/bash $exec_user
    passwd $exec_user
    cd /home/$exec_user
    CONFIG_DIR=/home/$exec_user/.config
    ;;
  *)
    exec_user=$USER
    ;;
  esac
fi

dialog --no-tags --title "Configuration Setup" --menu "Please select the location where you would like to put the configuration" 14 50 20 0 "$CONFIG_DIR" 1 "The current working directory" 2 "A custom directory" 2> "${INPUT}"
dir_pick=$(<"${INPUT}")

case $dir_pick in
2)
  dialog --dselect / 14 50 2> "${INPUT}"
  config_dir=$(<"${INPUT}")
  ;;
1)
  config_dir=`pwd`
  ;;
*)
  config_dir=$CONFIG_DIR
  ;;
esac

clear


# Install git and get the configuration
x=`pacman -Qs ^git$`
if [ ! -n "$x" ]; then
  echo "Installing git to fetch configuration files"
  sudo pacman -S git
fi

# Check if the config directory exists
if [ -d "$config_dir" ]; then
  # Check if the directory is a git directory and the remote url is correct
  cd $CONFIG_DIR

  remote_url=`git config --get remote.origin.url`
  
  # Check git and remote url
  if [ "$remote_url" != "$GIT_REPO_URL" ]; then
    echo "$config_dir exists, backing up to $config_dir.bak"
    mv -f $config_dir $config_dir.bak
  fi

fi


if [ ! -d "$CONFIG_DIR" ]; then
  git clone https://github.com/Gargamel1989/ArchConfig.git $config_dir &> /dev/null
else
  git pull origin master &> /dev/null
fi

echo "Starting setup script"
su $exec_user -c "sh $config_dir/config_setup.sh"
