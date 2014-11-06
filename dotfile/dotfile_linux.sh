#! /bin/bash
#
# For the Linux init user dev environment
#

echo "Start init the development "
echo "start init the shell env . Change the bash to Zshell..."
#  to install the basic tool like git gcc make and tmux vim etc

if ![ -x ~/.zshrc]; then
  
  git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
  cp ~/.zshrc ~/.zshrc.orig
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
  chsh -s /bin/zsh

fi
echo "then exit and relogin shell"
exit

