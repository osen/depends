CC=cc
CFLAGS=-Isrc
LFLAGS=-g

BIN_DIR=bin

SANDBOX_BIN=$(BIN_DIR)/sandbox

SANDBOX_SRC= \
  src/sandbox/main.c \
  src/sandbox/Test.c

SANDBOX_OBJ=$(SANDBOX_SRC:.c=.o)

.PHONY: all
all: $(BIN_DIR) $(SANDBOX_BIN)

-include depends.Mk

$(BIN_DIR):
	mkdir bin

$(SANDBOX_BIN): $(SANDBOX_OBJ)
	$(CC) -o $@ $(LFLAGS) $<

src/%.o: src/%.c
	$(CC) -c -o $@ $(CFLAGS) $<
	@sh ./depends.sh depends.Mk $<

.PHONY: clean
clean:
	rm -f $(SANDBOX_OBJ)
	rm -f $(SANDBOX_BIN)
	rm -f depends.Mk
	rm -rf $(BIN_DIR)
