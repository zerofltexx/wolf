# fake-uinput: LD_PRELOAD shim that lets containerized apps (e.g. Steam Input) create uinput
# devices in an unprivileged Wolf session container. It intercepts ioctl(UI_DEV_CREATE/DESTROY)
# and notifies Wolf over the control socket; Wolf performs the privileged mknod + fake-udev.
# Structure mirrors src/fake-udev. The shim is a single translation unit with no dependencies
# beyond libc/libdl.
option(BUILD_FAKE_UINPUT "Build fake-uinput shim library" ON)
if (BUILD_FAKE_UINPUT)
    message(STATUS "Building fake-uinput")

    add_library(fake_uinput SHARED fake-uinput.cpp)
    add_library(fake-uinput::lib ALIAS fake_uinput)

    target_compile_features(fake_uinput PRIVATE cxx_std_17)
    target_link_libraries(fake_uinput PRIVATE ${CMAKE_DL_LIBS})
    set_target_properties(fake_uinput PROPERTIES OUTPUT_NAME "fake-uinput" CXX_VISIBILITY_PRESET hidden)
    # This target is for development and tests. The shims shipped in the image (64- and 32-bit) are
    # built in docker/wolf.Dockerfile's fake-uinput-builder stage, against an old glibc, because they
    # are LD_PRELOADed into session images from other distros.
endif ()
