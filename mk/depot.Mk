DEPOT_OBJ= \
  src/depot/main.o

DEPOT_BIN=$(BIN_DIR)/depot

$(DEPOT_BIN): $(DEPOT_OBJ)
	$(CXX) -o $@ $(LFLAGS) $<

src/%.o: src/%.cpp
	$(CXX) -c -o $@ $(CFLAGS) $(CXXFLAGS) $<
	@sh ./depends.sh depends.Mk $<
