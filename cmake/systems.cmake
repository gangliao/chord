include(colorize)       # colorize and highlight message

IF(WIN32)
    SET(HOST_SYSTEM "win32")
ELSE(WIN32)
    IF(APPLE)
        EXEC_PROGRAM (sw_vers ARGS -productVersion OUTPUT_VARIABLE MACOSX_VERSION)
        STRING(REGEX MATCH "[0-9]+.[0-9]+" VERSION "${MACOSX_VERSION}")
        SET(MACOS_VERSION ${VERSION})
        SET(HOST_SYSTEM "macosx")
        IF(NOT DEFINED ENV{MACOSX_DEPLOYMENT_TARGET})
            # Set cache variable - end user may change this during ccmake or cmake-gui configure.
            SET(CMAKE_OSX_DEPLOYMENT_TARGET ${MACOS_VERSION} CACHE STRING
                "Minimum OS X version to target for deployment (at runtime); newer APIs weak linked. Set to empty string for default value.")
        ENDIF()
        set(CMAKE_EXE_LINKER_FLAGS "-framework CoreFoundation -framework Security")
    ELSE(APPLE)
        IF(EXISTS "/etc/issue")
            FILE(READ "/etc/issue" LINUX_ISSUE)
            IF(LINUX_ISSUE MATCHES "CentOS")
                SET(HOST_SYSTEM "centos")
            ELSEIF(LINUX_ISSUE MATCHES "Debian")
                SET(HOST_SYSTEM "debian")
            ELSEIF(LINUX_ISSUE MATCHES "Ubuntu")
                SET(HOST_SYSTEM "ubuntu")
            ELSEIF(LINUX_ISSUE MATCHES "Red Hat")
                SET(HOST_SYSTEM "redhat")
            ELSEIF(LINUX_ISSUE MATCHES "Fedora")
                SET(HOST_SYSTEM "fedora")
            ENDIF()
        ENDIF(EXISTS "/etc/issue")

        IF(EXISTS "/etc/redhat-release")
            FILE(READ "/etc/redhat-release" LINUX_ISSUE)
            IF(LINUX_ISSUE MATCHES "CentOS")
                SET(HOST_SYSTEM "centos")
            ENDIF()
        ENDIF(EXISTS "/etc/redhat-release")

        IF(NOT HOST_SYSTEM)
            SET(HOST_SYSTEM ${CMAKE_SYSTEM_NAME})
        ENDIF()

    ENDIF(APPLE)
ENDIF(WIN32)

# query number of logical cores
CMAKE_HOST_SYSTEM_INFORMATION(RESULT CPU_CORES QUERY NUMBER_OF_LOGICAL_CORES)

MARK_AS_ADVANCED(HOST_SYSTEM CPU_CORES)

MESSAGE(STATUS  "Chord: A Scalable Peer-to-Peer Lookup Protocol for Internet Applications")
MESSAGE(STATUS  "Found host system: ${HOST_SYSTEM}")
MESSAGE(STATUS  "Found host system's CPU: ${CPU_CORES} cores")

# external dependencies log output
SET(EXTERNAL_PROJECT_LOG_ARGS
    LOG_DOWNLOAD    0     # Wrap download in script to log output
    LOG_UPDATE      1     # Wrap update in script to log output
    LOG_CONFIGURE   1     # Wrap configure in script to log output
    LOG_BUILD       0     # Wrap build in script to log output
    LOG_TEST        1     # Wrap test in script to log output
    LOG_INSTALL     0     # Wrap install in script to log output
)
