#!/usr/bin/env bash

set -e

build_type="Release"

py_bin="/opt/python/cp310-cp310/bin/python"

echo "Going back to the root of the project"
ROOT_DIR="$(pwd)"

cd ${ROOT_DIR}

if [ ! -d "${ROOT_DIR}/install" ]; then
    mkdir install
fi

SHOW_HELP=false
build_filament=OFF
build_with_vulkan=OFF
build_studio=OFF
build_avx=ON
njobs=4

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) SHOW_HELP=true; shift ;;
        --filament) build_filament=ON; shift ;;
        --vulkan) build_with_vulkan=ON; shift ;;
        --studio) build_studio=ON; shift ;;
        --no-simd) build_avx=OFF; shift ;;
        --njobs) njobs="$2"; shift 2 ;;
        *) echo "Unkown option: $1"; exit 1 ;;
    esac
done

if [[ "${build_filament}" == "ON" ]]; then
    export CC=/usr/bin/clang
    export CXX=/usr/bin/clang++
fi

echo "Configuring ..."
CMAKE_CONFIG_ARGS=(
    "-DCMAKE_BUILD_TYPE=${build_type}"
    "-DUSE_STATIC_LIBCXX=OFF"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DMUJOCO_BUILD_EXAMPLES=OFF"
    "-DMUJOCO_BUILD_SIMULATE=ON"
    "-DMUJOCO_BUILD_TESTS=OFF"
    "-DMUJOCO_WITH_USD=OFF"
    "-DMUJOCO_USE_FILAMENT=${build_filament}"
    "-DMUJOCO_USE_FILAMENT_VULKAN=${build_with_vulkan}"
    "-DMUJOCO_BUILD_STUDIO=${build_studio}"
    "-DCMAKE_INSTALL_PREFIX=install"
    "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF"
    "-DMUJOCO_ENABLE_AVX_INTRINSICS=${build_avx}"
)

if [[ -n "${CMAKE_ARGS}" ]]; then
    read -a cmake_args_arr <<<"$CMAKE_ARGS"
    CMAKE_CONFIG_ARGS+=("${cmake_args_arr[@]}")
fi

cmake -B build "${CMAKE_CONFIG_ARGS[@]}"

echo "Building ..."

cmake --build build --config="${build_type}" --parallel ${njobs}

echo "Installing to target dir ..."

cmake --install build

echo "Copy plugins to install directory"

mkdir -p install/mujoco_plugin
cp ${ROOT_DIR}/build/lib64/libactuator.* ${ROOT_DIR}/install/mujoco_plugin
cp ${ROOT_DIR}/build/lib64/libelasticity.* ${ROOT_DIR}/install/mujoco_plugin
cp ${ROOT_DIR}/build/lib64/libsensor.* ${ROOT_DIR}/install/mujoco_plugin
cp ${ROOT_DIR}/build/lib64/libsdf_plugin.* ${ROOT_DIR}/install/mujoco_plugin

echo "Make source distribution"

bash ${ROOT_DIR}/python/make_sdist_manylinux.sh

echo "Build python wheel"

export MUJOCO_PATH="${ROOT_DIR}/install"
export MUJOCO_PLUGIN_PATH="${ROOT_DIR}/install/mujoco_plugin"

MUJOCO_CMAKE_ARGS=""
if [[ "${build_avx}" != ON ]]; then
    MUJOCO_CMAKE_ARGS="-DMUJOCO_ENABLE_AVX_INTRINSICS=OFF"
fi

MUJOCO_CMAKE_ARGS="${MUJOCO_CMAKE_ARGS}" ${py_bin} -m pip wheel --use-pep517 -vvv ${ROOT_DIR}/python/dist/mujoco-*.tar.gz --wheel-dir ${ROOT_DIR}/python/dist

auditwheel repair --wheel-dir ${ROOT_DIR}/python/dist ${ROOT_DIR}/python/dist/mujoco-*.whl
