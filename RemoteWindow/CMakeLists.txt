cmake_minimum_required(VERSION 3.15)

project(RemoteWindow VERSION 0.1.0 LANGUAGES CXX)

# Build only Linux distribution
if(NOT (UNIX AND NOT APPLE) OR ANDROID OR IOS)
    message(FATAL_ERROR "ERROR! Only Linux can build this software.")
else()
    set(LINUX TRUE)
endif()

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Required Qt 5.15 at least.
set(QT_MINIMUM_VERSION "5.15")

# "Enable C++ Exceptions" - "Yes (/EHsc)" => "Yes with SEH Exceptions (/EHa)"
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHa" CACHE STRING "CXX Exception Option" FORCE)
string(REPLACE "/EHsc" "/EHa" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

# "Basic Run-time checks" - "Both (/RTC1, equiv. to /RTCsu) (/RTC1)" => "Default"
#string(REPLACE "/RTC1" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")

# Used to create CMake config files
include(CMakePackageConfigHelpers)

# Used to generate export headers
include(GenerateExportHeader)

# Used to set installation paths
include(GNUInstallDirs)

include(FeatureSummary)


# Version
set(PROJECT_VERSION 0.1.0)
set(PROJECT_SOVERSION 0)


# Set build type
if(CMAKE_BUILD_TYPE STREQUAL "")
    set(CMAKE_BUILD_TYPE "Release")
endif()


# Show message, Debug or Release.
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message("")
    message("RemoteWindow Library : Debug Build.")
    message("")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    message("")
    message("RemoteWindow Library : Release Build.")
    message("")
endif()


# Set Default Install Directory
if(CMAKE_INSTALL_PREFIX STREQUAL "")
    set(CMAKE_INSTALL_PREFIX "/usr/local" CACHE PATH "Installation directory")
endif()


# Use pkg-config
find_package(PkgConfig REQUIRED)


# Check Qt Package Config files
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Gui Quick QuickControls2 Network LinguistTools)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Quick QuickControls2 Network LinguistTools)
pkg_check_modules(QT_CORE     Qt${QT_VERSION_MAJOR}Core    REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_GUI      Qt${QT_VERSION_MAJOR}Gui     REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_QUICK    Qt${QT_VERSION_MAJOR}Quick   REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_QUICKCONTTOLS2  Qt${QT_VERSION_MAJOR}QuickControls2 REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_NETWORK  Qt${QT_VERSION_MAJOR}Network REQUIRED IMPORTED_TARGET)


# Check if Qt version is greater than or equal to 5.15.0
if(QT_VERSION VERSION_LESS 5.15.0)
    message(FATAL_ERROR "Qt version must be greater than or equal to 5.15.0")
endif()


# Translate File
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/RemoteWindow_ja_JP.ts")
    # If exist ts file.
    set(TS_FILES RemoteWindow_ja_JP.ts)
else()
    # If not exist ts file.
    set(TS_FILES "")
    message("\nNot Translation\n")
endif()


# Source Files
set(SOURCES
    RemoteWindow.qrc
    CRemoteWindow.cpp
    CClient.cpp
    ${TS_FILES}
)


# Header Files
set(HEADERS
    RemoteWindowExport.h
    CRemoteWindow.h
    CClient.h
    CWindowState.h
)


# Image Files
file(GLOB IMAGE_FILES "Image/*.png" "Image/*.svg")


if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_create_translation(QM_FILES
        ${CMAKE_SOURCE_DIR} ${TS_FILES}
    )

    qt_add_library(RemoteWindow SHARED MANUAL_FINALIZATION
        qtquickcontrols2.conf
        ${SOURCES}
        ${QM_FILES}
        ${IMAGE_FILES}
    )
else()
    qt5_create_translation(QM_FILES
        ${CMAKE_SOURCE_DIR}
        ${TS_FILES}
    )

    add_library(RemoteWindow SHARED
        qtquickcontrols2.conf
        ${SOURCES}
        ${QM_FILES}
        ${IMAGE_FILES}
    )
endif()


# Add other source directories
target_sources(RemoteWindow PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/../SSHConfig/CWindowState.cpp"
)


# Add other include directories
target_include_directories(RemoteWindow BEFORE PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../SSHConfig
)


# Pre-Processor
## for Debug
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(RemoteWindow PRIVATE _DEBUG)
endif()

## for PinePhone
string(TOUPPER "${MACHINE}" MACHINE)
if(MACHINE STREQUAL "PINEPHONE")
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        if(NOT "${CMAKE_CXX_FLAGS}" MATCHES "^.*-march[= ]arm([^ ]+).*$")
            execute_process(COMMAND "uname -m" RESULT_VARIABLE ARCH)

            if(NOT "${ARCH}" STREQUAL "aarch64")
                message(FATAL_ERROR "\nThe compiler you are using is not for AArch64. PinePhone is for AArch64.\n")
            endif()

            message("\nYou can build this software for PinePhone.\n")
            target_compile_definitions(RemoteWindow PUBLIC PINEPHONE)
        else()
            message(FATAL_ERROR "\nThe compiler you are using is not for AArch64. PinePhone is for AArch64.\n")
        endif()
    elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
        message("\nYou can build this software for PinePhone.\n")
        target_compile_definitions(RemoteWindow PUBLIC PINEPHONE)
    endif()
else()
    if(NOT "${MACHINE}" STREQUAL "")
        message(FATAL_ERROR "\nThe \"machine\" option can be \"pinephone\" or \"PINEPHONE\".\n")
    else()
        message("\nYou will be compile PC.\n")
    endif()
endif()

## for Version
target_compile_definitions(RemoteWindow PRIVATE VER="0.1.0")


# Link Qt Libraries
target_link_libraries(RemoteWindow PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::QuickControls2
    Qt${QT_VERSION_MAJOR}::Network
)


# Compile option
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(RemoteWindow PRIVATE
        -O3
    )
endif()


# Version
set_target_properties(RemoteWindow PROPERTIES
    EXPORT_NAME RemoteWindow
    VERSION   ${PROJECT_VERSION}
    SOVERSION ${PROJECT_SOVERSION}
)


# Install
install(TARGETS RemoteWindow
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)


if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(RemoteWindow)
    qt_finalize_executable(RemoteWindow)
endif()
