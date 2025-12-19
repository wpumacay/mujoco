#!/usr/bin/env bash

set -e

build_type="Release"

echo "Going back to the root of the project"
cd "$(git rev-parse --show-toplevel)"

if [ ! -d "install" ]; then
    mkdir install
fi

echo "Configuring ..."
CMAKE_CONFIG_ARGS=(
    "-DCMAKE_BUILD_TYPE=${build_type}"
    # "-DUSE_STATIC_LIBCXX=OFF"
    # "-DBUILD_SHARED_LIBS=OFF"
    "-DMUJOCO_BUILD_EXAMPLES=OFF"
    "-DMUJOCO_BUILD_SIMULATE=OFF"
    "-DMUJOCO_BUILD_TESTS=OFF"
    "-DMUJOCO_WITH_USD=OFF"
    "-DMUJOCO_USE_FILAMENT=OFF"
    "-DMUJOCO_BUILD_STUDIO=OFF"
    "-DCMAKE_INSTALL_PREFIX=install"
    "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF"
)

if [[ -n "${CMAKE_ARGS}" ]]; then
    read -a cmake_args_arr <<<"$CMAKE_ARGS"
    CMAKE_CONFIG_ARGS+=("${cmake_args_arr[@]}")
fi

cmake -B build "${CMAKE_CONFIG_ARGS[@]}"
echo "Configuring ... DONE"

echo "Building ..."

cmake --build build --config="${build_type}"

echo "Building ... DONE"

echo "Installing to target dir ..."

cmake --install build

echo "Installing ... DONE"

