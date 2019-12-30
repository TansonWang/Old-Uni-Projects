// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#include "parallelepiped.hpp"

#include "rclcpp/rclcpp.hpp" // http://docs.ros2.org/dashing/api/rclcpp/
#include "student_helper.hpp"

#include <chrono>
#include <cmath>
#include <math.h>
#include <memory>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

namespace shapes
{
Parallelepiped::Parallelepiped(int id, double side
, std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
, double x_pos, double y_pos, double z_pos, float angle
    , shapes::ColourInterface::Colour colour)
    : Base(id, side, vector_ptr, x_pos, y_pos, z_pos, angle, colour)
{
    // Get a ref to the vector of marker for ease of use
    auto & shapes_list = shapes_list_ptr_->markers; 

    // Type of marker we want to display
    shape.type = visualization_msgs::msg::Marker::TRIANGLE_LIST;

    // Scale change the dimension of the sizes.
    shape.scale.x = side_length_.get_value();
    shape.scale.y = side_length_.get_value();
    shape.scale.z = side_length_.get_value();

    // Point values
    float side_angle = M_PI / 3;
    geometry_msgs::msg::Point p1, p2, p3, p4, p5, p6, p7, p8;
    std_msgs::msg::ColorRGBA c;
    c.r = 1;
    c.g = 0;
    c.b = 0;
    c.a = 1;

    // Generates sides
    float cosVal = cos(side_angle);
    float sinVal = sin(side_angle);

    // Not being a dumbass and making 8 points
    p1.x = 0;
    p1.y = 0;
    p1.z = 0;

    p2 = p1;
    p2.x = 1;

    p3 = p1;
    p3.x = cosVal;
    p3.y = sinVal;

    p4 = p3;
    p4.x += 1;

    p5 = p1;
    p5.x += cosVal;
    p5.z += sinVal;

    p6 = p2;
    p6.x += cosVal;
    p6.z += sinVal;

    p7 = p3;
    p7.x += cosVal;
    p7.z += sinVal;

    p8 = p4;
    p8.x += cosVal;
    p8.z += sinVal;

    // Base
    shape.points.push_back(p1);
    shape.points.push_back(p2);
    shape.points.push_back(p3);

    shape.points.push_back(p2);
    shape.points.push_back(p3);
    shape.points.push_back(p4);
    
    // Top
    shape.points.push_back(p5);
    shape.points.push_back(p6);
    shape.points.push_back(p7);

    shape.points.push_back(p6);
    shape.points.push_back(p7);
    shape.points.push_back(p8);

    // Front
    shape.points.push_back(p1);
    shape.points.push_back(p3);
    shape.points.push_back(p5);

    shape.points.push_back(p3);
    shape.points.push_back(p5);
    shape.points.push_back(p7);
    
    // Back
    shape.points.push_back(p2);
    shape.points.push_back(p4);
    shape.points.push_back(p6);

    shape.points.push_back(p4);
    shape.points.push_back(p6);
    shape.points.push_back(p8);

    // Left
    shape.points.push_back(p1);
    shape.points.push_back(p2);
    shape.points.push_back(p5);

    shape.points.push_back(p2);
    shape.points.push_back(p5);
    shape.points.push_back(p6);
    
    // Right
    shape.points.push_back(p3);
    shape.points.push_back(p4);
    shape.points.push_back(p7);

    shape.points.push_back(p4);
    shape.points.push_back(p7);
    shape.points.push_back(p8);
    
    // create a new marker
    shapes_list.push_back(shape);
}

} // namespace shapes
