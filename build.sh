#!/bin/sh

# iOS & simulator running on arm64
cmake -S ./ -DCMAKE_BUILD_TYPE=RelWithDebInfo \
            -DPLATFORM=OS64 \
            -DDEPLOYMENT_TARGET=12.0 \
            -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake \
            -Dprotobuf_BUILD_PROTOC_BINARIES=OFF \
            -DgRPC_BUILD_CODEGEN=OFF \
            -DCARES_INSTALL=OFF \
            -DHAVE_LIBNSL=FALSE \
            -DHAVE_SOCKET_LIBSOCKET=FALSE \
            -DHAVE_GHBN_LIBSOCKET=FALSE \
            -DHAVE_LIBSOCKET=FALSE \
            -DHAVE_LIBRT=FALSE \
            -B out/os64
cmake -S ./ -DCMAKE_BUILD_TYPE=RelWithDebInfo \
            -DPLATFORM=SIMULATORARM64 \
            -DDEPLOYMENT_TARGET=12.0 \
            -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake \
            -Dprotobuf_BUILD_PROTOC_BINARIES=OFF \
            -DgRPC_BUILD_CODEGEN=OFF \
            -DCARES_INSTALL=OFF \
            -DHAVE_LIBNSL=FALSE \
            -DHAVE_SOCKET_LIBSOCKET=FALSE \
            -DHAVE_GHBN_LIBSOCKET=FALSE \
            -DHAVE_LIBSOCKET=FALSE \
            -DHAVE_LIBRT=FALSE \
            -B out/simulatorarm64

# macOS on arm64
cmake -S ./ -DCMAKE_BUILD_TYPE=RelWithDebInfo \
            -DPLATFORM=MAC_ARM64 \
            -DENABLE_ARC=0 \
            -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake \
            -Dprotobuf_BUILD_PROTOC_BINARIES=OFF \
            -DgRPC_BUILD_CODEGEN=OFF \
            -DCARES_INSTALL=OFF \
            -DHAVE_LIBNSL=FALSE \
            -DHAVE_SOCKET_LIBSOCKET=FALSE \
            -DHAVE_GHBN_LIBSOCKET=FALSE \
            -DHAVE_LIBSOCKET=FALSE \
            -DHAVE_LIBRT=FALSE \
            -B out/mac_arm64

cmake --build ./out/os64 --config RelWithDebInfo --parallel 8
cmake --build ./out/simulatorarm64 --config RelWithDebInfo --parallel 8
cmake --build ./out/mac_arm64 --config RelWithDebInfo --parallel 8

rm -rf libgRPCEchoServerCpp.xcframework

xcodebuild -create-xcframework \
  -library "out/os64/libgRPCEchoServerCpp.a" \
  -library "out/simulatorarm64/libgRPCEchoServerCpp.a" \
  -library "out/mac_arm64/libgRPCEchoServerCpp.a" \
  -output libgRPCEchoServerCpp.xcframework

# copy Header
mkdir -p libgRPCEchoServerCpp.xcframework/Headers
cp EchoServer.h libgRPCEchoServerCpp.xcframework/Headers