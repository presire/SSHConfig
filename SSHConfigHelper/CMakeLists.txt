cmake_minimum_required(VERSION 3.15)

project(SSHConfigHelper VERSION 0.1.0 LANGUAGES CXX)

# Build only Linux distribution
if(NOT (UNIX AND NOT APPLE) OR ANDROID OR IOS)
    message(FATAL_ERROR "ERROR! Only Linux can build this software.")
else()
    set(LINUX TRUE)
endif()

set(CMAKE_INCLUDE_CURRENT_DIR ON)

#set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)

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
    message("SSHConfigHelper : Debug Build.")
    message("")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    message("")
    message("SSHConfigHelper : Release Build.")
    message("")
endif()


# Set Default Install Directory
if(CMAKE_INSTALL_PREFIX STREQUAL "")
    set(CMAKE_INSTALL_PREFIX "/usr/local" CACHE PATH "Installation directory")
endif()


# Use pkg-config
find_package(PkgConfig REQUIRED)

# Set Qt
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core DBus Xml LinguistTools)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core DBus Xml LinguistTools)

# Check Qt Package Config files
pkg_check_modules(QT_CORE Qt${QT_VERSION_MAJOR}Core REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_DBUS Qt${QT_VERSION_MAJOR}DBus REQUIRED IMPORTED_TARGET)
pkg_check_modules(QT_XML  Qt${QT_VERSION_MAJOR}Xml REQUIRED IMPORTED_TARGET)


# Check if Qt version is greater than or equal to 5.15.0
if(QT_VERSION VERSION_LESS 5.15.0)
    message(FATAL_ERROR "Qt version must be greater than or equal to 5.15.0")
endif()


# Find Library and Include: polkit-qt-core-1, polkit-qt-agent-1
if(WITH_POLQT_DIR)
   # With "-DWITH_POLQT_DIR" Option
   message("\nManually specified PolKit-Qt${QT_VERSION_MAJOR}-1 Directory : ${WITH_POLQT_DIR}\n")

   find_library(POLKIT_QT_CORE_LIB  NAMES polkit-qt${QT_VERSION_MAJOR}-core-1  HINTS ${WITH_POLQT_DIR}/lib64 ${WITH_POLQT_DIR}/lib)
   find_library(POLKIT_QT_AGENT_LIB NAMES polkit-qt${QT_VERSION_MAJOR}-agent-1 HINTS ${WITH_POLQT_DIR}/lib64 ${WITH_POLQT_DIR}/lib)

   if(${POLKIT_QT_CORE_LIB} OR ${POLKIT_QT_AGENT_LIB})
      message(FATAL_ERROR "ERROR! Not found polkit-qt${QT_VERSION_MAJOR}-core-1, polkit-qt${QT_VERSION_MAJOR}-agent-1.")
   endif()

   message("found : ${POLKIT_QT_CORE_LIB}")
   message("found : ${POLKIT_QT_AGENT_LIB}\n")

   set(POLKIT_QT_INCLUDE ${WITH_POLQT_DIR}/include/polkit-qt${QT_VERSION_MAJOR}-1)
else()
   # Using pkg-config: polkit-qt-core-1, polkit-qt-agent-1
   pkg_check_modules(POLKIT_QT       polkit-qt${QT_VERSION_MAJOR}-1       REQUIRED IMPORTED_TARGET)
   pkg_check_modules(POLKIT_QT_CORE  polkit-qt${QT_VERSION_MAJOR}-core-1  REQUIRED IMPORTED_TARGET)
   pkg_check_modules(POLKIT_QT_AGENT polkit-qt${QT_VERSION_MAJOR}-agent-1 REQUIRED IMPORTED_TARGET)

   find_package(PolkitQt${QT_VERSION_MAJOR}-1 PATHS ${POLKIT_QT_LIBDIR}/cmake REQUIRED COMPONENTS Core Agent)
   if(${PolkitQt${QT_VERSION_MAJOR}-1_FOUND} EQUAL 0)
      message(FATAL_ERROR "ERROR! Not found polkit-qt${QT_VERSION_MAJOR}-core-1, polkit-qt${QT_VERSION_MAJOR}-agent-1.")
   endif()

   #find_library(POLKIT_QT_CORE_LIB  NAMES polkit-qt${QT_VERSION_MAJOR}-core-1  HINTS ${POLKIT_QT_CORE_LIBDIR} ${POLKIT_QT_CORE_LIBRARY_DIRS})
   #find_library(POLKIT_QT_AGENT_LIB NAMES polkit-qt${QT_VERSION_MAJOR}-agent-1 HINTS ${POLKIT_QT_AGENT_LIBDIR} ${POLKIT_QT_AGENT_LIBRARY_DIRS})

   #set(POLKIT_QT_INCLUDE ${POLKIT_QT_INCLUDE_DIRS})
endif(WITH_POLQT_DIR)


# Translate File
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/SSHConfigHelper_ja_JP.ts")
    # If exist ts file.
    set(TS_FILES
        "${CMAKE_SOURCE_DIR}/SSHConfigHelper_ja_JP.ts"
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
    SSHConfigHelper.cpp
    SSHConfigHelper.qrc
)


# Header Files
set(HEADERS
    SSHConfigHelper.h
)


# Create Helper Execute Adaptor Files
qt_add_dbus_adaptor(
    SSHConfigAdaptor_SRC
    org.presire.sshconfig.xml
    SSHConfigHelper.h
    SSHConfigHelper
    SSHConfigAdaptor
    SSHConfigAdaptor
)


if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_create_translation(QM_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${TS_FILES}
    )

    qt_add_executable(SSHConfigHelper MANUAL_FINALIZATION
        ${SOURCES}
        ${HEADERS}
        ${SSHConfigAdaptor_SRC}
    )
else()
    qt5_create_translation(QM_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${TS_FILES}
    )

    add_executable(SSHConfigHelper
        ${SOURCES}
        ${HEADERS}
        ${SSHConfigAdaptor_SRC}
    )
endif()


# Link Qt Libraries
target_link_libraries(SSHConfigHelper PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::DBus
    Qt${QT_VERSION_MAJOR}::Xml
)


# Link PolKit-Qt-1 Libraries
if(WITH_POLQT_DIR)
    target_link_libraries(SSHConfigHelper PRIVATE
        ${POLKIT_QT_CORE_LIB}
        ${POLKIT_QT_AGENT_LIB}
    )
else()
    target_link_libraries(SSHConfigHelper PRIVATE
        PolkitQt${QT_VERSION_MAJOR}-1::Core
        PolkitQt${QT_VERSION_MAJOR}-1::Agent
    )
endif(WITH_POLQT_DIR)


# Include PolKit-Qt-1 Header files
if(WITH_POLQT_DIR)
    target_include_directories(SSHConfigHelper PRIVATE
        ${POLKIT_QT_INCLUDE}
    )
endif(WITH_POLQT_DIR)


# Pre-Processor
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(SSHConfigHelper PRIVATE _DEBUG)
endif()

target_compile_definitions(SSHConfigHelper PRIVATE VER="0.1.0")


# Compile option
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(SSHConfigHelper PRIVATE
        ${POLKIT_QT_CFLAGS}
        -O3
    )
else()
    target_compile_options(SSHConfigHelper PRIVATE
        ${POLKIT_QT_CFLAGS}
    )
endif()


# Install
install(TARGETS SSHConfigHelper
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)


# Install D-Bus Interface file
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/dbus/org.presire.sshconfig.xml.in
               ${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.xml
)

string(TOUPPER "${DBUSIF}" DBUSIF)
if("${DBUSIF}" STREQUAL "YES")
    if(${CMAKE_INSTALL_PREFIX} STREQUAL "/usr/local")
        install(FILES
            ${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.xml
            DESTINATION "/usr/share/dbus-1/interfaces"
        )
    else()
        install(FILES
            ${CMAKE_CURRENT_BINARY_DIR}/org.presire.sshconfig.conf
            DESTINATION "${CMAKE_INSTALL_PREFIX}/share/dbus-1/interfaces"
        )
    endif()
endif()


if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(SSHConfigHelper)
    qt_finalize_executable(SSHConfigHelper)
endif()
