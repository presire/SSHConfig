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


# Dependency Library
add_subdirectory(RemoteWindow)


# Helper binary
add_subdirectory(SSHConfigHelper)


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
find_library(REMOTEWINDOW_LIB NAMES RemoteWindow HINTS ${CMAKE_CURRENT_BINARY_DIR}/RemoteWindow)


# Translate File
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig/SSHConfig_ja_JP.ts")
    # If exist ts file.
    set(TS_FILES
        "${CMAKE_SOURCE_DIR}/SSHConfig/SSHConfig_ja_JP.ts"
    )

    #set_source_files_properties(${TS_FILES}
        #PROPERTIES OUTPUT_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig"
    #)
else()
    # If not exist ts file.
    set(TS_FILES
        ""
    )

    message("\nNot Translation\n")
endif()


# Source Files
set(SOURCES
    SSHConfig/main.cpp
    SSHConfig/CWindowState.cpp
    SSHConfig/CSSHServer.cpp
    SSHConfig/CSSHValue.cpp
    SSHConfig/CSSHService.cpp
    SSHConfig/CSSHTest.cpp
    SSHConfig/SSHConfig.qrc
    ${TS_FILES}
)


# Header Files
set(HEADERS
    SSHConfig/CWindowState.h
    SSHConfig/CSSHServer.h
    SSHConfig/CSSHValue.h
    SSHConfig/CSSHService.h
    SSHConfig/CSSHTest.h
    RemoteWindow/CRemoteWindow.h
)


if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_create_translation(QM_FILES
        ${CMAKE_SOURCE_DIR}/SSHConfig
        ${TS_FILES}
    )

    qt_add_executable(SSHConfig MANUAL_FINALIZATION
        SSHConfig/qtquickcontrols2.conf
        ${SOURCES}
        ${HEADERS}
        ${QM_FILES}
    )
else()
    qt5_create_translation(QM_FILES
        ${CMAKE_SOURCE_DIR}/SSHConfig
        ${TS_FILES}
    )

    add_executable(SSHConfig
        SSHConfig/qtquickcontrols2.conf
        ${SOURCES}
        ${HEADERS}
        ${QM_FILES}
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
target_link_libraries(SSHConfig PRIVATE
    RemoteWindow
)


# Add Include libRemoteWindow Header files
target_include_directories(SSHConfig BEFORE PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/RemoteWindow
)


# Pre-Processor
## for Debug
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(SSHConfig PRIVATE _DEBUG)
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
            target_compile_definitions(SSHConfig PUBLIC PINEPHONE)
        else()
            message(FATAL_ERROR "\nThe compiler you are using is not for AArch64. PinePhone is for AArch64.\n")
        endif()
    elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
        message("\nYou can build this software for PinePhone.\n")
        target_compile_definitions(SSHConfig PUBLIC PINEPHONE)
    endif()
else()
    if(NOT "${MACHINE}" STREQUAL "")
        message(FATAL_ERROR "\nThe \"machine\" option can be \"pinephone\" or \"PINEPHONE\".\n")
    else()
        message("\nYou will be compile PC.\n")
    endif()
endif()

## for Version
target_compile_definitions(SSHConfig PRIVATE VER="0.1.2")


# Compile option
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(SSHConfig PRIVATE
        -O3
    )
endif()


# Get path to home directory
set(HOME $ENV{HOME})


# Install Execute Binary
install(TARGETS SSHConfig
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)


# Install SSHConfig wrapper script file.
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig/Scripts/SSHConfig.sh.in
               ${CMAKE_CURRENT_BINARY_DIR}/SSHConfig.sh
               @ONLY
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/SSHConfig.sh
    DESTINATION "${CMAKE_INSTALL_PREFIX}/bin/"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ WORLD_READ
)


# Install QM Files
#install(FILES
    #${QM_FILES}
    #DESTINATION "${HOME}/.config/SSHConfig/Translation"
#)


# Install D-Bus Configuration file (for System Bus)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig/dbus/org.presire.sshconfig.conf.in
               ${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.conf
)

if(${CMAKE_INSTALL_PREFIX} STREQUAL "/usr/local" OR "${CMAKE_INSTALL_PREFIX}" MATCHES "^/usr/local(/*)$")
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.conf
        DESTINATION "/usr/share/dbus-1/system.d"
    )
else()
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.conf
        DESTINATION "${CMAKE_INSTALL_PREFIX}/share/dbus-1/system.d"
    )
endif()


# Install D-Bus Auto-Start file
#set(install_dir CMAKE_INSTALL_PREFIX)
#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig/dbus/org.presire.sshconfig.service.in
               #${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.service
               #@ONLY
#)

# Load File
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig/dbus/org.presire.sshconfig.service.in" input_file_content)
# Replace specified characters
string(REPLACE "%install_dir%" "${CMAKE_INSTALL_PREFIX}" output_file_content "${input_file_content}")
# Write File
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.service" "${output_file_content}")

if(${CMAKE_INSTALL_PREFIX} STREQUAL "/usr/local" OR "${CMAKE_INSTALL_PREFIX}" MATCHES "^/usr/local(/*)$")
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.service
        DESTINATION "/usr/share/dbus-1/system-services"
    )
else()
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.service
        DESTINATION "${CMAKE_INSTALL_PREFIX}/share/dbus-1/system-services"
    )
endif()


# Install Polkit File
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig/polkit/org.presire.sshconfig.policy.in
               ${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.policy
)

if(${CMAKE_INSTALL_PREFIX} STREQUAL "/usr/local" OR "${CMAKE_INSTALL_PREFIX}" MATCHES "^/usr/local(/*)$")
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.policy
        DESTINATION "/usr/share/polkit-1/actions"
    )
else()
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.policy
        DESTINATION "${CMAKE_INSTALL_PREFIX}/share/polkit-1/actions"
    )
endif()


# Install Icon File
if(${CMAKE_INSTALL_PREFIX} STREQUAL "/usr/local" OR "${CMAKE_INSTALL_PREFIX}" MATCHES "^/usr/local(/*)$")
    install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig/Image/SSHConfig.png
        DESTINATION "/usr/share/icons/hicolor/128x128/apps"
    )
    install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig/Image/SSHConfig.svg
        DESTINATION "/usr/share/icons/hicolor/scalable/apps"
    )
else()
    install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig/Image/SSHConfig.png
        DESTINATION "${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/128x128/apps"
    )
    install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig/Image/SSHConfig.svg
        DESTINATION "${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps"
    )
endif()


# Install Desktop Entry File
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/SSHConfig/DeskopEntry/SSHConfig.desktop.in" input_file_content)
# Replace specified characters
string(REPLACE "%install_dir%" "${CMAKE_INSTALL_PREFIX}" output_file_content "${input_file_content}")
string(REPLACE "%ver%" "${CMAKE_PROJECT_VERSION}" output_file_content "${output_file_content}")
# Write File
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/SSHConfig.desktop" "${output_file_content}")

if(${CMAKE_INSTALL_PREFIX} STREQUAL "/usr/local" OR "${CMAKE_INSTALL_PREFIX}" MATCHES "^/usr/local/+$")
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/SSHConfig.desktop
        DESTINATION "/usr/share/applications"
    )
else()
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/SSHConfig.desktop
        DESTINATION "${CMAKE_INSTALL_PREFIX}/share/applications"
    )
endif()


if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(SSHConfig)
    qt_finalize_executable(SSHConfig)
endif()
