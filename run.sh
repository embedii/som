#!/bin/bash

emoji=(😺 😸 😹 😻 😼 😽 🙀 😿 😾)

botmesg() {
 echo ""
 echo "${emoji[$(((RANDOM % 9) + 1)) - 1]}💬"
 sleep 1
 echo "$1"
 echo ""
 sleep 2
}

set() {
botmesg "Welcome $yourName how are you to day"

if [ ! $(grep "firstrun" ~/$mp/info.txt) ];then
 botmesg "This first run i will load your work from google drive"
 . ~/./$path/gdrive/update.sh
 first
 echo "firstrun" >> ~/$mp/info.txt
# count
fi

if [ ! $(find ~/ -type d -name "Workspace") ];then
 botmesg "I found you here in the first time"  
 botmesg "Excuse me load your work from google drive in here"

 . ~/./$path/gdrive/update.sh
 first
fi
 botmesg "Now my ability have check update your works"
}

run() {
 fullpath=$(find ~/ -type d -name "myai")
if [ "$USER" == "" ]
 then
  path=$(echo $fullpath | grep -Po ".*/home/\K.*")
 else
  path=$(echo $fullpath | grep -Po ".*/home/[[:alpha:]]{1,}/\K.*")
 fi 

 echo $fullpath
 echo $path 

 mp=$path
 if [ ! -f ~/$mp/info.txt ];then
   complet=false
  while [ $complet == false ]
   do
    botmesg "Hello.."
    botmesg "Please sign in just assign yourname and password"
    read -e -p "$(botmesg "yourname?: ")" name
    read -e -p "$(botmesg "yourpassword?: ")" pass
   
   echo "yourName=$name" >> ~/$mp/info.txt
   echo "mypass=$pass" >> ~/$mp/info.txt
   #firstrun=false
   complet=true
   done
   set

 else
   yourName=$(grep -Po "yourName=\K.*" ~/$mp/info.txt)
   mypass=$(grep -Po "mypass=\K.*" ~/$mp/info.txt)

   while [ "$name" != "$yourName" ]
   do
  #trap '' 2
  name=""
  pass=""

   botmesg "Who are you?"
   read -e -p "$(botmesg "What's your name?: ")" name

   if [ "$name" == "$yourName" ];then
     while [ "$pass" != "$mypass"  ]
      do
       botmesg "Are you $yourName sure?"
       read -e -s -p "$(botmesg "Please insert password: ")" pass
       if [ "$pass" == "$mypass" ];then 
	#trap 2     
        break 

       fi 
       botmesg "Sorry, I don't know you are"
       echo ""

     done
    fi
# botmesg "You are ton really!, ${greeting[$(((RANDOM % 2) + 1)) - 1]} ton"
 if [ "$name" != "$yourName" ];then
 botmesg "Sorry, I don't know you are"
 fi

 done
 set
 fi
}

run

botmesg ""
