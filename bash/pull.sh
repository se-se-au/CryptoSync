#!/bin/bash
prompt_confirm() {
  while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) echo ; return 0 ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "invalid input"
    esac 
  done  
}

while getopts r:l:p:s: option
do
case "${option}"
in
r) resourceid=${OPTARG};;
l) localfile=${OPTARG};;
p) protocol=${OPTARG};;
s) storage=${OPTARG};;

esac
done

read -sp 'Password:' password

remainder="$password"
first="${remainder%%_*}"; remainder="${remainder#*_}"
second="${remainder%%_*}"; remainder="${remainder#*_}"
export SSHPASS=$second

sshpass -e $protocol -p $storage/$resourceid

echo "Remote:"
stat -c "%y" $resourceid 
echo "Local:"
stat -c "%y" $localfile 

prompt_confirm "Overwrite local file?" || exit 0
openssl aes-256-ecb -md sha256 -d -a -in $resourceid -out $localfile -k $first
echo "Local updated!"
rm -f $resourceid
