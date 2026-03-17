setlocal EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir build
cd build

:: configure
cmake -G "Ninja" %CMAKE_ARGS% ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR:PATH="lib" ^
    -DCMAKE_INSTALL_SBINDIR:PATH="bin" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DLIBUSB_LIBRARIES:PATH="%LIBRARY_LIB%\libusb-1.0.lib" ^
    -DLIBUSB_INCLUDE_DIRS:PATH="%LIBRARY_INC%\libusb-1.0" ^
    -DENABLE_PACKAGING=OFF ^
    -DBUILD_PYTHON=ON ^
    -DBUILD_CLI=ON ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_TESTS=OFF ^
    -DINSTALL_UDEV_RULES=OFF ^
    -DPYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
    -DWITH_DOC=OFF ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Install python bindings
if exist "bindings\python\setup.py" (
    cd bindings\python
) else (
    cd ..\bindings\python
)

if not exist "setup.py" (
    echo "Could not find setup.py for python bindings"
    exit 1
)

%PYTHON% -m pip install . --no-deps --ignore-installed -vv
if errorlevel 1 exit 1
