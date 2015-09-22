
export AW_MAKE_FILE=$(AW_MAKE_PATH)/ext.mk

define make-simple
	$(MAKE) -C $< `test -e $</requires.mk && echo -f requires.mk` \
		-f $(AW_MAKE_PATH)/cc.mk -f $(AW_MAKE_PATH)/ar.mk \
		$@ && \
	( test -L $@ || ln -s $</$@ $@ )
endef

define cmake
	test -d $(SUBDIR)/build$(EXESUF) || \
		mkdir $(SUBDIR)/build$(EXESUF) && \
		cd $(SUBDIR)/build$(EXESUF) && \
		cmake ..
endef

#### aw-* ####

libaw-%$(EXESUF)$(LIBSUF): aw-% recurse
	$(make-simple)

.PRECIOUS: aw-%
aw-%:
ifneq ($(AW_CLONE_PATH),)
	test -d $@ || git clone $(AW_CLONE_PATH)/$@
else
	test -d $@ || git clone git@github.com:afterwise/$@.git
endif

#### bullet3 ####

libBulletCollision$(EXESUF)$(LIBSUF): bullet3/build$(EXESUF)/src/BulletCollision/libBulletCollision$(LIBSUF)
	test -L $@ || ln -s $^ $@

bullet3/build$(EXESUF)/src/BulletCollision/libBulletCollision$(LIBSUF): bullet3/build$(EXESUF)/Makefile recurse
	$(MAKE) -C bullet3/build$(EXESUF) BulletCollision

bullet3/build$(EXESUF)/Makefile: bullet3/CMakeLists.txt

.PRECIOUS: bullet3/%
bullet3/%: SUBDIR = bullet3
bullet3/%:
	( test -d bullet3 || git clone git@github.com:bulletphysics/bullet3.git ) && \
	( $(cmake) )

#### curl ####

libcurl$(EXESUF)$(LIBSUF): curl/build$(EXESUF)/lib/libcurl$(LIBSUF)
	test -L $@ || ln -s $^ $@

curl/build$(EXESUF)/lib/libcurl$(LIBSUF): curl/build$(EXESUF)/Makefile recurse
	$(MAKE) -C curl/build$(EXESUF) libcurl

.PRECIOUS: curl/%
curl/%: SUBDIR = curl
curl/%:
	( test -d curl || git clone git@github.com:bagder/curl.git ) && \
	( $(cmake) -DCURL_STATICLIB=ON )

#### glew ####

libglew$(EXESUF)$(LIBSUF): glew/lib/libGLEW$(LIBSUF)
	ln -s $^ $@

glew/lib/libGLEW$(LIBSUF): glew/Makefile
	$(MAKE) -C glew

.PRECIOUS: glew/%
glew/%:
	( test -d glew || git clone https://github.com/nigels-com/glew.git ) && \
	$(MAKE) -C glew/auto

#### glfw3 ####

libglfw3$(EXESUF)$(LIBSUF): glfw/build$(EXESUF)/src/libglfw3$(LIBSUF)
	test -L $@ || ln -s $^ $@

glfw/build$(EXESUF)/src/libglfw3$(LIBSUF): glfw/build$(EXESUF)/Makefile recurse
	$(MAKE) -C glfw/build$(EXESUF) glfw

.PRECIOUS: glfw/%
glfw/%: SUBDIR = glfw
glfw/%:
	( test -d glfw || git clone git@github.com:glfw/glfw.git ) && \
	( $(cmake) )

#### imgui ####

libimgui$(EXESUF)$(LIBSUF): imgui aw-debug recurse
	CFLAGS='-Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -include aw-debug.h -DIM_ASSERT=check' \
	$(make-simple)

.PRECIOUS: imgui
imgui:
	( test -d imgui || git clone git@github.com:ocornut/imgui.git ) && \
	echo "REQUIRES = aw-debug" > imgui/requires.mk

#### llvm ####

libLLVMMCJIT$(EXESUF)$(LIBSUF): llvm/build$(EXESUF)/Release+Asserts/lib/libLLVMMCJIT$(LIBSUF)
	test -L $@ || ln -s $^ $@

llvm/build$(EXESUF)/Release+Asserts/lib/libLLVMMCJIT$(LIBSUF): llvm
	cd llvm/build$(EXESUF) && $(MAKE) && \
	touch -c $@

llvm: llvm-current.tar.xz
	tar -xvf llvm-current.tar.xz && ln -s llvm-*.src llvm && \
	mkdir llvm/build$(EXESUF) && cd llvm/build$(EXESUF) && ../configure && \
	touch -c $@

llvm-current.tar.xz: llvm.version
	curl '-#' -o llvm-current.tar.xz "http://llvm.org/releases/`cat llvm.version`"

llvm.version:
	curl "-#" http://llvm.org/releases/download.html | grep -oE '(\d\.?)+\/llvm-(\d\.?)+src.tar.xz' | head -n1 > llvm.version

#### miniz ####

.PRECIOUS: miniz
miniz:
	test -d miniz || \
	( svn checkout http://miniz.googlecode.com/svn/trunk miniz && \
	find miniz -depth 1 -type f -not -name 'miniz.c' -exec ${RM} {} \; )

#### murmurhash3 ####

.PRECIOUS: murmurhash3
murmurhash3:
	test -d murmurhash3 || \
	( svn checkout http://smhasher.googlecode.com/svn/trunk/ murmurhash3 && \
	find murmurhash3 -type f -not -name 'MurmurHash3.*' | xargs $(RM) && \
	sed 's/^inline/static inline/' murmurhash3/MurmurHash3.cpp > murmurhash3/MurmurHash3.c && \
	$(RM) murmurhash3/MurmurHash3.cpp )

#### nanovg ####

libnanovg$(EXESUF)$(LIBSUF): nanovg/src recurse
	CFLAGS='-Wno-self-assign -Wno-sign-compare -Wno-missing-field-initializers' \
	$(make-simple)

.PRECIOUS: nanovg/%
nanovg/%:
	test -d nanovg || git clone git@github.com:memononen/nanovg.git

#### shewchuk_predicates ####

SHEWCHUK_PREDICATES_URL := http://www.cs.cmu.edu/afs/cs/project/quake/public/code/predicates.c

.PRECIOUS: shewchuk_predicates
shewchuk_predicates:
	mkdir -p $@ && \
	curl '-#' $(SHEWCHUK_PREDICATES_URL) -o $@/shewchuk_predicates.c

.PRECIOUS: stb
stb:
	test -d stb || \
	git clone git@github.com:nothings/stb.git

#### texture-atlas ####

.PRECIOUS: texture-atlas
texture-atlas:
	test -d texture-atlas || \
	svn checkout http://texture-atlas.googlecode.com/svn/trunk/ texture-atlas

#### tritri ####

TRITRI_URL := http://fileadmin.cs.lth.se/cs/Personal/Tomas_Akenine-Moller/code/opttritri.txt

.PRECIOUS: tritri
tritri:
	mkdir -p $@ && \
	curl '-#' $(TRITRI_URL) -o $@/tritri.c && \
	sed -ixxx 's/(float(fabs(x)))/(fabsf(x))/' $@/tritri.c && \
	$(RM) $@/tritri.cxxx

#### *.* ####

lib%$(EXESUF)$(LIBSUF): % recurse
	$(make-simple)

########

.PHONY: clean
clean:
	find . -type l \( -name '*$(LIBSUF)' \) \
		-exec $(RM) {} \;
	find . -type d \( -name 'aw-*' -or -name 'murmurhash3' -or -name 'shewchuk_predicates' -or -name 'tritri' \) \
		-exec $(MAKE) -C {} -f $(AW_MAKE_PATH)/rm.mk \;
	find . -type d \( -name 'bullet3' -or -name 'nanovg' \) \
		-exec $(MAKE) -C {}/src -f $(AW_MAKE_PATH)/rm.mk \;
	find . -type d \( -name 'curl' -or -name 'glfw' \) \
		-exec $(RM) -r {}/build$(EXESUF) \;
	find . -type d \( -name 'glew' \) \
		-exec $(MAKE) -C {} clean \;
	test ! -L llvm || \
		( cd llvm/build$(EXESUF) && $(MAKE) clean )

.PHONY: distclean
distclean:
	find -d . -depth 1 -type d \( -not -name contrib \) \
		-exec $(RM) -r {} \;
	$(RM) llvm llvm.version llvm-current.tar.xz

.PHONY: recurse
recurse:
	@true

