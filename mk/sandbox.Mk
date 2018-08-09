SANDBOX_OBJ= \
  src/sandbox/main.o \
  src/sandbox/Test.o

SANDBOX_BIN=$(BIN_DIR)/sandbox

$(SANDBOX_BIN): $(SANDBOX_OBJ)
	$(CC) -o $@ $(LFLAGS) $<

src/sandbox/%.o: src/sandbox/%.c
	$(CC) -c -o $@ $(CFLAGS) $<
	@sh ./depends.sh depends.Mk $<
