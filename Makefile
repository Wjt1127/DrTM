OPT ?= -O2 -g2 -DNDEBUG      # (A) Production use (optimized mode)
#OPT ?= -O2 -g2 -DNDEBUG -funroll-all-loops
#OPT ?= -g2              # (B) Debug mode, w/ full line-level debugging symbols
#OPT ?= -O2 -fno-omit-frame-pointer -g2 -DNDEBUG # (C) Profiling mode: opt, but w/debugging symbols
#-----------------------------------------------

CC=gcc-4.8
CXX=g++-4.8

CHOP=$(strip $(C))

# detect what platform we're building on
$(shell CC=$(CC) CXX=$(CXX) TARGET_OS=$(TARGET_OS) CHOP=$(CHOP)\
    ./build_detect_platform build_config.mk ./)
# this file is generated by the previous line to set build flags and sources
include build_config.mk

CFLAGS += -I. -I./include $(PLATFORM_CCFLAGS) $(OPT)
CXXFLAGS += -I. -I./include $(PLATFORM_CXXFLAGS) $(OPT)  -std=c++0x

LDFLAGS += $(PLATFORM_LDFLAGS)
LIBS += $(PLATFORM_LIBS)

LIBOBJECTS = $(SOURCES:.cc=.o)
MEMENVOBJECTS = $(MEMENV_SOURCES:.cc=.o)

LIBRARY = libleveldb.a
MEMENVLIBRARY = libmemenv.a

default: all

all: $(SHARED) $(LIBRARY)

clean:
	-rm -f $(PROGRAMS) $(BENCHMARKS) $(LIBRARY) $(SHARED) $(MEMENVLIBRARY) */*.o */*/*.o ios-x86/*/*.o ios-arm/*/*.o build_config.mk
	-rm -rf ios-x86/* ios-arm/*

$(LIBRARY): $(LIBOBJECTS)
	rm -f $@
	$(AR) -rs $@ $(LIBOBJECTS)

dbtest: oltp/dbtest.o $(LIBOBJECTS) $(TESTUTIL)
	$(CXX) $(LDFLAGS) oltp/dbtest.o $(LIBOBJECTS) $(TESTUTIL) -o $@ $(LIBS)


