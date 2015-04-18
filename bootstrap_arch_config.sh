#!/bin/sh

# 
# Download this file and run it on a fresh Arch install to setup
# the configuration.
#

# PARAMETERS
CONFIG_DIR="$HOME/.config"
GIT_REPO_URL="https://github.com/Gargamel1989/ArchConfig.git"

INPUT=/tmp/bootstrap.sh.$$

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
x=`pacman -Qs git`
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
sh $config_dir/config_setup.sh
