// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#include "cone.hpp"

#include "rclcpp/rclcpp.hpp" // http://docs.ros2.org/dashing/api/rclcpp/
#include "student_helper.hpp"

#include <chrono>
#include <memory>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

namespace shapes
{
Cone::Cone(int id, double radius
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
    , double x_pos, double y_pos, double z_pos, float angle
    , shapes::ColourInterface::Colour colour)
    : Base(id, radius, vector_ptr, x_pos, y_pos, z_pos, angle, colour)
    {
    // Get a ref to the vector of marker for ease of use
    auto & shapes_list = shapes_list_ptr_->markers; 

    // Type of marker we want to display
    shape.type = visualization_msgs::msg::Marker::ARROW;

    // Scale change the dimension of the radiuss.
    shape.scale.x = 0;
    shape.scale.y = side_length_.get_value();
    shape.scale.z = side_length_.get_value();

    // Start and End Points of the Cone
    geometry_msgs::msg::Point p;
    p.x = 0;
    p.y = 0;
    p.z = 0;

    shape.points.push_back(p);

    p.z = side_length_.get_value();
    shape.points.push_back(p);

    // Push Marker onto List
    shapes_list.push_back(shape);
}

} // namespace shapes
