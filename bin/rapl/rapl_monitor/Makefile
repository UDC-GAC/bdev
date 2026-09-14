CC = gcc
CFLAGS = -O3 -Wall
LFLAGS = 
PAPI_INCLUDE = ${PAPI_HOME}/src
PAPI_LIBRARY = ${PAPI_HOME}/src/libpapi.a

all:	rapl_monitor

rapl_monitor:	rapl_monitor.o
	$(CC) $(LFLAGS) -o rapl_monitor rapl_monitor.o $(PAPI_LIBRARY)

rapl_monitor.o:	rapl_monitor.c
	$(CC) $(CFLAGS) -I$(PAPI_INCLUDE) -c rapl_monitor.c

clean:	
	rm -f *~ *.o rapl_monitor
