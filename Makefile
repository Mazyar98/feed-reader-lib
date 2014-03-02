CPP = g++-4.8
EXT_PATH=$(realpath external)

LOCAL_PATH = $(EXT_PATH)/local
CXXFLAGS = -std=c++11 -DZI_USE_OPENMP -fopenmp -Wall
CXXOPT = -O2 -march=native -mtune=native -funroll-loops -DNDEBUG --fast-math
CXXDEBUG = -g -gstabs+
ZI = -I$(LOCAL_PATH)/zi_lib
LOCALTOOLS = -I$(LOCAL_PATH)
SRC = -I./src/

BOOST = -isystem$(LOCAL_PATH)/boost/include -L$(LOCAL_PATH)/boost/lib
LD_FLAGS = -Wl,-rpath,$(LOCAL_PATH)/boost/lib -L$(LOCAL_PATH)/boost/lib  \
	-lpthread -lboost_program_options -lboost_system -lboost_thread \
	-lboost_filesystem -lboost_iostreams -lboost_regex -lboost_serialization
LD_FLAGS += -lcurl
LD_FLAGS += -lxalan-c -lxerces-c

COMLIBS = $(LOCALTOOLS) $(BOOST) $(ZI) $(CPPCMS) $(SRC)
COMMON_OPT = $(CXXFLAGS) $(CXXOPT) $(COMLIBS)

# from http://stackoverflow.com/a/18258352
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

OBJ_DIR := build
OBJ := $(addprefix $(OBJ_DIR)/, $(patsubst %.cpp, %.o, $(call rwildcard, src/, *.cpp))) \
	$(addprefix $(OBJ_DIR)/, $(patsubst %.cpp, %.o, $(call rwildcard, examples/, *.cpp)))
HEADERS = $(call rwildcard, src/, *.hpp)

BIN := bin/test

.PHONY: all
all: $(OBJ_DIR) $(BIN)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)
	mkdir -p bin

$(OBJ_DIR)/%.o: %.cpp $(HEADERS)
	@mkdir -p $(OBJ_DIR)/$(shell dirname $<)
	$(CPP) -fpermissive $(COMMON_OPT) -c -o $@ $<

$(BIN): $(OBJ)
	$(CPP) -o $@ $^ $(LD_FLAGS)

.PHONY : run
run:
	@echo "******************** running ********************"
	./a.out
	@echo "******************** done    ********************"

.PHONY: clean
clean:
	@rm -f $(BIN)
	@rm -rf $(OBJ_DIR)

.PHONY: redo
redo: clean all
