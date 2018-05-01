while : ;do
    char=`
        stty cbreak -echo
        dd if=/dev/tty bs=1 count=1 2>/dev/null
        stty -cbreak echo
    `
    if [ "$char" =  "" ];then
        break
    fi
    password="$password$char"
    echo -n "*"
done
