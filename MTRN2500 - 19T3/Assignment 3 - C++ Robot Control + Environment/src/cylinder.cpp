// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#include "cylinder.hpp"

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
Cylinder::Cylinder(int id, double radius, double height
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
    , double x_pos, double y_pos, double z_pos, float angle
    , shapes::ColourInterface::Colour colour)
    : Base(id, radius, vector_ptr, x_pos, y_pos, z_pos, angle, colour)
    , height_{height}
{
    // Get a ref to the vector of marker for ease of use
    auto & shapes_list = shapes_list_ptr_->markers; 

    // Type of marker we want to display
    shape.type = visualization_msgs::msg::Marker::CYLINDER;

    // Scale change the dimension of the sides.
    shape.scale.x = side_length_.get_value();
    shape.scale.y = height_.get_value();
    shape.scale.z = side_length_.get_value();

    // Push Marker onto List
    shapes_list.push_back(shape);
}

} // namespace shapes