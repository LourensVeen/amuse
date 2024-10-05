ifneq (,$(filter-out clean distclean, $(MAKECMDGOALS)))
include support/config.mk
endif


# Detecting dependencies
support/config.mk:
	cd support && ./configure


# TODO: remove
CPU_COUNT := 1


# Building the code into a static library
DEPFLAGS += $(STOPCONDMPI_CFLAGS) $(CUDA_FLAGS)

CFLAGS += -std=c++11 $(DEPFLAGS) -Isrc/octgrav_v1.7d
LDFLAGS += $(CUDA_LDFLAGS)
LDLIBS += $(STOPCONDMPI_LIBS) 

CODELIB = src/octgrav_v1.7d/liboctgrav.a


$(CODELIB):
	$(MAKE) -C src/octgrav_v1.7d -j $(CPU_COUNT) CXX="$(CXX)" CUDA_TK="$(CUDA_TK)" NVCC="$(NVCC)"


# Building the workers
octgrav_worker.h: interface.py
	amusifier --type=h interface.py OctgravInterface -o $@

octgrav_worker.cc: interface.py
	amusifier --type=c interface.py OctgravInterface -o $@

octgrav_worker.o: octgrav_worker.cc octgrav_worker.h
	$(MPICXX) -c -o $@ $(CFLAGS) $<

octgrav_cuda_worker: interface.o integrator.o octgrav_worker.o $(CODELIB)
	$(MPICXX) -o $@ $(LDFLAGS) $^ $(LDLIBS)

%.o: %.cc
	$(MPICXX) -o $@ -c $(CFLAGS) $<

%.o: %.cpp
	$(MPICXX) -o $@ -c $(CFLAGS) $<

interface.o: octgrav_worker.h


# Which packages contain which workers?
amuse-octgrav-cuda_contains: octgrav_cuda_worker


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
	$(MAKE) -C src/octgrav_v1.7d clean
	rm -rf *.o *worker*

.PHONY: distclean
distclean: clean
	rm -f support/config.mk support/config.log support/config.status
	rm -rf support/autom4te.cache
