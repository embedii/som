#!/bin/bash

import="import sys; sys.path.append('$fullpath/gdrive'); import gdrive;"
mainid="1YaBmJqOTibixRAmMFZTINaweYGzXAk32"

check() {
echo "check update files in ${PWD##*/} folder"

f=(*)
echo "found files: " ${#f[*]}

list=$(python3 -c "import gdrive; gdrive.list()")
#echo $list
dc=($(echo $list | grep -Po "'name': *\K'[^']*'" | grep -o "[^']*") 
$(echo $list | grep -Po "'modifiedTime': *\K'[^']*'" | grep -o "[^']*"))
#echo "file from grive: ${dc[$i]} ${dc[$(($nf+$i))]}"
nf=$((${#dc[@]}/2))
#echo "total files: ${nf}"
 
#n=$(ls -1 | wc -l)
upload=()
metau=()
download=()
metad=()
for e in "${f[@]}"
 do
  for ((i=0; i<$nf; i++))
   do
    if [ $e == ${dc[$i]} ]
     then
      d1=$(date -r $e -Iminute)
      t1=$(echo $d1 | grep -Po  "[[:digit:]]{2}[:][[:digit:]]{2}[+]")
      d1=$(echo $d1 | grep -Po  "^[[:digit:]]{4}[-][[:digit:]]{2}[-][[:digit:]]{2}")

      d2=${dc[$(($nf+$i))]}
      d2=$(date -d "$d2" -Iminute)
      t2=$(echo $d2 | grep -Po  "[[:digit:]]{2}[:][[:digit:]]{2}[+]")
      d2=$(echo $d2 | grep -Po  "^[[:digit:]]{4}[-][[:digit:]]{2}[-][[:digit:]]{2}")
      #echo "${e} $(date -r $e '+%x %X')"
      if [[ "$d1" > "$d2" || "$d1" == "$d2" && "$t1" > "$t2" ]]
      then
	      echo "$d1 $t1 > $d2 $t2"
	upload+=($e)
        metau+=("$d1 $t1")
      elif [[ "$d1" < "$d2" || "$d1" == "$d2" && "$t1" < "$t2" ]]
      then
	      echo "$d1 $t1 < $d2 $t2"
	download+=(${dc[$i]})
        metad+=("$d2 $t2")
      fi
   fi
    done
 done

echo "file numbers must have upload: ${#upload[@]}"
for ((i=0; i<${#upload[@]}; i++))
 do
  echo "${upload[$i]} ${metau[$i]}"
 done

echo "file numbers must have download: ${#download[@]}"
for ((i=0; i<${#download[@]}; i++))
 do
  echo "${download[$i]} ${metad[$i]}"
 done

}

uploadd() {
 if [[ "${#upload[@]}" > 0  ]]
 then
  for file in "${upload[@]}"
   do 
    python3 -c "import gdrive; gdrive.update('$file')"
   done
 echo "upload completed"
 fi

}

downloadd() {
 create() {
  python3 -c "$import gdrive; gdrive.download('$1','$2','$3','$4','$5')"
 }

 if [[ "${#download[@]}" > 0  ]]
  then
   for file in "${download[@]}"
    do 
     create $1 $2 $3 $4 $5
    done
  else
   create $1 $2 $3 $4 $5
  fi

}

tester() {
tl=$(python3 -c "$import gdrive.list('$mainid')")
echo $tl
tf=($(echo $tl | grep -Po "'id': *\K'[^']*'" | grep -o "[^']*") 
$(echo $tl | grep -Po "'name': *\K'[^']*'" | grep -o "[^']*") 
$(echo $tl | grep -Po "'mimeType': *\K'[^']*'" | grep -o "[^']*") 
 $(echo $tl | grep -Po "'fileExtension': *\K'[^']*'" | grep -o "[^']*"))
 tfi=$((${#tf[@]}/4))
 for (( k=0; k<$tfi; k++ ))
  do
  echo "${tf[$k]} ${tf[$(($tfi+$k))]}"
  done 
}

first() {
 patname=()
 patid=()
 list=$(python3 -c "$import gdrive.list('$mainid')")
echo $list
 gf=($(echo $list | grep -Po "'id': *\K'[^']*'" | grep -o "[^']*") 
$(echo $list | grep -Po "'name': *\K'[^']*'" | grep -o "[^']*") 
$(echo $list | grep -Po "'mimeType': *\K'[^']*'" | grep -o "[^']*") 
$(echo $list | grep -Po "'fileExtension': *\K'[^']*'" | grep -o "[^']*"))
 gfi=$((${#gf[@]}/4))

 mkdir Workspace
 for ((f=0; f<$gfi; f++))
  do	    
   q=1
   t=0
   path="Workspace/"
   cid=${gf[$f]}
   cname=${gf[$(($gfi+$f))]}
   ctype=${gf[$(($gfi+$gfi+$f))]}
   cext=${gf[$(($gfi+$gfi+$gfi+$f))]}

   while [[ $q > 0 ]]
    do
     chls=$(python3 -c "$import gdrive.list('$cid')")

      if [ "$chls" != "[]" ]
       then
        cf=($(echo $chls | grep -Po "'id': *\K'[^']*'" | grep -o "[^']*") 
            $(echo $chls | grep -Po "'name': *\K'[^']*'" | grep -o "[^']*") 
            $(echo $chls | grep -Po "'mimeType': *\K'[^']*'" | grep -o "[^']*") 
	    $(echo $chls | grep -Po "'fileExtension': *\K'[^']*'" | grep -o "[^']*"))
        cfi=$((${#cf[@]}/4))
	q=$(($q+$cfi))
	t=0

      fi

      if [[ "$ctype" == "application/vnd.google-apps.folder" ]]
      then
	path+="$cname/"
	echo "make dir $path "
	mkdir -p $path

        patname+=("$path")
	patid+=("$cid")
	echo ""
     fi

     if [[ "$ctype" != "application/vnd.google-apps.folder" ]]
      then
       cpath=${patname[$((${#patname[@]}-$t))]}
        if [[ ${#patname[@]} == 0 ]]
         then
	  cpath="$path"
        fi
        echo "download file"
	echo "$cname to $cpath"
	echo "file extension $cext"
	downloadd $ctype $cext $cid $cname $cpath
        echo ""
     fi

  cid=${cf[$t]}
  cname=${cf[$(($cfi+$t))]}
  ctype=${cf[$(($cfi+$cfi+$t))]}
  cext=${cf[$(($cfi+$cfi+$cfi+$t))]}
  
  t=$(($t+1))
  q=$(($q-1))
  done

  cf=()
 done

 for dd in "${patname[@]}"
   do
    echo "path: $dd"
   done

}

#list=(sky tree mountain river)
#echo ${#list[@]}
#echo $list

#dc=$(echo $i | gerp -Po '"name": *\K"[^"]*"' | grep -o '[^"]*')

#file='update.sh'
#list=$(python3 -c "import gdrive; gdrive.list()")
#echo $list
#for i in "${!list[@]}"
# do
#  echo $i
# done
