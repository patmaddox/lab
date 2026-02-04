# Example CMake file

cmake_minimum_required(VERSION 3.16)

project(Example
  VERSION 1.0.0
  DESCRIPTION "Example project"
  LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

option(BUILD_TESTS "Build test suite" ON)

find_package(Threads REQUIRED)

add_library(example_lib
  src/example.c
  src/helper.c
)

target_include_directories(example_lib PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/include
)

add_executable(example
  src/main.c
)

target_link_libraries(example
  PRIVATE example_lib
  PRIVATE Threads::Threads
)

if(BUILD_TESTS)
  enable_testing()
  add_subdirectory(tests)
endif()

install(TARGETS example
  RUNTIME DESTINATION bin
)
