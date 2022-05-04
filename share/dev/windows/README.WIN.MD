# Building OCIO on Windows using MS Visual Studio MSVC

# Manual steps
- Install Microsoft Visual Studio
- Install Python
- Install CMake
- Install Doxygen (optional: only for python documentations)

## Microsoft Visual Studio (Desktop development with C++)
Please use the official Microsfot Visual Studio installer.
> See https://visualstudio.microsoft.com/downloads/

## Python
Please use the official Python installer
> See https://www.python.org/downloads/

**Make sure to check the option to add Python to PATH environment variable while running the installer**

## Cmake
Please use the official CMake installer.
> See https://cmake.org/download/
>
> Example: https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1-windows-x86_64.msi

**Make sure to check the option to add CMake to PATH environment variable while running the installer**

### Doxygen (optional: only for python documentations)
Please use the official Doxygen installer.
> See https://www.doxygen.nl/download.html
> 
> Example: https://www.doxygen.nl/files/doxygen-1.9.3-setup.exe


# Automated steps

## Using ocio_deps.bat
**ocio_deps.bat** script can be used to verify and install the rest of OCIO dependencies.
<br/>
The script can be used to install the following:
- Vcpkg
- OpenImageIO
- FreeGLUT
- Glew
- Python documentation dependencies (six, testresources, recommonmark, sphinx-p1ress-theme,     sphinx-tabs and breathe)

Run ocio script and follow the steps.
```bash
# If vcpkg is not installed
ocio.bat
# If vcpkg is installed already
ocio.bat --vcpkg <path to vcpkg root>

See help:

Mandatory option:
--vcpkg        Vcpkg location or location where you want to install it
```

# Buiding OCIO
## Using ocio.bat
Ocio_deps.bat can be used to build and install OCIO.
```bash
# Options can be removed by modifying the value inside ocio.bat script.
# see the top of ocio.bat file.
# Release
ocio.bat --vcpkg <vcpkg directory> --python <python directory> --type Release
# Debug
ocio.bat --vcpkg <vcpkg directory> --python <python directory> --type Release

See help:

Mandatory options:
--vcpkg        Vcpkg location

Optional options depending on the environment:
--python       Python installation

--msvs         vcvars64.bat location
               Default: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build

--ocio         path to OCIO source code
               Note: If the script is run from its repository location, this should not be specified.
               Default: ../../../

--b            build location
               Default: C:\Users\WDAGUtilityAccount\AppData\Local\Temp\OCIO\build

--i            installation location
               Default: C:\Users\WDAGUtilityAccount\AppData\Local\Temp\OCIO\install

--type         Release or Debug
               Default: Release
```