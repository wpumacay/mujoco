#!/usr/bin/env bash

set -e

build_type="Release"

echo "Going back to the root of the project"
ROOT_DIR="$(git rev-parse --show-toplevel)"

cd ${ROOT_DIR}

if [ ! -d "${ROOT_DIR}/install" ]; then
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
    "-DMUJOCO_USE_DEFAULT_LD=ON"
)

if [[ -n "${CMAKE_ARGS}" ]]; then
    read -a cmake_args_arr <<<"$CMAKE_ARGS"
    CMAKE_CONFIG_ARGS+=("${cmake_args_arr[@]}")
fi

cmake -B build "${CMAKE_CONFIG_ARGS[@]}"

echo "Building ..."

cmake --build build --config="${build_type}"

echo "Installing to target dir ..."

cmake --install build

echo "Copy plugins to install directory"

mkdir -p install/mujoco_plugin
cp ${ROOT_DIR}/build/lib/libactuator.* ${ROOT_DIR}/install/mujoco_plugin
cp ${ROOT_DIR}/build/lib/libelasticity.* ${ROOT_DIR}/install/mujoco_plugin
cp ${ROOT_DIR}/build/lib/libsensor.* ${ROOT_DIR}/install/mujoco_plugin
cp ${ROOT_DIR}/build/lib/libsdf_plugin.* ${ROOT_DIR}/install/mujoco_plugin

echo "Make source distribution"

bash ${ROOT_DIR}/python/make_sdist.sh

echo "Build python wheel"

MUJOCO_PATH=${ROOT_DIR}/install MUJOCO_PLUGIN_PATH=${ROOT_DIR}/install/mujoco_plugin uv build --wheel --force-pep517 ${ROOT_DIR}/python/dist/mujoco-*.tar.gz
