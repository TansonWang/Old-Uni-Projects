// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#include "cubelist.hpp"

#include "rclcpp/rclcpp.hpp" // http://docs.ros2.org/dashing/api/rclcpp/
#include "student_helper.hpp"

#include <chrono>
#include <memory>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

#include <cmath>
#include <math.h>

namespace shapes
{
Cubelist::Cubelist(int id
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr)
    : Base(id, 0, vector_ptr, 0, 0, 0, 0, shapes::ColourInterface::Colour::yellow)
{
    // Get a ref to the vector of marker for ease of use
    auto & shapes_list = shapes_list_ptr_->markers; 

    // Type of marker we want to display
    shape.type = visualization_msgs::msg::Marker::CUBE_LIST;

    // Scale change the dimension of the sizes.
    shape.scale.x = 1;
    shape.scale.y = 1;
    shape.scale.z = 1;
    
    // create a new marker
    shapes_list.push_back(shape);
}

} // namespace shapes
