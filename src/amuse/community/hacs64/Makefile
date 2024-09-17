ifneq (,$(filter-out clean distclean, $(MAKECMDGOALS)))
include support/config.mk
endif


# Detecting dependencies
support/config.mk:
	cd support && ./configure


# Building the code into a static library
CXXFLAGS += $(STOPCOND_CFLAGS) -Isrc -Isrc/ON_neib

LDLIBS += -lm $(STOPCOND_LIBS)

CODELIB = src/libhacs64cpu.a
CODELIB_CUDA = src/libhacs64gpu.a


$(CODELIB):
	$(MAKE) -C src -f ../src/Makefile -j $(CPU_COUNT) cpu CXX=$(MPICXX)

$(CODELIB_CUDA):
	$(MAKE) -C src -f ../src/Makefile -j $(CPU_COUNT) all CXX=$(MPICXX)


# Building the workers
hacs64_worker.h: interface.py
	amusifier --type=h interface.py Hacs64Interface -o $@

hacs64_worker.cc: interface.py
	amusifier --type=c interface.py Hacs64Interface -o $@

hacs64_worker.o: hacs64_worker.cc hacs64_worker.h
	$(MPICXX) -c -o $@ $(CXXFLAGS) -Isrc -Isrc/ON_neib $<

hacs64_worker: hacs64_worker.o interface.o $(CODELIB)
	$(MPICXX) -o $@ $(LDFLAGS) $^ $(LDLIBS)

hacs64_cuda_worker: hacs64_worker.o interface.o $(CODELIB_CUDA)
	$(MPICXX) -o $@ $(LDFLAGS) $(CUDA_LDFLAGS) $^ $(LDLIBS) -lcudart

interface.o: interface.cc hacs64_worker.h
	$(MPICXX) -o $@ -c $(CXXFLAGS) $<


# Which packages contain which workers?
amuse-hacs64_contains: hacs64_worker

amuse-hacs64-cuda_contains: hacs64_cuda_worker


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
	rm -f support/config.mk support/config.log support/config.status
	rm -rf support/autom4te.cache
