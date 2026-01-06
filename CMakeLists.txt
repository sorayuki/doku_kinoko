cmake_minimum_required(VERSION 3.10)
project(doku)

set(CMAKE_CXX_STANDARD 17)


if(WIN32)
    # Include directories
    include_directories(${CMAKE_SOURCE_DIR}/third_party/include)

    # Library directories
    link_directories(${CMAKE_SOURCE_DIR}/third_party/lib)

    # Source files
    set(SOURCES
        main_win.cpp
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
elseif(APPLE)
    # Include directories
    include_directories(${CMAKE_SOURCE_DIR}/third_party/include)
    
    # Source files
    set(SOURCES
        main_macos.mm
    )
    
    # Compile object only, do not link since we don't have libs
    add_library(doku OBJECT ${SOURCES})
endif()

