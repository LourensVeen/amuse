ifneq (,$(filter-out clean distclean, $(MAKECMDGOALS)))
include support/config.mk
endif


# Detecting dependencies
support/config.mk:
	cd support && ./configure


# Building the code into a static library
DEPFLAGS += $(OPENMP_CXXFLAGS)

DEPFLAGS += $(GSL_FLAGS)
DEPFLAGS += $(HDF5_CFLAGS)

CFLAGS += $(DEPFLAGS)

LDLIBS += $(GSL_LIBS)
LDLIBS += $(HDF5_LIBS)


QHULL_PATH = src/plugins/qhull-2012.1
LDLIBS += -L$(QHULL_PATH)/lib -lqhullstatic

HEALPIX_PATH = src/plugins/HEALPix
LDLIBS += -L$(HEALPIX_PATH)/lib -lhealpix_cxx


CODEOBJS := amuse_interface.o SimpleX.o Structs.o rates.o Common.o h5w_serial.o
CODEOBJS += keyValue.o tree_structures.o hilbert.o
CODEOBJS := $(patsubst %, src/obj/%, $(CODEOBJS))

$(CODEOBJS) &:
	$(MAKE) -C src -j $(CPU_COUNT) amuse CC="$(CC) $(CFLAGS)" CXX="$(CXX) $(CXXFLAGS)"

# Note that there is an unfinished implementation of an OpenGL worker in
# interface.py. The original build system had some commented-out definitions
# for building it, but those relied on an amuse_interface_gl.cpp that does not
# exist. See the git history if you pick this up in the future.


# Building the workers
simplex_worker.h: interface.py
	amusifier --type=h interface.py SimpleXInterface -o $@

simplex_worker.cc: interface.py
	amusifier --type=c interface.py SimpleXInterface -o $@

simplex_worker.o: simplex_worker.cc simplex_worker.h
	$(MPICXX) -c -o $@ $(CFLAGS) $<

simplex_worker: simplex_worker.o $(CODEOBJS)
	$(MPICXX) -o $@ $(LDFLAGS) $^ $(LDLIBS)


# Which packages contain which workers?
amuse-simplex_contains: simplex_worker


# Building and installing packages
develop-%: %_contains
	support/shared/uninstall.sh $*
	python -m pip install -e packages/$*

install-%: %_contains
	support/shared/uninstall.sh $*
	python -m pip install packages/$*

package-%: %_contains
	python3 -m pip install -vv --no-cache-dir --no-deps --no-build-isolation --prefix ${PREFIX} packages/$*

test-%:
	cd packages/$* && pytest


# Cleaning up
.PHONY: clean
clean:
	$(MAKE) -C src clean
	rm -rf *.o *worker*

.PHONY: distclean
distclean: clean
	$(MAKE) -C src veryclean
	rm -f support/config.mk support/config.log support/config.status
	rm -rf support/autom4te.cache
