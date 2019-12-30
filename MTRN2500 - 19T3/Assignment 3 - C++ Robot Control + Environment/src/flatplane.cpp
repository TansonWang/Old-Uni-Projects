// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#include "flatplane.hpp"

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
Flatplane::Flatplane(int id, double side
, std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
, double x_pos, double y_pos, double z_pos, float angle
    , shapes::ColourInterface::Colour colour)
    : Cube(id, side, vector_ptr, x_pos, y_pos, z_pos, angle, colour)
{
    // Get a ref to the vector of marker for ease of use
    auto & shapes_list = shapes_list_ptr_->markers; 

    // Type of marker we want to display
    shape.type = visualization_msgs::msg::Marker::CUBE;

    // Scale change the dimension of the sides.
    shape.scale.x = side_length_.get_value();
    shape.scale.y = side_length_.get_value();
    shape.scale.z = 0.1;

    // create a new marker
    shapes_list.push_back(shape);
}


} // namespace shapes
