// Copyright 2019 Zhihao Zhang License MIT

#ifndef JOYSTICK_LISTENER_HPP_
#define JOYSTICK_LISTENER_HPP_

#include "config_parser.hpp"
#include "geometry_msgs/msg/accel_stamped.hpp" // http://docs.ros.org/api/geometry_msgs/html/msg/AccelStamped.html
#include "rclcpp/rclcpp.hpp"       // http://docs.ros2.org/dashing/api/rclcpp/
#include "sensor_msgs/msg/joy.hpp" // http://wiki.ros.org/joy
#include "geometry_msgs/msg/pose_stamped.hpp" // http://docs.ros.org/melodic/api/geometry_msgs/html/msg/PoseStamped.html
#include "visualization_msgs/msg/marker.hpp" 
#include "visualization_msgs/msg/marker_array.hpp"

#include "sphere.hpp"
#include "cube.hpp"
#include "cone.hpp"
#include "cylinder.hpp"
#include "pyramid.hpp"
#include "prism.hpp"
#include "cone.hpp"
#include "parallelepiped.hpp"

#include <string>

namespace assignment3
{
class JoystickListener final : public rclcpp::Node
{
public:
    explicit JoystickListener(std::string const & zid, JoystickConfig config
    , KinematicLimits speedconfig
    , std::chrono::milliseconds const refresh_period
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> cube_list_ptr);

private:
    rclcpp::Subscription<sensor_msgs::msg::Joy>::SharedPtr joystick_input_;
    //rclcpp::Publisher<geometry_msgs::msg::AccelStamped>::SharedPtr
    //    acceleration_output_;
    //rclcpp::Publisher<geometry_msgs::msg::PoseStamped>::SharedPtr pose_output_;
    std::string const zid_;
    JoystickConfig const config_;
    KinematicLimits speedconfig_;
    rclcpp::TimerBase::SharedPtr timer_;
    std::shared_ptr<visualization_msgs::msg::MarkerArray> cube_list_ptr_;
    float x_pos_;
    float y_pos_;
    float z_pos_ = 0.5;
    float ang_ = 0;
    int id_counter_ = 12345;
    int prev_drop_ = 0;
    shapes::ColourInterface::Colour colour_ = shapes::ColourInterface::Colour::red;
    std::shared_ptr<visualization_msgs::msg::MarkerArray> shapes_list_ptr_;
    int id_;
    auto joy_message_callback(sensor_msgs::msg::Joy::UniquePtr joy_message)
        -> void;
    auto timer_callback() -> void;
};  
} // namespace assignment3

#endif // JOYSTICK_LISTENER_HPP_
