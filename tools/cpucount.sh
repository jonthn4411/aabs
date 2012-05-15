core_number=`cat /proc/cpuinfo | grep "cpu cores" | head -1 | awk -F: '{ print $2 }'`
ht=`cat /proc/cpuinfo | grep -w ht`
if [ -z $? ]; then
	ht=1
else
	ht=2
fi
echo $((core_number=core_number*ht))
