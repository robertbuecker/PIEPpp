cmake_minimum_required(VERSION 3.25)

project(PIEPModern LANGUAGES CXX)

option(PIEP_BUILD_PYTHON "Build pybind11-based Python bindings smoke target" ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Python3 COMPONENTS Interpreter Development REQUIRED)

function(piep_copy_mingw_runtime target_name)
    if(NOT MINGW)
        return()
    endif()

    get_filename_component(PIEP_COMPILER_BIN "${CMAKE_CXX_COMPILER}" DIRECTORY)
    foreach(runtime_name IN ITEMS libstdc++-6.dll libgcc_s_seh-1.dll libwinpthread-1.dll libquadmath-0.dll)
        set(runtime_path "${PIEP_COMPILER_BIN}/${runtime_name}")
        if(EXISTS "${runtime_path}")
            add_custom_command(
                TARGET "${target_name}" POST_BUILD
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                        "${runtime_path}"
                        "$<TARGET_FILE_DIR:${target_name}>"
            )
        endif()
    endforeach()
endfunction()

add_library(piep_core INTERFACE)
target_include_directories(
    piep_core
    INTERFACE
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
target_compile_features(piep_core INTERFACE cxx_std_20)

if(MSVC)
    target_compile_options(piep_core INTERFACE /W4 /permissive-)
else()
    target_compile_options(
        piep_core
        INTERFACE
            -Wall
            -Wextra
            -Wpedantic
            -Wconversion
            -Wshadow
    )
endif()

add_executable(piep_geometry_smoke examples/smoke_geometry.cpp)
target_link_libraries(piep_geometry_smoke PRIVATE piep_core)
piep_copy_mingw_runtime(piep_geometry_smoke)

add_executable(piep_geometry_tests tests/test_geometry.cpp)
target_link_libraries(piep_geometry_tests PRIVATE piep_core)
piep_copy_mingw_runtime(piep_geometry_tests)

add_test(NAME piep_geometry_tests COMMAND piep_geometry_tests)

add_executable(piep_pattern_tests tests/test_pattern_prep.cpp)
target_link_libraries(piep_pattern_tests PRIVATE piep_core)
piep_copy_mingw_runtime(piep_pattern_tests)

add_test(NAME piep_pattern_tests COMMAND piep_pattern_tests)

add_executable(piep_search_setup_tests tests/test_search_setup.cpp)
target_link_libraries(piep_search_setup_tests PRIVATE piep_core)
piep_copy_mingw_runtime(piep_search_setup_tests)

add_test(NAME piep_search_setup_tests COMMAND piep_search_setup_tests)

add_executable(piep_candidate_generation_tests tests/test_candidate_generation.cpp)
target_link_libraries(piep_candidate_generation_tests PRIVATE piep_core)
piep_copy_mingw_runtime(piep_candidate_generation_tests)

add_test(NAME piep_candidate_generation_tests COMMAND piep_candidate_generation_tests)

add_executable(piep_indexing_tests tests/test_indexing.cpp)
target_link_libraries(piep_indexing_tests PRIVATE piep_core)
piep_copy_mingw_runtime(piep_indexing_tests)

add_test(NAME piep_indexing_tests COMMAND piep_indexing_tests)

add_executable(piep_simulation_tests tests/test_simulation.cpp)
target_link_libraries(piep_simulation_tests PRIVATE piep_core)
piep_copy_mingw_runtime(piep_simulation_tests)

add_test(NAME piep_simulation_tests COMMAND piep_simulation_tests)

add_executable(piep_gm_search_tests tests/test_gm_search.cpp)
target_link_libraries(piep_gm_search_tests PRIVATE piep_core)
piep_copy_mingw_runtime(piep_gm_search_tests)

add_test(NAME piep_gm_search_tests COMMAND piep_gm_search_tests)

add_executable(piep_postprocessing_tests tests/test_postprocessing.cpp)
target_link_libraries(piep_postprocessing_tests PRIVATE piep_core)
piep_copy_mingw_runtime(piep_postprocessing_tests)

add_test(NAME piep_postprocessing_tests COMMAND piep_postprocessing_tests)

add_executable(piep_pipeline_synthetic_tests tests/test_pipeline_synthetic.cpp)
target_link_libraries(piep_pipeline_synthetic_tests PRIVATE piep_core)
piep_copy_mingw_runtime(piep_pipeline_synthetic_tests)

add_test(NAME piep_pipeline_synthetic_tests COMMAND piep_pipeline_synthetic_tests)

if(PIEP_BUILD_PYTHON)
    execute_process(
        COMMAND "${Python3_EXECUTABLE}" -m pybind11 --cmakedir
        OUTPUT_VARIABLE PIEP_PYBIND11_CMAKEDIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE PIEP_PYBIND11_STATUS
    )

    if(PIEP_PYBIND11_STATUS EQUAL 0 AND PIEP_PYBIND11_CMAKEDIR)
        list(PREPEND CMAKE_PREFIX_PATH "${PIEP_PYBIND11_CMAKEDIR}")
        find_package(pybind11 CONFIG QUIET)
    endif()

    if(pybind11_FOUND)
        pybind11_add_module(piep_core_py MODULE python/module.cpp)
        target_link_libraries(piep_core_py PRIVATE piep_core)
        set_target_properties(piep_core_py PROPERTIES OUTPUT_NAME piep_core)
        piep_copy_mingw_runtime(piep_core_py)

        set(PIEP_PYTHONPATH "$<TARGET_FILE_DIR:piep_core_py>;${CMAKE_CURRENT_SOURCE_DIR}/python")

        add_test(
            NAME piep_python_smoke
            COMMAND
                "${CMAKE_COMMAND}" -E env
                "PYTHONPATH=${PIEP_PYTHONPATH}"
                "${Python3_EXECUTABLE}"
                "${CMAKE_CURRENT_SOURCE_DIR}/python/smoke_bindings.py"
        )

        add_test(
            NAME piep_python_api_tests
            COMMAND
                "${CMAKE_COMMAND}" -E env
                "PYTHONPATH=${PIEP_PYTHONPATH}"
                "${Python3_EXECUTABLE}"
                "${CMAKE_CURRENT_SOURCE_DIR}/python/test_api.py"
        )
    else()
        message(WARNING "pybind11 not found; Python bindings target will be skipped.")
    endif()
endif()
