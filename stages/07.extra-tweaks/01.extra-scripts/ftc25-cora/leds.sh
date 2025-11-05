#!/bin/bash

led_on() {
	echo 1 >> led${1}_${2}/brightness
}

led_off() {
	echo 0 >> led${1}_${2}/brightness
}

set_trigger() {
	echo ${3} >> led${1}_${2}/trigger
}

# Check if the script is run as root
if [ "$(id -u)" != "0" ] ; then
	echo "This script must be run as root"
	exit 1
fi

cd /sys/class/leds

# switch off both LEDs
led_off 0 blue
led_off 0 red
led_off 0 green
led_off 1 blue
led_off 1 red
led_off 1 green

# start LED animation

# 0-1s: both red
led_on 0 red
led_on 1 red
sleep 1

# 1-2s: both green
led_off 0 red
led_off 1 red
led_on 0 green
led_on 1 green
sleep 1

# 2-3s: both blue
led_off 0 green
led_off 1 green
led_on 0 blue
led_on 1 blue
sleep 1

# 3-4s: both white
led_on 0 red
led_on 1 red
led_on 0 green
led_on 1 green
sleep 1

# 4-5s: LED 1 purple, LED 2 off
led_off 1 blue
led_off 1 red
led_off 1 green
led_off 0 green
sleep 1

# 5-6 s: LED 1 off, LED 2 cyan
led_off 0 blue
led_off 0 red
led_on 1 green
led_on 1 blue
sleep 1

# 6-7 s: LED 1 cyan, LED 2 off
led_off 1 blue
led_off 1 green
led_on 0 green
led_on 0 blue
sleep 1

# 7-8 s: LED 1 off, LED 2 purple
led_off 0 blue
led_off 0 green
led_on 1 blue
led_on 1 red
sleep 1

# 8-9s: both yellow
led_off 1 blue
led_on 0 red
led_on 0 green
led_on 1 red
led_on 1 green
sleep 1

# 9-10s: both off
led_off 0 red
led_off 0 green
led_off 1 red
led_off 1 green
sleep 1

# 10-11s: both yellow
led_on 0 red
led_on 0 green
led_on 1 red
led_on 1 green
sleep 1

# 11-12s: both off
led_off 0 red
led_off 0 green
led_off 1 red
led_off 1 green
sleep 1

# 12-13s: LED 1 purple, LED 2 off
led_on 0 red
led_on 0 blue
sleep 1

# 13-14s: LED 1 cyan, LED 2 purple
led_off 0 red
led_on 0 green
led_on 1 red
led_on 1 blue
sleep 1

# 14-15s: LED 1 white, LED 2 cyan
led_off 1 red
led_on 0 red
led_on 1 green
sleep 1

# 15-16s: LED 1 off, LED 2 white
led_off 0 blue
led_off 0 green
led_off 0 red
led_on 1 blue
led_on 1 green
led_on 1 red
sleep 1

# 16-17s: LED 1 purple, LED 2 cyan
led_off 1 red
led_on 0 blue
led_on 0 red
sleep 1

# 17-18s: LED 1 cyan, LED 2 purple
led_off 0 red
led_off 1 green
led_on 0 green
led_on 1 red
sleep 1

# 18-19s: LED 1 white, LED 2 yellow
led_off 1 blue
led_on 0 red
led_on 1 green
sleep 1

# 19-20s: LED 1 yellow, LED 2 white
led_off 0 blue
led_on 1 blue
sleep 1

# switch off both LEDs
led_off 0 blue
led_off 0 red
led_off 0 green
led_off 1 blue
led_off 1 red
led_off 1 green
