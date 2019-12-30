// Copyright 2019 Zhihao Zhang License MIT

#include "joystick_listener.hpp"

#include "student_helper.hpp"

#include <memory>
#include <string>
#include <utility>
#include <math.h>
#include <cmath>

#include "sphere.hpp"
#include "cube.hpp"
#include "cone.hpp"
#include "cylinder.hpp"
#include "pyramid.hpp"
#include "prism.hpp"
#include "cone.hpp"
#include "parallelepiped.hpp"


#include "cubelist.hpp"

namespace assignment3
{

JoystickListener::JoystickListener(
    std::string const & zid, JoystickConfig config, KinematicLimits speedconfig
    , std::chrono::milliseconds const refresh_period
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> cube_list_ptr)
    
    : rclcpp::Node{helper::joy_node_name(zid)}
    , config_{config}
    , shapes_list_ptr_{vector_ptr}
    , cube_list_ptr_{cube_list_ptr}
{
    
    // subscriber code to joy topic
    auto callback = std::bind(&JoystickListener::joy_message_callback, this, std::placeholders::_1);
    this->joystick_input_ = create_subscription<sensor_msgs::msg::Joy>(std::string("/z0000000/joy"), 10, callback);
    //publisher code to acceleration topic
    //acceleration_output_ = create_publisher<geometry_msgs::msg::AccelStamped>(std::string{"/z0000000/acceleration"}, 10);
    //publisher code to pose topic
    //pose_output_ = create_publisher<geometry_msgs::msg::PoseStamped>(std::string{"/z0000000/pose"}, 10);
    this->timer_ = create_wall_timer(std::chrono::milliseconds{refresh_period},
                    [this]() {
                            JoystickListener::timer_callback();
                        }
            );
  }

  
// ReSharper disable once CppMemberFunctionMayBeConst
auto JoystickListener::joy_message_callback(
    sensor_msgs::msg::Joy::UniquePtr joy_message) -> void
{
        // This is the code for joystick listener section
        std::cout << "Listener" << std::endl;
        // Using Lambda function as part of the for_each statement
        std::for_each(joy_message->axes.begin(), joy_message->axes.end(), [](const float& n) { std::cout << " \t" << n; });
        std::cout << "\nTotal number of buttons pressed: " << std::endl;
        int activeButtons = count(joy_message->buttons.begin(), joy_message->buttons.end(), 1);
        std::cout << activeButtons << std::endl;

        

        // Grab the first value
        float plus = joy_message->axes[config_.speed_plus_axis];
        // Grab the second value
        float min = joy_message->axes[config_.speed_minus_axis];
        // Grad the angular acc value (third value)
        ang_ = joy_message->axes[config_.steering_axis] * M_PI;
        // Grab the L/R trigger value
        float up = joy_message->buttons[config_.LT];
        float down = joy_message->buttons[config_.RT];
        // Grab button values
        int drop = joy_message->buttons[config_.dropButton];
        int clear = joy_message->buttons[config_.clearButton];
        
        // Check if its a deadzone value
        if (abs(plus) <= config_.speed_deadzone) {
            plus = 0;
        }
        if (abs(min) <= config_.speed_deadzone) {
            min = 0;
        }
        if (abs(ang_) <= config_.steering_deadzone) {
            ang_ = 0;
        }

        // Grab the maximum velocity value
        //float max_linear = speedconfig_.max_linear_speed;
        
        // Scale velocity with max value
        float x_scaled = plus * 1;
        float y_scaled = min * 1;
        
        
        x_pos_ += x_scaled * -0.1;
        if (x_pos_ >= 5) {
            x_pos_ = 5;
        }
        if (x_pos_ <= -5) {
            x_pos_ = -5;
        }
        y_pos_ += y_scaled * 0.1; 
        if (y_pos_ >= 5) {
            y_pos_ = 5;
        }
        if (y_pos_ <= -5) {
            y_pos_ = -5;
        }
        
        std::cout << "Printing values" << std::endl;
        std::cout << "Plus: " << x_scaled << std::endl;
        std::cout << "Minus:" << y_scaled << std::endl;
        std::cout << "Angle:" << ang_ << std::endl;
        std::cout << "x:" << x_pos_ << std::endl;
        std::cout << "y:" << y_pos_ << std::endl;
        std::cout << "z:" << z_pos_ << std::endl;

        
        
        if (up == 1)
        {
            std::cout << "Going up!" << std::endl;
            z_pos_ += 0.1;
            if (z_pos_ >= 10) {
                z_pos_ = 10;
            }
        }
        if (down == 1)
        {
            std::cout << "Going down!" << std::endl;
            z_pos_ -= 0.1;
            if (z_pos_ <= 0.5) {
                z_pos_ = 0.5;
            }
        }
        if (drop > prev_drop_)
        {
            shapes::Cube(id_counter_++, 1, cube_list_ptr_, x_pos_, y_pos_, z_pos_, ang_, colour_);
            
            std::cout << "Drop a block!" << std::endl;
            
            
            if (colour_ == shapes::ColourInterface::Colour::red) {
                colour_ = shapes::ColourInterface::Colour::yellow;
                
            } else if (colour_ == shapes::ColourInterface::Colour::yellow) {
                colour_ = shapes::ColourInterface::Colour::green;
                
            } else if (colour_ == shapes::ColourInterface::Colour::green) {
                colour_ = shapes::ColourInterface::Colour::blue;
                
            } else if (colour_ == shapes::ColourInterface::Colour::blue) {
                colour_ = shapes::ColourInterface::Colour::black;
                
            } else if (colour_ == shapes::ColourInterface::Colour::white) {
                colour_ = shapes::ColourInterface::Colour::red;
            } else {
                colour_ = shapes::ColourInterface::Colour::white;
            }  
            
        }

        if (clear == 1)
        {
            std::cout << "Clear all blocks!" << std::endl;
            auto & cube_list = cube_list_ptr_->markers;
            cube_list.clear();
        }
        prev_drop_ = drop;
        
}

auto JoystickListener::timer_callback() -> void
{
    //double dt = (now()-input_message->header.stamp).seconds();
    
    
    //auto & marker_list = shapes_list_ptr_->markers;
    shapes::Cube(120,1,shapes_list_ptr_,x_pos_,y_pos_,z_pos_,ang_,colour_);
    shapes::Sphere(121,0.3,shapes_list_ptr_,x_pos_-std::sin(2*M_PI/11 + ang_),y_pos_+std::cos(2*M_PI/11 + ang_),z_pos_,ang_,shapes::ColourInterface::Colour::red);
    shapes::Cylinder(122,0.3,0.3,shapes_list_ptr_,x_pos_-std::sin(2*2*M_PI/11 + ang_),y_pos_+std::cos(2*2*M_PI/11 + ang_),z_pos_,ang_,shapes::ColourInterface::Colour::red);
    shapes::Parallelepiped(123,0.3,shapes_list_ptr_,x_pos_-std::sin(3*2*M_PI/11 + ang_),y_pos_+std::cos(3*2*M_PI/11 + ang_),z_pos_,ang_,shapes::ColourInterface::Colour::red);
    shapes::Cone(124,0.3,shapes_list_ptr_,x_pos_-std::sin(4*2*M_PI/11 + ang_),y_pos_+std::cos(4*2*M_PI/11 + ang_),z_pos_,ang_,shapes::ColourInterface::Colour::red);
    shapes::Pyramid(125,0.3,0.3,4,shapes_list_ptr_,x_pos_-std::sin(5*2*M_PI/11 + ang_),y_pos_+std::cos(5*2*M_PI/11 + ang_),z_pos_,ang_,shapes::ColourInterface::Colour::red);
 //   shapes::Pyramid(126,0.1,0.1,3,shapes_list_ptr_,x_pos_-std::sin(6*2*M_PI/11 + ang_),y_pos_+std::cos(6*2*M_PI/11 + ang_),z_pos_,ang_,shapes::ColourInterface::Colour::red);
 //   shapes::Pyramid(127,0.1,0.1,8,shapes_list_ptr_,x_pos_-std::sin(7*2*M_PI/11 + ang_),y_pos_+std::cos(7*2*M_PI/11 + ang_),z_pos_,ang_,shapes::ColourInterface::Colour::red);
 //   shapes::Pyramid(128,0.1,0.1,4,shapes_list_ptr_,x_pos_-std::sin(8*2*M_PI/11 + ang_),y_pos_+std::cos(8*2*M_PI/11 + ang_),z_pos_,ang_,shapes::ColourInterface::Colour::red);
 //   shapes::Prism(129,0.1,0.1,3,shapes_list_ptr_,x_pos_-std::sin(9*2*M_PI/11 + ang_),y_pos_+std::cos(9*2*M_PI/11 + ang_),z_pos_,ang_,shapes::ColourInterface::Colour::red);
 //   shapes::Prism(130,0.1,0.1,4,shapes_list_ptr_,x_pos_-std::sin(10*2*M_PI/11 + ang_),y_pos_+std::cos(10*2*M_PI/11 + ang_),z_pos_,ang_,shapes::ColourInterface::Colour::red);
    
    shapes::Prism(131,0.3,0.3,8,shapes_list_ptr_,x_pos_-std::sin(ang_),y_pos_+std::cos(ang_),z_pos_,ang_,shapes::ColourInterface::Colour::red);


    auto & cube_list = cube_list_ptr_->markers;
    std::for_each(cube_list.begin(),cube_list.end(),[](visualization_msgs::msg::Marker & n) {
        n.pose.position.z -= 0.1;
        if (n.pose.position.z < 0.5)
        {
            n.pose.position.z = 0.5;
        }
    });
    
    
    
}
} // namespace assignment3
