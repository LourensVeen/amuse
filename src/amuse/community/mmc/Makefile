ifneq (,$(filter-out clean distclean, $(MAKECMDGOALS)))
include support/config.mk
endif


# Detecting dependencies
support/config.mk:
	cd support && ./configure


# Building the code into a static library
DEPFLAGS += $(AMUSE_MPI_CFLAGS)
DEPFLAGS += $(FORSOCKETS_CFLAGS)

FFLAGS += $(DEPFLAGS)

LDFLAGS +=

LDLIBS += -lm $(AMUSE_MPI_LIBS)
LDLIBS += $(FORSOCKETS_LIBS)


CODELIB = src/libmmc.a

$(CODELIB): | src
	$(MAKE) -C src -j $(CPU_COUNT)
	$(MAKE) -C amuselib -j $(CPU_COUNT) support_worker


# Building the workers
worker_code.f90: interface.py
	amusifier --type=f90 interface.py mmcInterface -o $@

worker_code.o: worker_code.f90
	$(MPIFC) -c $(FFLAGS) $<

interface.f90 src/amuse_interface2.f: makeinterface.py
	python makeinterface.py

interface.o: interface.f90
	$(MPIFC) -c -o $@ $(FFLAGS) -Isrc $<

mmc_worker: interface.o worker_code.o $(CODELIB)
	$(MPIFC) -o $@ $(LDFLAGS) $^ $(LDLIBS)


# Which packages contain which workers?
amuse-mmc_contains: mmc_worker


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
	$(MAKE) -C amuselib distclean
	rm -rf *.o *worker* mmc.mod

.PHONY: distclean
distclean: clean
	#-$(MAKE) -C src clean
	#-$(MAKE) -C amuselib distclean
	rm -f support/config.mk support/config.log support/config.status
	rm -rf support/autom4te.cache

