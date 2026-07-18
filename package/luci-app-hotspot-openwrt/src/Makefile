all: mikrotik_api

mikrotik_api: mikrotik_api.c md5.c
	$(CC) $(CFLAGS) -o mikrotik_api mikrotik_api.c md5.c $(LDFLAGS)

clean:
	rm -f mikrotik_api *.o
