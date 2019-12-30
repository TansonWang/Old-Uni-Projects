cmake_minimum_required(VERSION 3.10)
project(assignment3)

# Use C++17
set(CMAKE_CXX_STANDARD 17)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
elseif(MSVC)
  add_compile_options(-D_SILENCE_CXX17_OLD_ALLOCATOR_MEMBERS_DEPRECATION_WARNING )
  add_compile_options(-D_USE_MATH_DEFINES )
endif()

add_executable(assignment3 src/main.cpp)

target_sources(assignment3 PRIVATE
  include/single_shape_display.hpp
  include/multi_shape_display.hpp
  include/student_helper.hpp
  include/interfaces.hpp
  include/sphere.hpp
  include/cube.hpp
  include/cylinder.hpp
  include/pyramid.hpp
  include/prism.hpp
  include/cone.hpp
  include/parallelepiped.hpp
  include/Base.hpp
  include/flatplane.hpp
  include/background.hpp
  include/cubelist.hpp
  include/config_parser.hpp
  include/joystick_listener.hpp
  include/marker_broadcaster.hpp
  include/pose_kinematic.hpp
  include/transform_broadcaster.hpp
  include/velocity_kinematic.hpp
)

target_sources(assignment3 PRIVATE
  src/single_shape_display.cpp
  src/multi_shape_display.cpp
  src/student_helper.cpp
  src/sphere.cpp
  src/cube.cpp
  src/cylinder.cpp
  src/pyramid.cpp
  src/prism.cpp
  src/cone.cpp
  src/parallelepiped.cpp
  src/Base.cpp
  src/flatplane.cpp
  src/background.cpp
  src/cubelist.cpp
  src/joystick_listener.cpp
  src/velocity_kinematic.cpp
  src/pose_kinematic.cpp
  src/marker_broadcaster.cpp
  src/transform_broadcaster.cpp
  src/config_parser.cpp
)

target_include_directories(assignment3 PRIVATE include)
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(visualization_msgs REQUIRED)
find_package(tf2_geometry_msgs REQUIRED)
find_package(tf2 REQUIRED)
find_package(tf2_ros REQUIRED)

if(BUILD_TESTING)
	find_package(ament_lint_auto REQUIRED)
	ament_lint_auto_find_test_dependencies()
endif()
get_filename_component(PARENT_DIR ${PROJECT_SOURCE_DIR} PATH)

ament_target_dependencies(assignment3 rclcpp)
ament_target_dependencies(assignment3 sensor_msgs)
ament_target_dependencies(assignment3 geometry_msgs)
ament_target_dependencies(assignment3 visualization_msgs)
ament_target_dependencies(assignment3 tf2_geometry_msgs)
ament_target_dependencies(assignment3 tf2)
ament_target_dependencies(assignment3 tf2_ros)

install (DIRECTORY launch DESTINATION share/${PROJECT_NAME}/)
install(TARGETS assignment3 DESTINATION lib/${PROJECT_NAME})

ament_package()
