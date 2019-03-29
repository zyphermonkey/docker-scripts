#!/bin/bash
docker_find_files () {
  echo -e "\e[96m  Largest Files (+10M)\e[0m"
  docker exec $1 sh -c '/usr/bin/find / -xdev $2 -path ./proc -prune -o -path ./sys -prune -o -type f -size +10000k -exec du -Shx {} + | sort -rh | head | sed "s/^/  /"'
}

docker_find_directories () {
  #du -hxa / --exclude="/data" --exclude="/dockerlogs" --exclude="/dockerlogs2" --exclude="/dockervarlib" --exclude="/license" --exclude="/opt/splunk/etc" --exclude="/opt/splunk/var" | sort -h -r | head
  echo -e "\e[96m  Largest Directories\e[0m"
  docker exec $1 sh -c 'du -hxa / $2 | sort -rh | head | sed "s/^/  /"'
}

docker_find_subdirectories () {
  #du -Shx /  --exclude="/data" --exclude="/dockerlogs" --exclude="/dockerlogs2" --exclude="/dockervarlib" --exclude="/license" --exclude="/opt/splunk/etc" --exclude="/opt/splunk/var" | sort -rh | head
  echo -e "\e[96m  Largest Directories (excluding subdirectories)\e[0m"
  docker exec $1 sh -c 'du -Shx / $2 | sort -rh | head | sed "s/^/  /"'
}

docker_get_mounts () {
  mounts=$(docker inspect --format='{{range .Mounts}}{{json .Destination}}{{end}}' $1)
  #echo $mounts
  
  #echo $path
}

docker_set_exclude_path () {
  for i in `echo $mounts | tr \" '\n' | grep -v "^$"`; do path="$path -path '.$i' -prune -o "; done
}

docker_set_exclude_dir () {
  for i in `echo $mounts | tr \" '\n' | grep -v "^$"`; do exclude="$exclude --exclude='$i' "; done
  #echo $exclude
}

for container in $(docker ps --format '{{.Names}}' | sort -f)
do 
  echo -e "\e[32;4m$container\e[0m"
  docker_get_mounts "$container"
  docker_set_exclude_path
  docker_set_exclude_dir
  docker_find_files $container $path
  docker_find_directories $container $exclude
  docker_find_subdirectories $container $exclude
done
