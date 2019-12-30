/**
 *  Assignment 3 for MTRN2500 T3 2019
 *  Developers: Tanson Wang, Duc Minh Tran
 *  Date:       December 2019
 *  Notes:      WIP
 **/

#include "rclcpp/rclcpp.hpp" // http://docs.ros2.org/dashing/api/rclcpp/
#include "single_shape_display.hpp"
#include "multi_shape_display.hpp"
#include "visualization_msgs/msg/marker_array.hpp"

#include "sphere.hpp"
#include "cube.hpp"
#include "cone.hpp"
#include "cylinder.hpp"
#include "pyramid.hpp"
#include "prism.hpp"
#include "cone.hpp"
#include "parallelepiped.hpp"
#include "flatplane.hpp"
#include "background.hpp"
#include "cubelist.hpp"

#include "config_parser.hpp"
#include "joystick_listener.hpp"
#include "marker_broadcaster.hpp"
#include "pose_kinematic.hpp"
#include "student_helper.hpp"
#include "transform_broadcaster.hpp"
#include "velocity_kinematic.hpp"

#include <chrono>
#include <iostream>
#include <memory>
#include <vector>
#include <typeinfo>
#include <algorithm>
#include <fstream>

// ReSharper disable once CppParameterMayBeConst
auto main(int argc, char * argv[]) -> int
{
    using namespace std::chrono_literals;

    try
    {
        rclcpp::init(argc, argv); // Initialise ROS2
        std::cout << "Main Program Start. Please press the ENTER key to continue...";
        std::cin.ignore(); // Wait until there is an Enter key input

        auto ros_worker = rclcpp::executors::SingleThreadedExecutor{};

        std::ifstream file_;
        file_.open(argv[1], std::ifstream::in);
 
        auto const config_strings = assignment3::ConfigReader{file_};
        auto const config = assignment3::ConfigParser{config_strings};
 
        file_.close();




        auto random_array_ptr = std::make_shared<visualization_msgs::msg::MarkerArray>();
        auto random_1 = std::make_shared<assignment3::Background>(random_array_ptr);
        auto random_display = std::make_shared<display::MultiShapeDisplay>("Random", 100ms, random_array_ptr);
        ros_worker.add_node(random_display);
        
        
        
        
        
        
        
        
        
        // Create a list for the UAV to append to
        auto UAV_array_ptr = std::make_shared<visualization_msgs::msg::MarkerArray>();
        auto cube_list_ptr = std::make_shared<visualization_msgs::msg::MarkerArray>();
        std::make_shared<shapes::Cubelist>(43289762098345,cube_list_ptr);

        // Create the UAV, Currently only spheres are available.
        auto input_node = std::make_shared<assignment3::JoystickListener>(
        "z0000000", config.get_joystick_config(), config.get_kinematic_config(), 100ms, UAV_array_ptr, cube_list_ptr);
        ros_worker.add_node(input_node);

        // Publish the UAV and turn it into a node.
        auto UAV_display = std::make_shared<display::MultiShapeDisplay> ("UAV_display", 100ms, UAV_array_ptr);
        ros_worker.add_node(UAV_display);
        auto Block_display = std::make_shared<display::MultiShapeDisplay> ("Block_display", 100ms, cube_list_ptr);
        ros_worker.add_node(Block_display);

        
        

        

        auto transform_node =
        std::make_shared<assignment3::TransformBroadcaster>("z0000000");
        ros_worker.add_node(transform_node);


        // Create a list for the dropped blocks to append to
        


        auto previous_time = std::chrono::steady_clock::now();

        // Periodically do some work
        while (rclcpp::ok())
        {
            auto current_time = std::chrono::steady_clock::now();
            if (current_time - previous_time > 1s)
            {
                // Meowing at rate of 1hz.
                std::cout << "meow\n";
                previous_time = current_time;
            }

            ros_worker.spin_some(50ms);
        }
    }
    catch (std::exception & e)
    {
        // Something wrong occured, printing error message.
        std::cerr << "Error message:" << e.what() << "\n";
    }

    rclcpp::shutdown(); // Cleaning up before exiting.

    return 0;
}
