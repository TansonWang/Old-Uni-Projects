// Copyright 2019 Zhihao Zhang License MIT

#include "joystick_listener.hpp"

#include "student_helper.hpp"

#include <memory>
#include <string>
#include <utility>


namespace assignment2
{
JoystickListener::JoystickListener(
    std::string const & zid, JoystickConfig config)
    
    : rclcpp::Node{helper::joy_node_name(zid)}
    , zid_{zid}
    , config_{config}

{
    auto callback = std::bind(&JoystickListener::joy_message_callback, this, std::placeholders::_1);
    this->joystick_input_ = create_subscription<sensor_msgs::msg::Joy>(std::string("/z0000000/joy"), 10, callback);


    acceleration_output_ = create_publisher<geometry_msgs::msg::AccelStamped>(std::string{"/z0000000/acceleration"}, 10); 
}

auto JoystickListener::joy_message_callback(
    sensor_msgs::msg::Joy::UniquePtr joy_message) -> void
    {
        std::cout << "\n========================================================" << std::endl;
        std::cout << "This is the Joystick Listener section." << std::endl;

        // Using Lambda function as part of the for_each statement
        std::for_each(joy_message->axes.begin(), joy_message->axes.end(), [](const float& n) { std::cout << " \t" << n; });
        std::cout << "Printing Number of Buttons Pressed: " << std::endl; 
        int activeButtons = count(joy_message->buttons.begin(), joy_message->buttons.end(), 1); 
        std::cout << activeButtons << std::endl;

        // Grab the first value 
        float plus = joy_message->axes[config_.speed_plus_axis]; 
        // Grab the second value 
        float min = joy_message->axes[config_.speed_minus_axis]; 
        // Grad the angular acc value (third value)
        float ang = joy_message->axes[config_.steering_axis]; 

        // Check if its a deadzone value 
        if (abs(plus) <= config_.speed_deadzone) { 
            plus = 0; 
        } 
        if (abs(min) <= config_.speed_deadzone) { 
            min = 0; 
        } 
        if (abs(ang) <= config_.steering_deadzone) { 
            ang = 0; 
        }

        // Now change so on a scale from 0 to 1 
        plus = plus/2 + 0.5; 
        min = min/2 + 0.5; 
        // ang = ang; //angle does not need to be mapped again.

        // Calculating Net Value 
        float net = -min + plus; 
        
        /*
        std::cout << "Printing Values" << std::endl;
        std::cout << plus << std::endl; 
        std::cout << min << std::endl; 
        std::cout << ang << std::endl;
        std::cout << net << std::endl; 
        */

        // Create the shell for the to be published information
        auto info = geometry_msgs::msg::AccelStamped();

        // Fill the values in Accel 
        info.accel.linear.x = net; 
        info.accel.angular.z = ang; 
        info.header = joy_message->header; 
        info.header.frame_id = this->zid_; 

        // Publish the information
        acceleration_output_->publish(info);

    } // namespace assignment2

}