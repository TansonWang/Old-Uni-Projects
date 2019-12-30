// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#include "prism.hpp"

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
Prism::Prism(int id, double side1, double side2, int sides
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
    , double x_pos, double y_pos, double z_pos, float angle
    , shapes::ColourInterface::Colour colour)
    : Base(id, side1, vector_ptr, x_pos, y_pos, z_pos, angle, colour)
{
    // Get a ref to the vector of marker for ease of use
    auto & shapes_list = shapes_list_ptr_->markers; 

    shape.type = visualization_msgs::msg::Marker::TRIANGLE_LIST;

    // Scale change the dimension of the sizes.
    shape.scale.x = side1;
    shape.scale.y = side2;
    shape.scale.z = side1;

    // Point values
    float side_angle = M_PI * 2 / sides;
    geometry_msgs::msg::Point p1, p2, p3;
    std_msgs::msg::ColorRGBA c;
    c.r = 1;
    c.g = 0;
    c.b = 0;
    c.a = 1;
    
    // Generates sides
    for (int i = 0; i < sides; ++i) {
        p1.x = 0;
        p1.y = 0;
        p1.z = 0;
        p2 = p1;
        p3 = p1;
        
        p1.x = sin(side_angle * (i - 1.5));
        p1.y = cos(side_angle * (i - 1.5));
        p2.x = sin(side_angle * (i - 0.5));
        p2.y = cos(side_angle * (i - 0.5));

        // Lower Triangle
        shape.points.push_back(p1);
        shape.points.push_back(p2);
        shape.points.push_back(p3);
        //shape.colors.push_back(c);

        // Lower Wall
        p3 = p1;
        p3.z = 1;        
        shape.points.push_back(p1);
        shape.points.push_back(p2);
        shape.points.push_back(p3);
        //shape.colors.push_back(c);

        // Upper Wall
        p1 = p2;
        p1.z = 1;        
        shape.points.push_back(p1);
        shape.points.push_back(p2);
        shape.points.push_back(p3);
        //shape.colors.push_back(c);
        
        // Upper Triangle
        p2.x = 0;
        p2.y = 0;
        p2.z = 1;
        shape.points.push_back(p1);
        shape.points.push_back(p2);
        shape.points.push_back(p3);

        //shape.colors.push_back(c);
    }

    // create a new marker
    shapes_list.push_back(shape);
}

} // namespace shapes
