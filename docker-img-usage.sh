for i in `docker ps --format '{{.Names}}'`;do echo $i;done

#get docker mounts
docker inspect --format='{{range .Mounts}}{{json .Destination}}{{end}}' splunk | tr \" '\n' | grep -v "^$"

#find largest directories
du -hxa / --exclude="/data" --exclude="/dockerlogs" --exclude="/dockerlogs2" --exclude="/dockervarlib" --exclude="/license" --exclude="/opt/splunk/etc" --exclude="/opt/splunk/var" | sort -h -r | head

#find largest directory excluding subdirectories (-S)
du -Shx /  --exclude="/data" --exclude="/dockerlogs" --exclude="/dockerlogs2" --exclude="/dockervarlib" --exclude="/license" --exclude="/opt/splunk/etc" --exclude="/opt/splunk/var" | sort -rh | head

mounts=`docker inspect --format='{{range .Mounts}}{{json .Destination}}{{end}}' splunk`
docker exec -it -e mounts=$mounts splunk bash
for i in `echo $mounts | tr \" '\n' | grep -v "^$"`; do echo $i; done


find . -xdev \
-path './dockerlogs' -prune -o \
-path './dockerlogs2' -prune -o \
-path './dockervarlib' -prune -o \
-path './proc' -prune -o \
-path './sys' -prune -o \
-path './opt/splunk/etc' -prune -o \
-path './opt/splunk/var' -prune -o \
-path './license' -prune -o \
-path './data' -prune -o \
-type f \
-exec du -Shx {} + \
| sort -rh \
| head -n 20

find . -xdev \
-path './config' -prune -o \
-path './proc' -prune -o \
-path './sys' -prune -o \
-type f \
-size 10000k \
-exec du -Shx {} + \
| sort -rh \
| head -n 20
