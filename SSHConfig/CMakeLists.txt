cmake_minimum_required(VERSION 3.15)

project(SSHConfig VERSION 0.1.2 LANGUAGES CXX)

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


# Set build type
if(CMAKE_BUILD_TYPE STREQUAL "")
    set(CMAKE_BUILD_TYPE "Release")
endif()


# Show message, Debug or Release.
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message("")
    message("SSHConfig : Debug Build.")
    message("")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    message("")
    message("SSHConfig : Release Build.")
    message("")
endif()


# Set Default Install Directory
if(CMAKE_INSTALL_PREFIX STREQUAL "")
    set(CMAKE_INSTALL_PREFIX "/usr/local" CACHE PATH "Installation directory")
endif()


# Use pkg-config
find_package(PkgConfig REQUIRED)


# Check Qt Package Config files
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Gui Widgets DBus Quick QuickControls2 LinguistTools)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Widgets DBus Quick QuickControls2 LinguistTools)
pkg_check_modules(QT_CORE   Qt${QT_VERSION_MAJOR}Core REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_GUI    Qt${QT_VERSION_MAJOR}Gui REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_Widget Qt${QT_VERSION_MAJOR}Widgets REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_DBUS   Qt${QT_VERSION_MAJOR}DBus REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_QUICK  Qt${QT_VERSION_MAJOR}Quick REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_QUICKCONTTOLS2  Qt${QT_VERSION_MAJOR}QuickControls2 REQUIRED IMPORTED_TARGET)


# Check if Qt version is greater than or equal to 5.15.0
if(QT_VERSION VERSION_LESS 5.15.0)
    message(FATAL_ERROR "Qt version must be greater than or equal to 5.15.0")
endif()


# Find Library and Include: libRemoteWindow.so
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    find_library(REMOTEWINDOW_LIB NAMES RemoteWindow HINTS ${CMAKE_CURRENT_SOURCE_DIR}/../RemoteWindow/Debug)
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    find_library(REMOTEWINDOW_LIB NAMES RemoteWindow HINTS ${CMAKE_CURRENT_BINARY_DIR}/RemoteWindow)
endif()


# Translate File
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig_ja_JP.ts")
  # If exist ts file.
  set(TS_FILES SSHConfig_ja_JP.ts)
else()
  # If not exist ts file.
  set(TS_FILES "")
  message("\nNot Translation\n")
endif()


# Source Files
set(SOURCES
    qml.qrc
    main.cpp
    CWindowState.cpp
    CSSHServer.cpp
    CSSHValue.cpp
    CSSHService.cpp
    CSSHTest.cpp
    ${TS_FILES}
)


# Header Files
set(HEADERS
    CWindowState.h
    CSSHServer.h
    CSSHValue.h
    CSSHService.h
    CSSHTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../RemoteWindow/CRemoteWindow.h
)


# Image Files
#file(GLOB IMAGE_FILES "Image/*")


if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(SSHConfig MANUAL_FINALIZATION
        ${SOURCES}
        ${HEADERS}
        ${IMAGE_FILES}
    )

    qt_create_translation(QM_FILES
        ${CMAKE_SOURCE_DIR}
        ${TS_FILES}
    )
else()
    add_executable(SSHConfig
        qtquickcontrols2.conf
        ${SOURCES}
        ${HEADERS}
        ${IMAGE_FILES}
    )

    qt5_create_translation(QM_FILES
        ${CMAKE_SOURCE_DIR}
        ${TS_FILES}
    )
endif()


# Link Qt Libraries
target_link_libraries(SSHConfig PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::DBus
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::QuickControls2
)


# Link libRemoteWindow Library
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_link_libraries(SSHConfig PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/../RemoteWindow/Debug/libRemoteWindow.so
    )
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_link_libraries(SSHConfig PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/RemoteWindow/libRemoteWindow.so
    )
endif()


# Add Include libRemoteWindow Header files
target_include_directories(SSHConfig BEFORE
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../RemoteWindow
)


# Pre-Processor
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(SSHConfig PRIVATE _DEBUG)
endif()

target_compile_definitions(SSHConfig PRIVATE VER="0.1.2")


# Compile option
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(SSHConfig PRIVATE
        -O3
    )
endif()


# Install
install(TARGETS SSHConfig
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(SSHConfig)
    qt_finalize_executable(SSHConfig)
endif()
