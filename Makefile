CC=cc

BIN_DIR=bin

SANDBOX_BIN=$(BIN_DIR)/sandbox
SANDBOX_SRC=src/sandbox/main.c
SANDBOX_OBJ=$(SANDBOX_SRC:.c=.o)

DEPOT_BIN=$(BIN_DIR)/depot
DEPOT_SRC=src/depot/main.c

.PHONY: all
all: $(BIN_DIR) $(DEPOT_BIN) $(SANDBOX_BIN)

-include depends.Mk

$(BIN_DIR):
	mkdir bin

$(DEPOT_BIN): $(DEPOT_SRC)
	$(CC) -o $@ $(DEPOT_SRC)

$(SANDBOX_BIN): $(SANDBOX_OBJ)
	$(CC) -o $@ $<

#src/sandbox/main.c:

src/sandbox/%.o: src/sandbox/%.c
	$(CC) -c -o $@ $<
	@echo "Custom sandbox rule"
	@sh ./depends.sh depends.Mk $<

src/%.o: src/%.c
	$(CC) -c -o $@ $<
	@$(DEPOT_BIN) -o depends.Mk $<

.PHONY: clean
clean:
	rm -f $(SANDBOX_OBJ)
	rm -f $(SANDBOX_BIN)
	rm -f depends.Mk
	rm -f $(DEPOT_BIN)
	rm -rf $(BIN_DIR)
