cmake_minimum_required(VERSION 3.10)
project(doku)

set(CMAKE_CXX_STANDARD 17)

# Include directories
include_directories(${CMAKE_SOURCE_DIR}/third_party/include)

# Library directories
link_directories(${CMAKE_SOURCE_DIR}/third_party/lib)

# Source files
set(SOURCES
    main.cpp
    doku.cpp
)

# Executable
add_executable(doku ${SOURCES})

# Link libraries
target_link_libraries(doku
    libEGL
    libGLESv2
    zlib
)

# Copy DLLs to output directory
add_custom_command(TARGET doku POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/third_party/bin/libEGL.dll"
        "$<TARGET_FILE_DIR:doku>"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/third_party/bin/libGLESv2.dll"
        "$<TARGET_FILE_DIR:doku>"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/third_party/bin/zlib1.dll"
        "$<TARGET_FILE_DIR:doku>"
)

# Generate .gitignore in binary directory to ignore all files there
file(WRITE ${CMAKE_BINARY_DIR}/.gitignore "*")
