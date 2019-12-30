// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#ifndef SPHERE_HPP_
#define SPHERE_HPP_

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
class Sphere : public Base
{
public:
    explicit Sphere(int id, double radius
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
    , double x_pos, double y_pos, double z_pos, float angle
    , shapes::ColourInterface::Colour colour);

protected:
    
};
} // namespace shapes
#endif // SPHERE_HPP_
