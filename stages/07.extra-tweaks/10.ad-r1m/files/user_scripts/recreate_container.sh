
sudo nmcli radio wifi on
sleep 3

I=docker.cloudsmith.io/adi/adrd-common/ad-r1m:rpi5
docker pull $I

