all: dhcp-sentinel

dhcp-sentinel: dhcp-sentinel.o
	$(CC) $(LDFLAGS) -o $@ $^

dhcp-sentinel.o: dhcp-sentinel.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o dhcp-sentinel
