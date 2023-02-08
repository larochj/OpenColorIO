# SPDX-License-Identifier: BSD-3-Clause
# Copyright Contributors to the OpenColorIO Project.
#
# Locate Imath
#
# Variables defined by this module:
#   Imath_FOUND          - Indicate whether the library was found or not
#   Imath_LIBRARY        - Path to the library file
#   Imath_INCLUDE_DIR    - Location of the header files
#   Imath_VERSION        - Library's version
#
# Global targets defined by this module:
#   Imath::Imath
#
# The libraries files are search based on the CMake variable CMAKE_FIND_LIBRARY_SUFFIXES. On the 
# majority of operating systems, the dynamic libaries are prefered first, and then static libraries.
#
# If your installation has both static and dynamic libraries present, the dynamic one will be used 
# by default. You may set Imath_STATIC_LIBRARY to TRUE to use the static one. If the static one is 
# missing, CMake won't find anything even if the variable is set. If only the static one is present, 
# that variable is unnecessary. It is ignored if OCIO is installing the library since OCIO builds
# the dependency as static library.
#
# If the library is not installed in a standard path, you can do the following the help
# the find module:
#
# If the package provides CMake's configuration file, use -DImath_DIR=<path to folder>.
# If it doesn't provide it, try -DImath_ROOT=<path to folder with lib and includes>.
# Alternatively, try -DImath_LIBRARY=<path to lib file> and -DImath_INCLUDE_DIR=<path to folder>.
#

###############################################################################
### Try to find package ###

# BUILD_TYPE_DEBUG variable is currently set in one of the OCIO's CMake files. 
# Now that some OCIO's find module are installed with the library itself (with static build), 
# a consumer app don't have access to the variables set by an OCIO's CMake files. Therefore, some 
# OCIO's find modules must detect the build type by itselves. 
set(BUILD_TYPE_DEBUG OFF)
if(CMAKE_BUILD_TYPE MATCHES "[Dd][Ee][Bb][Uu][Gg]")
   set(BUILD_TYPE_DEBUG ON)
endif()

if(NOT OCIO_INSTALL_EXT_PACKAGES STREQUAL ALL)
    set(_Imath_REQUIRED_VARS Imath_LIBRARY)
    set(_Imath_LIB_VER "${Imath_FIND_VERSION_MAJOR}_${Imath_FIND_VERSION_MINOR}")

    if(NOT DEFINED Imath_ROOT)
        # Search for ImathConfig.cmake
        find_package(Imath ${Imath_FIND_VERSION} CONFIG QUIET)
    endif()

    if(Imath_FOUND)
        get_target_property(Imath_LIBRARY Imath::Imath LOCATION)
    else()
        list(APPEND _Imath_REQUIRED_VARS Imath_INCLUDE_DIR)

        # Search for Imath.pc
        find_package(PkgConfig QUIET)
        pkg_check_modules(PC_Imath QUIET "Imath>=${Imath_FIND_VERSION}")

        # Find include directory
        find_path(Imath_INCLUDE_DIR
            NAMES
                Imath/ImathConfig.h
            HINTS
                ${Imath_ROOT}
                ${PC_Imath_INCLUDE_DIRS}
            PATH_SUFFIXES
                include
        )

        # Lib names to search for
        set(_Imath_LIB_NAMES "Imath-${_Imath_LIB_VER}" Imath)
        if(BUILD_TYPE_DEBUG)
            # Prefer Debug lib names
            list(INSERT _Imath_LIB_NAMES 0 "Imath-${_Imath_LIB_VER}_d")
        endif()

        if(Imath_STATIC_LIBRARY)
            # Prefer static lib names
            set(_Imath_STATIC_LIB_NAMES 
                "${CMAKE_STATIC_LIBRARY_PREFIX}Imath-${_Imath_LIB_VER}${CMAKE_STATIC_LIBRARY_SUFFIX}"
                "${CMAKE_STATIC_LIBRARY_PREFIX}Imath${CMAKE_STATIC_LIBRARY_SUFFIX}"
            )
            if(BUILD_TYPE_DEBUG)
                # Prefer static Debug lib names
                list(INSERT _Imath_STATIC_LIB_NAMES 0
                    "${CMAKE_STATIC_LIBRARY_PREFIX}Imath-${_Imath_LIB_VER}_d${CMAKE_STATIC_LIBRARY_SUFFIX}")
            endif()
        endif()

        # Find library
        find_library(Imath_LIBRARY
            NAMES
                ${_Imath_STATIC_LIB_NAMES} 
                ${_Imath_LIB_NAMES}
            HINTS
                ${Imath_ROOT}
                ${PC_Imath_LIBRARY_DIRS}
            PATH_SUFFIXES
                lib64 lib 
        )

        # Get version from config header file
        if(Imath_INCLUDE_DIR)
            if(EXISTS "${Imath_INCLUDE_DIR}/Imath/ImathConfig.h")
                set(_Imath_CONFIG "${Imath_INCLUDE_DIR}/Imath/ImathConfig.h")
            endif()
        endif()

        if(_Imath_CONFIG)
            file(STRINGS "${_Imath_CONFIG}" _Imath_VER_SEARCH 
                REGEX "^[ \t]*#define[ \t]+IMATH_VERSION_STRING[ \t]+\"[.0-9]+\".*$")
            if(_Imath_VER_SEARCH)
                string(REGEX REPLACE ".*#define[ \t]+IMATH_VERSION_STRING[ \t]+\"([.0-9]+)\".*" 
                    "\\1" Imath_VERSION "${_Imath_VER_SEARCH}")
            endif()
        elseif(PC_Imath_FOUND)
            set(Imath_VERSION "${PC_Imath_VERSION}")
        endif()
    endif()

    # Override REQUIRED if package can be installed
    if(OCIO_INSTALL_EXT_PACKAGES STREQUAL MISSING)
        set(Imath_FIND_REQUIRED FALSE)
    endif()

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(Imath
        REQUIRED_VARS 
            ${_Imath_REQUIRED_VARS}
        VERSION_VAR
            Imath_VERSION
    )
endif()

###############################################################################
### Create target

if (Imath_FOUND AND NOT TARGET Imath::Imath)
    add_library(Imath::Imath UNKNOWN IMPORTED GLOBAL)
    add_library(Imath::ImathConfig INTERFACE IMPORTED GLOBAL)
    set(_Imath_TARGET_CREATE TRUE)
endif()

###############################################################################
### Configure target ###

if(_Imath_TARGET_CREATE)
    file(MAKE_DIRECTORY ${Imath_INCLUDE_DIR}/Imath)

    set_target_properties(Imath::Imath PROPERTIES
        IMPORTED_LOCATION ${Imath_LIBRARY}
        INTERFACE_INCLUDE_DIRECTORIES "${Imath_INCLUDE_DIR};${Imath_INCLUDE_DIR}/Imath"
    )
    set_target_properties(Imath::ImathConfig PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Imath_INCLUDE_DIR};${Imath_INCLUDE_DIR}/Imath"
    )

    mark_as_advanced(Imath_INCLUDE_DIR Imath_LIBRARY Imath_VERSION)
endif()