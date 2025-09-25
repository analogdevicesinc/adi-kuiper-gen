#!/bin/bash

declare -A morse
morse[0]='- - - - -'
morse[1]='. - - - -'
morse[2]='. . - - -'
morse[3]='. . . - -'
morse[4]='. . . . -'
morse[5]='. . . . .'
morse[6]='- . . . .'
morse[7]='- - . . .'
morse[8]='- - - . .'
morse[9]='- - - - .'
morse[A]='. -'
morse[B]='- . . .'
morse[C]='- . - .'
morse[D]='- . .'
morse[E]='.'
morse[F]='. . - .'
morse[G]='- - .'
morse[H]='. . . .'
morse[I]='. .'
morse[J]='. - - -'
morse[K]='- . -'
morse[L]='. - . .'
morse[M]='- -'
morse[N]='- .'
morse[O]='- - -'
morse[P]='. - - .'
morse[Q]='- - . -'
morse[R]='. - .'
morse[S]='. . .'
morse[T]='-'
morse[U]='. . -'
morse[V]='. . . -'
morse[W]='. - -'
morse[X]='- . . -'
morse[Y]='- . - -'
morse[Z]='- - . .'

TIME_DIT=0.2

MSG=$1

for (( i=0; i<${#MSG}; i++ )); do
	C=${MSG:$i:1}
	M=${morse[$C]}

	for q in $M; do
		if [ $q = '.' ]; then
			gpioset 0 22=1
			sleep $TIME_DIT
			gpioset 0 22=0
			sleep $TIME_DIT
		elif [ $q = '-' ]; then
			gpioset 0 22=1
			sleep $TIME_DIT
			sleep $TIME_DIT
			sleep $TIME_DIT
			gpioset 0 22=0
			sleep $TIME_DIT
		fi
	done

	sleep $TIME_DIT
	sleep $TIME_DIT
done

