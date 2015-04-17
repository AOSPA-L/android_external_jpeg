ifeq (true, $(USE_LIBJPEG_TURBO))
# Makefile for libjpeg-turbo

ifneq ($(TARGET_SIMULATOR),true)

LOCAL_PATH := $(my-dir)

##################################################
###                simd                        ###
##################################################

include $(CLEAR_VARS)

# Check Target Arch
ifeq ($(TARGET_ARCH_VARIANT),armv7-a-neon)

USE_SIMD := true

# enable armv7 idct neon assembly
LOCAL_CFLAGS += -DANDROID_JPEG_USE_VENUM
LOCAL_CFLAGS += -march=armv7-a -mfpu=neon

LOCAL_SRC_FILES_arm := simd/jsimd_arm_neon.S \
                   simd/jsimd_arm.c

LOCAL_C_INCLUDES +=  $(LOCAL_PATH)/simd

LOCAL_MODULE_TAGS := debug

LOCAL_MODULE := libsimd

include $(BUILD_STATIC_LIBRARY)
endif #ARM

ifeq ($(TARGET_ARCH_VARIANT),armv8-a)

USE_SIMD := true

# enable armv7 idct neon assembly
LOCAL_CFLAGS += -DANDROID_JPEG_USE_VENUM
LOCAL_CFLAGS += -march=armv8-a

LOCAL_SRC_FILES_arm64 := simd/jsimd_arm64_neon.S \
                   simd/jsimd_arm64.c

LOCAL_C_INCLUDES +=  $(LOCAL_PATH)/simd

LOCAL_MODULE_TAGS := debug

LOCAL_MODULE := libsimd

include $(BUILD_STATIC_LIBRARY)
endif #ARM64


######################################################
###                libjpeg.so                       ##
######################################################

include $(CLEAR_VARS)

# From autoconf-generated Makefile
libjpeg_SOURCES_DIST =  jcapimin.c jcapistd.c jccoefct.c jccolor.c \
        jcdctmgr.c jchuff.c jcinit.c jcmainct.c jcmarker.c jcmaster.c \
        jcomapi.c jcparam.c jcphuff.c jcprepct.c jcsample.c jctrans.c \
        jdapimin.c jdapistd.c jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c \
        jddctmgr.c jdhuff.c jdinput.c jdmainct.c jdmarker.c jdmaster.c \
        jdmerge.c jdphuff.c jdpostct.c jdsample.c jdtrans.c jerror.c \
        jfdctflt.c jfdctfst.c jfdctint.c jidctflt.c jidctfst.c jidctint.c \
        jidctred.c jquant1.c jquant2.c jutils.c jmemmgr.c jmemnobs.c \
	jaricom.c jcarith.c jdarith.c \
	turbojpeg.c transupp.c jdatadst-tj.c jdatasrc-tj.c \
	turbojpeg-mapfile

ifeq (,$(TARGET_BUILD_APPS))
# building against master
# use ashmem as libjpeg decoder's backing store
LOCAL_CFLAGS += -DUSE_ANDROID_ASHMEM
LOCAL_SRC_FILES += \
    jmem-ashmem.c
else
# unbundled branch, built against NDK.
LOCAL_SDK_VERSION := 17
# the original android memory manager.
# use sdcard as libjpeg decoder's backing store
LOCAL_SRC_FILES += \
    jmem-android.c
endif


LOCAL_STATIC_LIBRARIES := liblog \
    libcutils \

ifeq (USE_SIMD, true)
LOCAL_STATIC_LIBRARIES += libsimd
else
libjpeg_SOURCES_DIST += jsimd_none.c
endif

LOCAL_SRC_FILES:= $(libjpeg_SOURCES_DIST)

LOCAL_CFLAGS += -DAVOID_TABLES  -O3 -fstrict-aliasing -fprefetch-loop-arrays  -DANDROID \
        -DANDROID_TILE_BASED_DECODE -DENABLE_ANDROID_NULL_CONVERT -DANDROID_JPEG_USE_VENUM

LOCAL_MODULE_TAGS := debug
LOCAL_MODULE := libjpeg_static

include $(BUILD_STATIC_LIBRARY)

######################################################
#          Build shared library libjpeg.so         ###
######################################################
include $(CLEAR_VARS)
LOCAL_MODULE := libjpeg
LOCAL_MODULE_TAGS := optional
LOCAL_WHOLE_STATIC_LIBRARIES = libjpeg_static
LOCAL_SHARED_LIBRARIES := liblog libcutils
include $(BUILD_SHARED_LIBRARY)

######################################################
###                  cjpeg                         ###
######################################################

include $(CLEAR_VARS)

# From autoconf-generated Makefile
cjpeg_SOURCES = cdjpeg.c cjpeg.c rdbmp.c rdgif.c \
        rdppm.c rdswitch.c rdtarga.c

LOCAL_SRC_FILES:= $(cjpeg_SOURCES)

LOCAL_SHARED_LIBRARIES := libjpeg

LOCAL_CFLAGS := -DBMP_SUPPORTED -DGIF_SUPPORTED -DPPM_SUPPORTED -DTARGA_SUPPORTED \
         -DANDROID -DANDROID_TILE_BASED_DECODE -DENABLE_ANDROID_NULL_CONVERT

LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLE)

LOCAL_MODULE_TAGS := debug

LOCAL_MODULE := cjpeg

include $(BUILD_EXECUTABLE)

######################################################
###                  djpeg                         ###
######################################################

include $(CLEAR_VARS)

# From autoconf-generated Makefile
djpeg_SOURCES = cdjpeg.c djpeg.c rdcolmap.c rdswitch.c \
        wrbmp.c wrgif.c wrppm.c wrtarga.c

LOCAL_SRC_FILES:= $(djpeg_SOURCES)

LOCAL_SHARED_LIBRARIES := libjpeg

LOCAL_CFLAGS := -DBMP_SUPPORTED -DGIF_SUPPORTED -DPPM_SUPPORTED -DTARGA_SUPPORTED \
            -DANDROID -DANDROID_TILE_BASED_DECODE -DENABLE_ANDROID_NULL_CONVERT

LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLE)

LOCAL_MODULE_TAGS := debug

LOCAL_MODULE := djpeg

include $(BUILD_EXECUTABLE)

######################################################
###                    jpegtran                    ###
######################################################

include $(CLEAR_VARS)

# From autoconf-generated Makefile
jpegtran_SOURCES = jpegtran.c rdswitch.c cdjpeg.c transupp.c

LOCAL_SRC_FILES:= $(jpegtran_SOURCES)

LOCAL_SHARED_LIBRARIES := libjpeg

LOCAL_CFLAGS := -DANDROID -DANDROID_TILE_BASED_DECODE -DENABLE_ANDROID_NULL_CONVERT

LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLE)

LOCAL_MODULE_TAGS := debug

LOCAL_MODULE := jpegtran

include $(BUILD_EXECUTABLE)

######################################################
###                 tjunittest                     ###
######################################################

include $(CLEAR_VARS)

# From autoconf-generated Makefile
tjunittest_SOURCES = tjunittest.c tjutil.c

LOCAL_SRC_FILES:= $(tjunittest_SOURCES)

LOCAL_SHARED_LIBRARIES := libjpeg

LOCAL_CFLAGS := -DANDROID -DANDROID_TILE_BASED_DECODE -DENABLE_ANDROID_NULL_CONVERT

LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLE)

LOCAL_MODULE_TAGS := debug

LOCAL_MODULE := tjunittest

include $(BUILD_EXECUTABLE)

######################################################
###                  tjbench                       ###
######################################################

include $(CLEAR_VARS)

# From autoconf-generated Makefile
tjbench_SOURCES = tjbench.c bmp.c tjutil.c rdbmp.c rdppm.c \
        wrbmp.c wrppm.c

LOCAL_SRC_FILES:= $(tjbench_SOURCES)

LOCAL_SHARED_LIBRARIES := libjpeg

LOCAL_CFLAGS := -DBMP_SUPPORTED -DPPM_SUPPORTED \
         -DANDROID -DANDROID_TILE_BASED_DECODE -DENABLE_ANDROID_NULL_CONVERT

LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLE)

LOCAL_MODULE_TAGS := debug

LOCAL_MODULE := tjbench

include $(BUILD_EXECUTABLE)

######################################################
###                    rdjpgcom                    ###
######################################################

include $(CLEAR_VARS)

# From autoconf-generated Makefile
rdjpgcom_SOURCES = rdjpgcom.c

LOCAL_SRC_FILES:= $(rdjpgcom_SOURCES)

LOCAL_SHARED_LIBRARIES := libjpeg

LOCAL_CFLAGS :=  -DANDROID -DANDROID_TILE_BASED_DECODE -DENABLE_ANDROID_NULL_CONVERT

LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLE)

LOCAL_MODULE_TAGS := debug

LOCAL_MODULE := rdjpgcom

include $(BUILD_EXECUTABLE)

######################################################
###                     wrjpgcom                   ###
######################################################

include $(CLEAR_VARS)

# From autoconf-generated Makefile
wrjpgcom_SOURCES = wrjpgcom.c

LOCAL_SRC_FILES:= $(wrjpgcom_SOURCES)

LOCAL_SHARED_LIBRARIES := libjpeg

LOCAL_CFLAGS := -DANDROID -DANDROID_TILE_BASED_DECODE -DENABLE_ANDROID_NULL_CONVERT

LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLE)

LOCAL_MODULE_TAGS := debug

LOCAL_MODULE := wrjpgcom

include $(BUILD_EXECUTABLE)

endif  # TARGET_SIMULATOR != true
endif  # USE_LIBJPEG_TURBO = true
