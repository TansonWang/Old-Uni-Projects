// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#ifndef Cylinder_HPP_
#define Cylinder_HPP_

#include "visualization_msgs/msg/marker.hpp" 
#include "visualization_msgs/msg/marker_array.hpp"
#include "Base.hpp"

#include <memory>
#include <string>
#include <tuple>
#include <vector>

namespace shapes
{
// ReSharper disable once CppClassCanBeFinal
class Cylinder : public Base
{
public:
    explicit Cylinder(int id, double radius, double height
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
    , double x_pos, double y_pos, double z_pos, float angle
    , shapes::ColourInterface::Colour colour);
protected:
    AllAxis height_;
};
} // namespace shapes
#endif // Cylinder_HPP_
