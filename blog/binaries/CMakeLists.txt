cmake_minimum_required(VERSION 3.0)

project(HelloWorld)

# Spécifiez le répertoire où les exécutables seront mis
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/binaries)

add_executable(hello main.c)
