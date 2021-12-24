#!/bin/bash
docker_find_files () {
  #echo -e "\e[96m  Largest Files (+200M)\e[0m"
  docker_find_files_results=$(docker exec $1 sh -c '/usr/bin/find / -xdev $2 -path ./proc -prune -o -path ./sys -prune -o -type f -size +200000k -exec du -shx {} + | sort -r | head | sed "s/^/    /"')
}

docker_find_directories () {
  #echo -e "\e[96m  Largest Directories (+200M)\e[0m"
  docker_find_directories_results=$(docker exec $1 sh -c 'du -hxa / $2 | sort -r | head | sed "s/^/    /"')
}

docker_find_subdirectories () {
  #echo -e "\e[96m  Largest Directories (+200M) (excluding subdirectories)\e[0m"
  docker_find_subdirectories_results=$(docker exec $1 sh -c 'du -shx / $2 | sort -r | head | sed "s/^/    /"')
}

docker_get_mounts () {
  mounts=$(docker inspect --format='{{range .Mounts}}{{json .Destination}}{{end}}' $1)
  #echo $mounts
}

docker_set_exclude_path () {
  for i in `echo $mounts | tr \" '\n' | grep -v "^$"`; do path="$path -path '.$i' -prune -o "; done
}

docker_set_exclude_dir () {
  for i in `echo $mounts | tr \" '\n' | grep -v "^$"`; do exclude="$exclude --exclude='$i' "; done
  #echo $exclude
}

results () {
  if [[ ! -z $docker_find_files_results || ! -z $docker_find_directories_results || ! -z $docker_find_subdirectories_results ]]; then
    echo -e "\e[$1\e]"
  fi 
  
  if [[ ! -z $docker_find_files_results ]]; then
    echo -e "\e[Largest Files \e]"
	echo $docker_find_files_results
  fi 

  if [[ ! -z $docker_find_directories_results ]]; then
    echo -e "\e[Largest Directories \e]"
	echo $docker_find_directories_results
  fi 

  if [[ ! -z $docker_find_subdirectories_results ]]; then
    echo -e "\e[Largest Directories (excluding subdirectories)\e]"
	echo $docker_find_subdirectories_results
  fi

  if [[ ! -z $docker_find_files_results || ! -z $docker_find_directories_results || ! -z $docker_find_subdirectories_results ]]; then
    echo ""
  fi 
  
}

# Uncomment if you need, but leaving it commented out since it adds significant delay to the script. 
# docker system df -v
for container in $(docker ps --format '{{.Names}}' | sort -f)
do 
  #echo -e "\e[32;4m$container\e[0m"
  docker_get_mounts "$container"
  docker_set_exclude_path
  docker_set_exclude_dir
  docker_find_files $container $path
  #docker_find_directories $container $exclude  #This needs works. Currently not useful
  docker_find_subdirectories $container $exclude
  results $container $docker_find_files_results $docker_find_directories_results $docker_find_subdirectories_results
done
