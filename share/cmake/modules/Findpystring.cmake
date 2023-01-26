# SPDX-License-Identifier: BSD-3-Clause
# Copyright Contributors to the OpenColorIO Project.
#
# Locate pystring
#
# Variables defined by this module:
#   pystring_FOUND          - Indicate whether the library was found or not
#   pystring_LIBRARY        - Path to the library file
#   pystring_INCLUDE_DIR    - Location of the header files
#   pystring_VERSION        - Library's version
#
# Global targets defined by this module:
#   pystring::pystring - IMPORTED target, if found
#
# The dynamic libraries will be located by default.
#
# If the library is not installed in a standard path, you can do the following the help
# the find module:
#
# If the package provides a configuration file, use -Dpystring_DIR=<path to folder>.
# If it doesn't provide it, try -Dpystring_ROOT=<path to folder with lib and includes>.
# Alternatively, try -Dpystring_LIBRARY=<path to lib file> and -Dpystring_INCLUDE_DIR=<path to folder>.
#

###############################################################################
### Try to find package ###

if(NOT OCIO_INSTALL_EXT_PACKAGES STREQUAL ALL)
    # Find include directory
    find_path(pystring_INCLUDE_DIR
        NAMES
            pystring/pystring.h
        HINTS
            ${pystring_ROOT}
        PATH_SUFFIXES
            include
            pystring/include
    )

    # Find library
    find_library(pystring_LIBRARY
        NAMES
            pystring libpystring
        HINTS
            ${_pystring_SEARCH_DIRS}
        PATH_SUFFIXES
            pystring/lib
            lib64
            lib
    )

    # Override REQUIRED if package can be installed
    if(OCIO_INSTALL_EXT_PACKAGES STREQUAL MISSING)
        set(pystring_FIND_REQUIRED FALSE)
    endif()

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(pystring
        REQUIRED_VARS 
            pystring_INCLUDE_DIR 
            pystring_LIBRARY
    )
    set(pystring_FOUND ${pystring_FOUND})
endif()

###############################################################################
### Configure target ###

if(pystring_FOUND AND NOT TARGET pystring::pystring)
    add_library(pystring::pystring UNKNOWN IMPORTED GLOBAL)
    set(_pystring_TARGET_CREATE TRUE)
endif()

###############################################################################
### Configure target ###

if(_pystring_TARGET_CREATE)
    set_target_properties(pystring::pystring PROPERTIES
        IMPORTED_LOCATION ${pystring_LIBRARY}
        INTERFACE_INCLUDE_DIRECTORIES ${pystring_INCLUDE_DIR}
    )

    mark_as_advanced(pystring_INCLUDE_DIR pystring_LIBRARY pystring_VERSION)
endif()