
sudo nmcli radio wifi on
sleep 3

if [ $(id -u) == 0 ]; then
	echo "Warning: Running this as root will not find the credentials added with \`docker login\`"
fi

I=docker.cloudsmith.io/adi/adrd-common/ad-r1m:rpi5
docker pull $I
docker tag $I working

