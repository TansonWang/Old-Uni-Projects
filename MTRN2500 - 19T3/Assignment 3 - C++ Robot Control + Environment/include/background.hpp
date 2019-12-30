// Copyright 2019 Zhihao Zhang License MIT

#ifndef background_HPP_
#define background_HPP_

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
class Background final
{
public:
    explicit Background(
        std::shared_ptr<visualization_msgs::msg::MarkerArray> shape_list_ptr
        );

protected:
    std::shared_ptr<visualization_msgs::msg::MarkerArray> shape_list_ptr_;

private:

};
} // namespace assignment3
#endif // MARKER_BROADCASTER_HPP_
