#!/bin/sh

if [[ $# -eq 0 ]]; then
    echo "use -h for help"
    exit 1
fi

configure=0
build=0
install=0
run=0

while getopts "cbirh" opt; do
    case "$opt" in
        c) configure=1 ;;
        b) build=1 ;;
        i) install=1 ;;
        r) run=1 ;;
        h)
            echo "./android.sh [command]"
            echo "    -c        configure"
            echo "    -b        build"
            echo "    -i        install using adb"
            echo "    -r        run using adb"
            exit 1
            ;;
    esac
done

if [ "$configure" -eq 1 ]; then
    /usr/bin/android-aarch64-cmake -B build/android -DCMAKE_BUILD_TYPE=Debug \
                -DQT_ANDROID_ABIS="arm64-v8a" \
                -DANDROID_PLATFORM=android-23 \
                -DANDROID_SDK_ROOT="/home/$USER/.android/sdk" \
                -DANDROID_NDK="/home/$USER/.android/sdk/ndk/26.3.11579264" \
                -DCMAKE_TOOLCHAIN_FILE="/home/$USER/.android/sdk/ndk/26.3.11579264/build/cmake/android.toolchain.cmake" \
                -DCMAKE_FIND_ROOT_PATH="/opt/android-libs/aarch64"
fi

if [ "$build" -eq 1 ]; then
    cmake --build build/android -j16
fi

if [ "$install" -eq 1 ]; then
    cmake --build build/android install_apk
fi

if [ "$run" -eq 1 ]; then
    cmake --build build/android run_apk
fi
