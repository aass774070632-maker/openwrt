.PHONY: all clean

CFLAGS ?= -O2 -s -Wall
LDFLAGS ?=

all: np-monitor

np-monitor: np-monitor.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

clean:
	rm -f np-monitor
