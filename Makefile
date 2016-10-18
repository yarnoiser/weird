.PHONY: clean

SERVER_SRC=	shared/coroutine.scm \
                shared/debug.scm \
		shared/highlevel-io.scm \
		shared/lowlevel-io.scm \
		shared/terminal.scm \
		server/client.scm \
		server/event.scm \
		server/init.scm \
		server/main.scm \
		server/remote.scm \
                server/serializer.scm \
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

