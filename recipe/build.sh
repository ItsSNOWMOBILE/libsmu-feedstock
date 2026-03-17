#!/usr/bin/env bash
set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_SBINDIR=bin \
    -DBUILD_PYTHON=ON \
    -DBUILD_CLI=ON \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTS=OFF \
    -DENABLE_PACKAGING=OFF \
    -DPYTHON_EXECUTABLE:FILEPATH=$PYTHON \
    -DWITH_DOC=OFF \
    ..

cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install

# Install python bindings
# In 1.0.4, setup.py might be generated in the build directory
if [ -f "bindings/python/setup.py" ]; then
    cd bindings/python
elif [ -f "../bindings/python/setup.py" ]; then
    cd ../bindings/python
else
    echo "Could not find setup.py for python bindings"
    exit 1
fi

$PYTHON -m pip install . --no-deps --ignore-installed -vv
