ifneq (,$(filter-out clean distclean, $(MAKECMDGOALS)))
include support/config.mk
endif


# Detecting dependencies
support/config.mk:
	cd support && ./configure


# Downloading the code
BONSAI_VERSION := 581fa8e70501ce85660c7eac0d61c0e5c5bece4a

src:
	mkdir -p src

src/bonsai.tar.gz: | src
	$(DOWNLOAD) https://github.com/treecode/Bonsai/archive/$(BONSAI_VERSION).tar.gz >$@

src/bonsai: | src/bonsai.tar.gz
	cd src && tar xf bonsai.tar.gz
	rm -rf src/bonsai
	mv src/Bonsai-$(BONSAI_VERSION) src/bonsai
	cd src && patch -p0 <../bonsai_build.patch


# Building the code into a static library
CFLAGS += $(STOPCONDMPI_CFLAGS) $(OPENMP_CXXFLAGS) $(CUDA_FLAGS)
LDFLAGS += $(CUDA_LDFLAGS)
LDLIBS += $(STOPCONDMPI_LIBS) -lcuda -lcudart

CODELIB = src/bonsai/build/libbonsai_amuse.a

$(CODELIB): | src/bonsai
	cd src/bonsai && cmake -DUSE_MPI=0 -DUSE_MPIMT=0 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DUSE_THRUST=1 -DUSE_CUB=0 -B build -S runtime
	cd src/bonsai/build && make -j $(CPU_COUNT) bonsai_amuse


# Building the workers

bonsai_cuda_worker.h: interface.py
	amusifier --type=h -i amuse.community.interface.stopping_conditions.StoppingConditionInterface interface.py Bonsai2Interface -o $@

bonsai_cuda_worker.cc: interface.py
	amusifier --type=c interface.py Bonsai2Interface -o $@

bonsai_cuda_worker.o: bonsai_cuda_worker.cc bonsai_cuda_worker.h
	$(MPICXX) -c -o $@ $(CFLAGS) $<

bonsai_cuda_worker: libraryInterface.o bonsai_cuda_worker.o $(CODELIB)
	$(MPICXX) -o $@ $(LDFLAGS) $^ $(LDLIBS)

libraryInterface.o: libraryInterface.cu bonsai_cuda_worker.h | src/bonsai
	$(NVCC) -c -Xcompiler "$(CFLAGS)" $<


# Which packages contain which workers?
amuse-bonsai2-cuda_contains: bonsai_cuda_worker


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
	cd packages/$* && pytest -v


# Cleaning up
.PHONY: clean
clean:
	rm -rf src/bonsai/build
	rm -rf *.o *worker*

.PHONY: distclean
distclean: clean
	rm -f support/config.mk support/config.log support/config.status
	rm -rf support/autom4te.cache
	rm -rf src
