# SPDX-License-Identifier: BSD-3-Clause
# Copyright Contributors to the OpenColorIO Project.
#
# All find modules used in this module support typical find_package
# behavior or installation of packages from external projects, as configured 
# by the OCIO_INSTALL_EXT_PACKAGES option.
#

include(Colors)
include(ocio_find_package)

###############################################################################
### Global package options ###

# Some packages register their CMake config location in the CMake User or 
# System Package Registry. We disable these search locations globally since 
# they can cause unwanted linking between multiple builds of OpenColorIO 
# when a package has previously been installed to ext/dist. Set these variables
# to OFF during cmake configuration to enable package registry use.

set(CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY ON CACHE BOOL
    "Disable CMake User Package Registry when finding packages")

set(CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY ON CACHE BOOL
    "Disable CMake System Package Registry when finding packages")

if (APPLE)
    # Store the previous value of CMAKE_FIND_FRAMEWORK and CMAKE_FIND_APPBUNDLE.
    set(_PREVIOUS_CMAKE_FIND_FRAMEWORK ${CMAKE_FIND_FRAMEWORK})
    set(_PREVIOUS_CMAKE_FIND_APPBUNDLE ${CMAKE_FIND_APPBUNDLE})

    # Prioritize other paths before Frameworks and Appbundle for find_path, find_library and 
    # find_package.
    set(CMAKE_FIND_FRAMEWORK LAST)
    set(CMAKE_FIND_APPBUNDLE LAST)
endif()


message(STATUS "")
message(STATUS "Missing a dependency? Try the following possibilities:")
message(STATUS "If the package provides a configuration file, use -D<pkg>_DIR=<path to folder>.")
message(STATUS "If it doesn't provide it, try -D<pkg>_ROOT=<path to folder with lib and includes>.")
message(STATUS "Alternatively, try -D<pkg>_LIBRARY=<path to lib file> and -D<pkg>_INCLUDE_DIR=<path to folder>.")
message(STATUS "")
message(STATUS "Please refer to the find module under share/cmake/modules for extra information.")

###############################################################################
##
## Required dependencies
##
###############################################################################
message(STATUS "")
message(STATUS "Checking for mandatory dependencies...")

# expat
# https://github.com/libexpat/libexpat
ocio_find_package(  expat REQUIRED ALLOW_INSTALL
                    MIN_VERSION 2.4.1
                    RECOMMENDED_MIN_VERSION 2.5.0
                    RECOMMENDED_MIN_VERSION_REASON "CVE fixes and fix issue with symbol leakage when built as a static library")

# yaml-cpp
# https://github.com/jbeder/yaml-cpp
ocio_find_package(  yaml-cpp REQUIRED ALLOW_INSTALL
                    MIN_VERSION 0.6.3
                    RECOMMENDED_MIN_VERSION 0.7.0
                    RECOMMENDED_MIN_VERSION_REASON "Latest version tested with OCIO")

# pystring
# https://github.com/imageworks/pystring
ocio_find_package(  pystring REQUIRED ALLOW_INSTALL
                    MIN_VERSION 1.1.3
                    RECOMMENDED_MIN_VERSION 1.1.3
                    RECOMMENDED_MIN_VERSION_REASON "Latest version tested with OCIO")

# Imath (>=3.1)
# https://github.com/AcademySoftwareFoundation/Imath
ocio_find_package(  Imath REQUIRED ALLOW_INSTALL
                    MIN_VERSION 3.1.1
                    RECOMMENDED_MIN_VERSION 3.1.5
                    RECOMMENDED_MIN_VERSION_REASON "Latest version tested with OCIO")

###############################################################################
### ZLIB (https://github.com/madler/zlib)
###
### The following variables can be set:
### ZLIB_ROOT               Location of ZLIB library file and includes folder.
###                         Alternatively, ZLIB_LIBRARY and ZLIB_INCLUDE_DIR can be used.
###
### ZLIB_LIBRARY            Location of ZLIB library file.
### ZLIB_INCLUDE_DIR        Location of ZLIB includes folder.
###
### ZLIB_VERSION            ZLIB Version (CMake 3.26+)
### ZLIB_VERSION_STRING     ZLIB Version (CMake < 3.26)
###
###############################################################################
# ZLIB 1.2.13 is used since it fixes a critical vulnerability.
# See https://nvd.nist.gov/vuln/detail/CVE-2022-37434
# See https://github.com/madler/zlib/releases/tag/v1.2.13

if(NOT OCIO_INSTALL_EXT_PACKAGES STREQUAL ALL)
    # ZLIB_USE_STATIC_LIBS is supported only from CMake 3.24+.
    if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.24.0") 
        if (ZLIB_STATIC_LIBRARY)
            set(ZLIB_USE_STATIC_LIBS "${ZLIB_STATIC_LIBRARY}")
        endif()
    else() # For CMake < 3.24 since ZLIB_USE_STATIC_LIBS is not available.
        if(NOT ZLIB_LIBRARY)
            set(_cmake_find_library_x_changed true)
            if(DEFINED CMAKE_FIND_LIBRARY_PREFIXES)
                set(_ZLIB_ORIG_CMAKE_FIND_LIBRARY_PREFIXES "${CMAKE_FIND_LIBRARY_PREFIXES}")
            else()
                set(_ZLIB_ORIG_CMAKE_FIND_LIBRARY_PREFIXES)
            endif()

            if(DEFINED CMAKE_FIND_LIBRARY_SUFFIXES)
                set(_ZLIB_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES "${CMAKE_FIND_LIBRARY_SUFFIXES}")
            else()
                set(_ZLIB_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES)
            endif()

            # Prefix/suffix for windows.
            if(WIN32)
                list(APPEND CMAKE_FIND_LIBRARY_PREFIXES "" "lib")
                list(APPEND CMAKE_FIND_LIBRARY_SUFFIXES ".dll.a")
            endif()

            # Check if static lib is preferred.
            if(ZLIB_STATIC_LIBRARY OR ZLIB_USE_STATIC_LIBS)
                if(WIN32)
                    set(CMAKE_FIND_LIBRARY_SUFFIXES .lib .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
                else()
                    set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
                endif()
            endif()
        endif()
    endif()

    set(_ZLIB_REQUIRED REQUIRED)
    # Override REQUIRED if package can be installed
    if(OCIO_INSTALL_EXT_PACKAGES STREQUAL MISSING)
        set(_ZLIB_REQUIRED "")
    endif()

    ocio_find_package(  ZLIB REQUIRED ALLOW_INSTALL
                        MIN_VERSION 1.2.10
                        RECOMMENDED_MIN_VERSION 1.2.13
                        RECOMMENDED_MIN_VERSION_REASON "CVE fixes"
                        VERSION_VARS ZLIB_VERSION_STRING ZLIB_VERSION )

    # Restore the original find library ordering
    if(_cmake_find_library_x_changed)
        if(DEFINED _ZLIB_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES)
            set(CMAKE_FIND_LIBRARY_SUFFIXES "${_ZLIB_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES}")
        else()
            set(CMAKE_FIND_LIBRARY_SUFFIXES)
        endif()

        if(DEFINED _ZLIB_ORIG_CMAKE_FIND_LIBRARY_PREFIXES)
            set(CMAKE_FIND_LIBRARY_PREFIXES "${_ZLIB_ORIG_CMAKE_FIND_LIBRARY_PREFIXES}")
        else()
            set(CMAKE_FIND_LIBRARY_PREFIXES)
        endif()
    endif()
endif()

if(NOT ZLIB_FOUND)
    ocio_install_package(ZLIB VERSION 1.2.13)
endif()
###############################################################################

# minizip-ng
# https://github.com/zlib-ng/minizip-ng
ocio_find_package(  minizip-ng REQUIRED ALLOW_INSTALL
                    MIN_VERSION 3.0.6
                    RECOMMENDED_MIN_VERSION 3.0.7
                    RECOMMENDED_MIN_VERSION_REASON "Latest version tested with OCIO")

###############################################################################
##
## Optional dependencies
##
###############################################################################
message(STATUS "")
message(STATUS "Checking for optional dependencies...")

if(OCIO_BUILD_APPS)
    # NOTE: Depending of the compiler version lcms2 2.2 does not compile with 
    # C++17 so, if you change the lcms2 version update the code to compile 
    # lcms2 and dependencies with C++17 or higher i.e. remove the cap of C++ 
    # version in Findlcms2.cmake and src/apps/ociobakelut/CMakeLists.txt.

    # lcms2
    # https://github.com/mm2/Little-CMS
    ocio_find_package(  lcms2 REQUIRED ALLOW_INSTALL
                        MIN_VERSION 2.2
                        RECOMMENDED_MIN_VERSION 2.2
                        RECOMMENDED_MIN_VERSION_REASON "Latest version tested with OCIO")
endif()

if(OCIO_BUILD_OPENFX)
    # openfx
    # https://github.com/ofxa/openfx
    ocio_find_package(  openfx REQUIRED ALLOW_INSTALL
                        MIN_VERSION 1.4.0
                        RECOMMENDED_MIN_VERSION 1.4.0
                        RECOMMENDED_MIN_VERSION_REASON "Latest version tested with OCIO")
endif()

if (OCIO_PYTHON_VERSION AND NOT OCIO_BUILD_PYTHON)
    message (WARNING "OCIO_PYTHON_VERSION=${OCIO_PYTHON_VERSION} but OCIO_BUILD_PYTHON is off.")
endif ()

if(OCIO_BUILD_PYTHON OR OCIO_BUILD_DOCS)

    # NOTE: We find Python once in the global scope so that it can be checked 
    # and referenced throughout the project.

    set(_Python_COMPONENTS Interpreter)

    # Support building on manylinux docker images.
    # https://pybind11.readthedocs.io/en/stable/compiling.html#findpython-mode
    if(OCIO_BUILD_PYTHON AND ${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.18.0")
        list(APPEND _Python_COMPONENTS Development.Module)
    elseif(OCIO_BUILD_PYTHON)
        list(APPEND _Python_COMPONENTS Development)
    endif()


    # Python
    ocio_find_package(  Python REQUIRED
                        COMPONENTS ${_Python_COMPONENTS}
                        MIN_VERSION ${OCIO_PYTHON_VERSION}
                        RECOMMENDED_MIN_VERSION ${OCIO_PYTHON_VERSION}
                        RECOMMENDED_MIN_VERSION_REASON "Latest version tested with OCIO")

    if(OCIO_BUILD_PYTHON)
        # pybind11
        # https://github.com/pybind/pybind11
        # pybind11 2.9 fixes issues with MS Visual Studio 2022 (Debug).
        ocio_find_package(  pybind11 REQUIRED ALLOW_INSTALL
                            MIN_VERSION 2.9.2
                            RECOMMENDED_MIN_VERSION 2.9.2
                            RECOMMENDED_MIN_VERSION_REASON "Pybind 2.10.0+ does not work with Python 2.7 anymore")
    endif()
endif()

if((OCIO_BUILD_APPS AND OCIO_USE_OIIO_FOR_APPS) OR OCIO_BUILD_TESTS)
    # OpenImageIO is required for OSL unit test and optional for apps.

    # OpenImageIO
    # https://github.com/OpenImageIO/oiio
    set(OIIO_VERSION "2.2.14")
    set(OIIO_RECOMMENDED_VERSION "2.4")

    # TODO: Try when OIIO 2.4 is released (https://github.com/OpenImageIO/oiio/pull/3322).
    # Supported from OIIO 2.4+. Setting this for lower versions doesn't affect anything.
    set(OPENIMAGEIO_CONFIG_DO_NOT_FIND_IMATH 1)
    ocio_find_package(  OpenImageIO 
                        MIN_VERSION ${OIIO_VERSION}
                        RECOMMENDED_MIN_VERSION ${OIIO_RECOMMENDED_VERSION})
endif()

if(OCIO_BUILD_APPS)

    if(OCIO_USE_OIIO_FOR_APPS AND OpenImageIO_FOUND AND TARGET OpenImageIO::OpenImageIO)
        add_library(OpenColorIO::ImageIOBackend ALIAS OpenImageIO::OpenImageIO)
        set(OCIO_IMAGE_BACKEND OpenImageIO)
    else()
        # OpenEXR
        # https://github.com/AcademySoftwareFoundation/openexr
        ocio_find_package(  OpenEXR REQUIRED ALLOW_INSTALL
                            MIN_VERSION 3.0.4
                            RECOMMENDED_MIN_VERSION 3.1.5
                            RECOMMENDED_MIN_VERSION_REASON "Latest version tested with OCIO")

        if(OpenEXR_FOUND AND TARGET OpenEXR::OpenEXR)
            add_library(OpenColorIO::ImageIOBackend ALIAS OpenEXR::OpenEXR)
            set(OCIO_IMAGE_BACKEND OpenEXR)
        endif()
    endif()

    if(OCIO_IMAGE_BACKEND)
        message(STATUS "Using ${OCIO_IMAGE_BACKEND} to build ociolutimage, ocioconvert and ociodisplay.")
    endif()

endif()

# Check dependencies for OSL unit test framework (i.e. OpenImageIO and Imath) before looking
# for the Open Shading Language library.

if(OCIO_BUILD_TESTS)
    if(TARGET OpenImageIO::OpenImageIO)
        if(TARGET Imath::Imath)
            # OpenShadingLanguage
            # https://github.com/AcademySoftwareFoundation/OpenShadingLanguage
            ocio_find_package(  OpenShadingLanguage
                                MIN_VERSION 1.11
                                RECOMMENDED_MIN_VERSION 1.11
                                RECOMMENDED_MIN_VERSION_REASON "Latest version tested with OCIO")
            if(NOT OSL_FOUND)
                message(WARNING "Skipping build of the OpenShadingLanguage unit tests (OpenShadingLanguage missing)")
            endif()
        else()
            message(WARNING "Skipping build of the OpenShadingLanguage unit tests (Imath missing)")
        endif()
    else()
        message(WARNING "Skipping build of the OpenShadingLanguage unit tests (OpenImageIO missing)")
    endif()
endif()

if (APPLE)
    # Restore CMAKE_FIND_FRAMEWORK and CMAKE_FIND_APPBUNDLE values.
    set(CMAKE_FIND_FRAMEWORK ${_PREVIOUS_CMAKE_FIND_FRAMEWORK})
    set(CMAKE_FIND_APPBUNDLE ${_PREVIOUS_CMAKE_FIND_APPBUNDLE})
endif()
