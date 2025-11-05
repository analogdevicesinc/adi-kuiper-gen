obj-m := adxl355_spi.o

all:
	make -C /usr/src/linux-headers-6.1.0/ M=$(shell pwd) modules

clean:
	make -C /usr/src/linux-headers-6.1.0/ M=$(shell pwd) modules
