cmake_minimum_required(VERSION 3.19)
project(gRPCEchoServerCpp)

set(CMAKE_CXX_STANDARD 17)

include(FetchContent)
FetchContent_Declare(
        gRPC
        GIT_REPOSITORY https://github.com/grpc/grpc
        GIT_TAG v1.38.0
)
set(FETCHCONTENT_QUIET OFF)
FetchContent_MakeAvailable(gRPC)

add_library(gRPCEchoServerCpp EchoServer.h generated/Model.grpc.pb.cc generated/Model.pb.cc)
add_executable(start Cli.cpp generated/Model.pb.cc generated/Model.grpc.pb.cc)

target_include_directories(gRPCEchoServerCpp PUBLIC generated)

target_link_libraries(gRPCEchoServerCpp grpc++)
target_link_libraries(start grpc++)