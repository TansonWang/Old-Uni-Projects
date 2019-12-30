// Copyright 2019 Zhihao Zhang License MIT

#ifndef MARKER_BROADCASTER_HPP_
#define MARKER_BROADCASTER_HPP_

#include "rclcpp/rclcpp.hpp" // http://docs.ros2.org/dashing/api/rclcpp/
#include "visualization_msgs/msg/marker.hpp"
#include "visualization_msgs/msg/marker_array.hpp"

#include "geometry_msgs/msg/pose_stamped.hpp" // http://docs.ros.org/melodic/api/geometry_msgs/html/msg/PoseStamped.html

#include <chrono>
#include <memory>
#include <string>
#include <vector>

namespace assignment3
{
class MarkerBroadcaster final : public rclcpp::Node
{
public:
    explicit MarkerBroadcaster(std::string const & zid,
        std::chrono::milliseconds refresh_period,
        std::shared_ptr<visualization_msgs::msg::MarkerArray>
            shape_list_ptr);

private:
    rclcpp::Subscription<geometry_msgs::msg::PoseStamped>::SharedPtr pose_input_;
    
    rclcpp::Publisher<visualization_msgs::msg::MarkerArray>::SharedPtr
        marker_publisher_;

    rclcpp::TimerBase::SharedPtr timer_;
    geometry_msgs::msg::PoseStamped::UniquePtr pose_;
    std::shared_ptr<visualization_msgs::msg::MarkerArray> shape_list_ptr_;
    std::string zid_;

    auto marker_publisher_callback() -> void;
    auto pose_callback(geometry_msgs::msg::PoseStamped::UniquePtr input_message) -> void;
    auto callback(geometry_msgs::msg::PoseStamped thing) -> void;
};
} // namespace assignment3
#endif // MARKER_BROADCASTER_HPP_
