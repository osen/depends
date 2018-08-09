DEPOT_OBJ= \
  src/depot/main.o

DEPOT_BIN=$(BIN_DIR)/depot

$(DEPOT_BIN): $(DEPOT_OBJ)
	$(CC) -o $@ $(LFLAGS) $<

src/%.o: src/%.c
	$(CC) -c -o $@ $(CFLAGS) $<
	@sh ./depends.sh depends.Mk $<
