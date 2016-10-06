.PHONY: clean

SERVER_SRC=	shared/debug.scm \
		server/client.scm \
		server/event.scm \
		server/lowlevel-io.scm \
		server/highlevel-io.scm \
		server/coroutine.scm \
		server/main.scm \
		server/remote.scm \
                server/serialize.scm \
		server/user.scm \

CLIENT_SRC=	shared/debug.scm \
		client/main.scm \


all: weird-client weird-server

weird-client: $(CLIENT_SRC)
	csc -D debug -d3 $^ -o $@

weird-server: $(SERVER_SRC)
	csc -D debug -d3 $^ -o $@

clean:
	$(RM) weird-client weird-server *.o *.c \
	      shared/*.o shared/*.c \
	      client/*.o client/*.c \
	      server/*.o server/*.c \
	      server/data/users/*.scm \
	      server/data/*.pem \

