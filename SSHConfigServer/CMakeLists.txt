cmake_minimum_required(VERSION 3.15)

project(SSHConfigServer VERSION 0.1.0 LANGUAGES CXX)

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
set(QT_MINIMUM_VERSION 5.15)

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
    message("SSHConfigServer Library : Debug Build.")
    message("")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    message("")
    message("SSHConfigServer Library : Release Build.")
    message("")
endif()


# Set Default Install Directory
if(CMAKE_INSTALL_PREFIX STREQUAL "")
    set(CMAKE_INSTALL_PREFIX "/usr/local" CACHE PATH "Installation directory")
endif()


# Use pkg-config
find_package(PkgConfig REQUIRED)


# Set Qt
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core DBus Network LinguistTools)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core DBus Network LinguistTools)


# Check Qt Package Config files
pkg_check_modules(QT_CORE     Qt${QT_VERSION_MAJOR}Core REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_DBUS     Qt${QT_VERSION_MAJOR}DBus REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_NETWORK  Qt${QT_VERSION_MAJOR}Network REQUIRED IMPORTED_TARGET)


# Check if Qt version is greater than or equal to 5.15.0
if(QT_VERSION VERSION_LESS 5.15.0)
    message(FATAL_ERROR "Qt version must be greater than or equal to 5.15.0")
endif()


# Find Library and Include: libbsd
#if(WITH_LIBBSD_DIR)
    #With "-DWITH_LIBBSD_DIR" Option
    #message("\nManually specified libbsd Directory : ${WITH_LIBBSD_DIR}\n")

    #find_library(LIBBSD_LIB NAMES bsd HINTS ${WITH_LIBBSD_DIR}/lib64 ${WITH_LIBBSD_DIR}/lib)

    #if(${LIBBSD_LIB})
        #message(FATAL_ERROR "ERROR! Not found libbsd library.")
    #endif()

    #message("found : ${LIBBSD_LIB}")

    #set(LIBBSD_INCLUDE ${WITH_LIBBSD_DIR}/include)
#else()
    #Using pkg-config: libbsd
    #pkg_check_modules(LIBBSD REQUIRED libbsd REQUIRED IMPORTED_TARGET)

    #if(${LIBBSD_FOUND} EQUAL 0)
        #message(FATAL_ERROR "ERROR! Not found libbsd library.")
    #endif()
#endif(WITH_LIBBSD_DIR)


# Translate File
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/SSHConfigServer_ja_JP.ts")
    # If exist ts file.
    set(TS_FILES
        "${CMAKE_SOURCE_DIR}/SSHConfigServer_ja_JP.ts"
    )

    set_source_files_properties(${TS_FILES} PROPERTIES
        OUTPUT_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/i18n"
    )
else()
    # If not exist ts file.
    set(TS_FILES
        ""
    )

    message("\nNot Translation\n")
endif()


# Source Files
set(SOURCES
    main.cpp
    CUIRunner.cpp
    CServer.cpp
    CSSLSocket.cpp
    SSHConfigServer.qrc
    ${TS_FILES}
)


# Header Files
set(HEADERS
    CUIRunner.h
    CServer.h
    CSSLSocket.h
)


if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_create_translation(QM_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${TS_FILES}
    )

    qt_add_executable(SSHConfigServer MANUAL_FINALIZATION
        ${SOURCES}
        ${HEADERS}
        ${QM_FILES}
        #${LIBBSD_INCLUDE}
    )
else()
    qt5_create_translation(QM_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${TS_FILES}
    )

    add_executable(SSHConfigServer
        ${SOURCES}
        ${HEADERS}
        ${QM_FILES}
        #${LIBBSD_INCLUDE}
    )
endif()


# Link Qt Libraries
target_link_libraries(SSHConfigServer PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::DBus
    Qt${QT_VERSION_MAJOR}::Network
)


# Link libbsd libraries
#if(WITH_LIBBSD_DIR)
    #target_link_libraries(SSHConfigServer PRIVATE
        #${LIBBSD_LIB}
    #)
#else()
    #target_link_libraries(SSHConfigServer PRIVATE
        #${LIBBSD_LIBRARIES}
    #)
#endif(WITH_LIBBSD_DIR)


# Include libbsd header files
#if(WITH_LIBBSD_DIR)
    #target_include_directories(SSHConfigServer PRIVATE
        #${LIBBSD_INCLUDE}
    #)
#endif(WITH_LIBBSD_DIR)


# Pre-Processor
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(SSHConfigServer PRIVATE _DEBUG)
endif()

target_compile_definitions(SSHConfigServer PRIVATE VER="0.1.0")


# Compile option
#target_compile_options(SSHConfigServer PRIVATE
    #${LIBBSD_CFLAGS}
#)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(SSHConfigServer PRIVATE
        -O3
    )
endif()


# Install
install(TARGETS SSHConfigServer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)


# Install Server Configuration file
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/etc/sshconfig.json.in
               ${CMAKE_CURRENT_BINARY_DIR}/sshconfig.json
)

if("${SYSCONFDIR}" STREQUAL "")
    set(SYSCONFDIR "/etc/sshconfig")
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/sshconfig.json
        DESTINATION "/etc/sshconfig"
    )
else()
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/sshconfig.json
        DESTINATION "${SYSCONFDIR}"
    )
endif()


# Install systemd File
if("${USER}" STREQUAL "")
    set(USER "root")
endif()

if("${GROUP}" STREQUAL "")
    set(GROUP "root")
endif()

if("${PID}" STREQUAL "")
    set(PID "/var/run")
endif()

file(READ "${CMAKE_CURRENT_SOURCE_DIR}/etc/sshconfigd.service.in" input_file_content)
# Replace specified characters
string(REPLACE "%user%" "${USER}" output_file_content "${input_file_content}")
string(REPLACE "%group%" "${GROUP}" output_file_content "${output_file_content}")
string(REPLACE "%pid_dir%" "${PID}" output_file_content "${output_file_content}")
string(REPLACE "%install_dir%" "${CMAKE_INSTALL_PREFIX}" output_file_content "${output_file_content}")
string(REPLACE "%sysconf_dir%" "${SYSCONFDIR}" output_file_content "${output_file_content}")
# Write File
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/sshconfigd.service" "${output_file_content}")

if("${SYSTEMD}" STREQUAL "")
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/sshconfigd.service
        DESTINATION "/etc/systemd/system"
    )
else()
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/sshconfigd.service
        DESTINATION "${SYSTEMD}"
    )
endif()


if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(SSHConfigServer)
endif()
