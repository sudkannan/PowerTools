      CFLAGS=-g

all: rapl_lib_shared rapl_lib_static power_gadget_static

rapl_lib_shared:
	gcc $(CFLAGS) -fpic -c msr.c cpuid.c rapl.c -lm
	gcc $(CFLAGS) -shared -o librapl.so msr.o cpuid.o rapl.o -lm

rapl_lib_static:
	gcc -Wl, -t $(CFLAGS) -c msr.c cpuid.c rapl.c -lm
	ar rcs librapl.a msr.o cpuid.o rapl.o

power_gadget_static:
	gcc $(CFLAGS) power_gadget.c -I. -L. -o power_gadget ./librapl.a -lm

power_gadget:
	gcc $(CFLAGS) power_gadget.c -I. -L. -lrapl -o -lm power_gadget 

gprof: CFLAGS = -pg
gprof: all
	./power_gadget -e 100 -d 60 >/dev/null 2>&1
	gprof power_gadget > power_gadget.gprof
	rm -f gmon.out
	make clean

clean:
	rm -f power_gadget librapl.so librapl.a msr.o cpuid.o rapl.o 
