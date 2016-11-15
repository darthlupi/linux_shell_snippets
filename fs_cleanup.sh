#!/bin/bash

###################
#Set variables
###################
#Percentage that will trigger a deep dive into the file system to find large files.
min_percent=@option.min_percent@
#How much to grow the FS by in addition to the min percent
grow_percent=@option.grow_percent@

max_file_size=@option.max_file_size@
#Files we will attempt to archive
archive_search=@option.archive_search@
tar_search=@option.tar_search@

#Array to hold file system status



function archive_files {
  fs=$1
  tar_search=$2
  archive_search=$3
  max_file_size=$4
  find $fs -type f -size +$max_file_size -exec ls -lh {} \; |  grep -iE $archive_search | while read large_file
  do
    large_file_array=($(echo $large_file))
    extention=`echo ${large_file_array[8]} | awk -F. '{print $NF}'`
    echo "File extention is $extention"
    #If the file is a file we would tar up then go for it else just move the file...
    if echo ${large_file_array[8]} | grep -iE $tar_search
    then
      echo "Create tgz from file, move off system, and delete file."
      echo "tar -xzvf  ${large_file_array[8]}.tgz ${large_file_array[8]}"
        echo "mv ${large_file_array[8]}.tgz /nfs_storage_place"
        echo "rm ${large_file_array[8]}"
    else
      echo "Move file off system."
      echo "mv ${large_file_array[8]} /nfs_storage_place"
    fi
  done
}

function filling_filesystems {
  min_percent=$1
  result_type=$2
  result_number=5
  if [ "$result_type" == "filesystem" ]
  then
    result_number=0
  fi
  #Feed the results of df ( minus header ) to the variable df_data
  df -hP | grep -v boot | sed -n '1!p' | while read df_data
  do
    #Convert df_data to array
    #Element 3 = Space Available, 4 = Use%, 5 = Mount Point
    df_array=($(echo $df_data))
    #Compare precentage used to the minimum allowed threshold.
    #Strip the % sign from the array.
    if [ "${df_array[4]//%}" -gt "$min_percent" ]
    then
      echo ${df_array[$result_number]}
    fi
  done
}

function grow_lv {
  lv_fs=$1
  min_percent=$2
  grow_percent=$3
  echo $lv_fs
  total_kb=$(df -Pk  | grep $lv_fs  | awk '{print $2}')
  used_percent=$(df -Pk  | grep $lv_fs  | awk '{print $5}' | sed  s/%//g )
  #Calculate filesystem increase required in percentage.
  #This is the difference of the percent used and the min percent
  #plus the grow percent we want to use as a buffer.
  grow_percent=$(($used_percent-$min_percent+grow_percent))
  echo $grow_percent
  #Get the required increase in KB to meet the grow percent required.
  #Use binary calculator for float.
  float_grow_kb=$(echo "$total_kb * 0.01 * $grow_percent" | bc )
  #Convert float to int.
  grow_kb=${float_grow_kb%.*}
  echo "Attempting to grow $fs by $grow_kb KB."
  lvextend -L+"$grow_kb"K $fs
  if [ $? -eq 0 ]
  then
    resize2fs $fs
  else
    echo "Unable to grow FS.  Please add additional storage to the volume group."
  fi
}

#####################################################################################
#Investigate the storage, archive where possible, and increase FS where possible
#####################################################################################

#Attempt to archive files
echo "Searching for filesystems with utilization > $min_percent"
for fs in $(filling_filesystems $min_percent )
do
   echo "  Searching for files to archive in filesystem: $fs."
   archive_files $fs $tar_search $archive_search $max_file_size
done

#Attempt to grow LV
echo "Searching for filesystems that can be grown..."
for fs in $(filling_filesystems $min_percent "filesystem")
do
   echo "  Attempting to grow: $fs."
   grow_lv $fs $min_percent $grow_percent
done
