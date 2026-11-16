enable_language(C)

option(ANYPS5_ICU_STUB_DATA "Build ICU without its data package, so exports that need ICU data throw" OFF)

if(ANYPS5_ICU_STUB_DATA)
    target_sources(icu_common PRIVATE ${ICU_SOURCE_DIR}/stubdata/stubdata.cpp)
else()
    find_package(Python3 COMPONENTS Interpreter)
    if(NOT Python3_Interpreter_FOUND)
        message(FATAL_ERROR "ICU data is built with Python 3 (icutools.databuilder). Install Python 3, or configure with -DANYPS5_ICU_STUB_DATA=ON")
    endif()

    function(icu_list_sources out directory)
        file(STRINGS "${ICU_SOURCE_DIR}/${directory}/sources.txt" names)
        set(files)
        foreach(name IN LISTS names)
            string(STRIP "${name}" name)
            if(NOT name STREQUAL "")
                list(APPEND files "${ICU_SOURCE_DIR}/${directory}/${name}")
            endif()
        endforeach()
        set(${out} ${files} PARENT_SCOPE)
    endfunction()

    file(STRINGS "${ICU_SOURCE_DIR}/common/unicode/uvernum.h" icuMajorLine REGEX "^#define U_ICU_VERSION_MAJOR_NUM ")
    string(REGEX REPLACE "^#define U_ICU_VERSION_MAJOR_NUM ([0-9]+).*$" "\\1" ICU_MAJOR "${icuMajorLine}")
    set(ICU_DATA_ENTRY "icudt${ICU_MAJOR}")
    set(ICU_DATA_NAME "icudt${ICU_MAJOR}l")

    icu_list_sources(ICU_HOST_COMMON_SOURCES common)
    list(APPEND ICU_HOST_COMMON_SOURCES ${ICU_SOURCE_DIR}/stubdata/stubdata.cpp)
    add_library(icu_host_common STATIC EXCLUDE_FROM_ALL ${ICU_HOST_COMMON_SOURCES})
    target_include_directories(icu_host_common SYSTEM PUBLIC ${ICU_SOURCE_DIR}/common)
    target_compile_definitions(icu_host_common PUBLIC U_STATIC_IMPLEMENTATION PRIVATE U_COMMON_IMPLEMENTATION)
    target_compile_features(icu_host_common PUBLIC cxx_std_17)

    icu_list_sources(ICU_HOST_I18N_SOURCES i18n)
    add_library(icu_host_i18n STATIC EXCLUDE_FROM_ALL ${ICU_HOST_I18N_SOURCES})
    target_include_directories(icu_host_i18n SYSTEM PUBLIC ${ICU_SOURCE_DIR}/i18n)
    target_compile_definitions(icu_host_i18n PRIVATE U_I18N_IMPLEMENTATION)
    target_link_libraries(icu_host_i18n PUBLIC icu_host_common)

    icu_list_sources(ICU_HOST_IO_SOURCES io)
    add_library(icu_host_io STATIC EXCLUDE_FROM_ALL ${ICU_HOST_IO_SOURCES})
    target_include_directories(icu_host_io SYSTEM PUBLIC ${ICU_SOURCE_DIR}/io)
    target_compile_definitions(icu_host_io PRIVATE U_IO_IMPLEMENTATION)
    target_link_libraries(icu_host_io PUBLIC icu_host_i18n)

    icu_list_sources(ICU_HOST_TOOLUTIL_SOURCES tools/toolutil)
    add_library(icu_host_toolutil STATIC EXCLUDE_FROM_ALL ${ICU_HOST_TOOLUTIL_SOURCES})
    target_include_directories(icu_host_toolutil SYSTEM PUBLIC ${ICU_SOURCE_DIR}/tools/toolutil)
    target_compile_definitions(icu_host_toolutil PRIVATE U_TOOLUTIL_IMPLEMENTATION)
    target_link_libraries(icu_host_toolutil PUBLIC icu_host_io)

    set(ICU_TOOL_DIR "${CMAKE_BINARY_DIR}/icu-tools")
    set(ICU_TOOLS genrb icupkg genccode pkgdata gencfu gencnval gendict genbrk gensprep makeconv)
    set(ICU_TOOL_TARGETS)
    foreach(tool IN LISTS ICU_TOOLS)
        icu_list_sources(toolSources tools/${tool})
        add_executable(icu_tool_${tool} EXCLUDE_FROM_ALL ${toolSources})
        set_target_properties(icu_tool_${tool} PROPERTIES OUTPUT_NAME ${tool} RUNTIME_OUTPUT_DIRECTORY "${ICU_TOOL_DIR}")
        target_include_directories(icu_tool_${tool} PRIVATE ${ICU_SOURCE_DIR}/tools/${tool})
        target_link_libraries(icu_tool_${tool} PRIVATE icu_host_toolutil)
        list(APPEND ICU_TOOL_TARGETS icu_tool_${tool})
    endforeach()

    set(ICU_DATA_BUILD "${CMAKE_BINARY_DIR}/icu-data")
    set(ICU_DATA_OUT "${ICU_DATA_BUILD}/${ICU_DATA_NAME}")
    set(ICU_DATA_TMP "${ICU_DATA_BUILD}/tmp")
    set(ICU_DATA_PACKAGE "${ICU_DATA_TMP}/${ICU_DATA_NAME}.dat")
    set(ICU_DATA_C "${ICU_DATA_BUILD}/${ICU_DATA_NAME}_dat.c")

    add_custom_command(
        OUTPUT "${ICU_DATA_PACKAGE}" "${ICU_DATA_TMP}/icudata.lst"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${ICU_DATA_OUT}" "${ICU_DATA_TMP}"
        COMMAND ${CMAKE_COMMAND} -E env "PYTHONPATH=${ICU_SOURCE_DIR}/python" "ICU_DATA=${ICU_DATA_BUILD}"
            "${Python3_EXECUTABLE}" -m icutools.databuilder --mode unix-exec
            --src_dir "${ICU_SOURCE_DIR}/data" --out_dir "${ICU_DATA_OUT}"
            --tmp_dir "${ICU_DATA_TMP}" --tool_dir "${ICU_TOOL_DIR}"
        COMMAND ${CMAKE_COMMAND} -E env "ICU_DATA=${ICU_DATA_BUILD}"
            "${ICU_TOOL_DIR}/pkgdata" -m common -p "${ICU_DATA_NAME}" -c
            -s "${ICU_DATA_OUT}" -d "${ICU_DATA_TMP}" "${ICU_DATA_TMP}/icudata.lst"
        DEPENDS ${ICU_TOOL_TARGETS}
        COMMENT "Building the ICU data package ${ICU_DATA_NAME}.dat")

    add_custom_command(
        OUTPUT "${ICU_DATA_C}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${ICU_DATA_BUILD}"
        COMMAND "${ICU_TOOL_DIR}/genccode" -e "${ICU_DATA_ENTRY}" -d "${ICU_DATA_BUILD}" "${ICU_DATA_PACKAGE}"
        DEPENDS "${ICU_DATA_PACKAGE}" ${ICU_TOOL_TARGETS}
        COMMENT "Generating C source for the ICU data package")

    add_library(icu_data STATIC EXCLUDE_FROM_ALL "${ICU_DATA_C}")
    target_include_directories(icu_data SYSTEM PRIVATE ${ICU_SOURCE_DIR}/common)
    set_target_properties(icu_data PROPERTIES POSITION_INDEPENDENT_CODE ON)
    target_link_libraries(icu_common PUBLIC icu_data)
endif()
