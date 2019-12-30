// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#ifndef Prism_HPP_
#define Prism_HPP_

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
class Prism : public Base
{
public:
    explicit Prism(int id, double side1, double side2, int sides
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
    , double x_pos, double y_pos, double z_pos, float angle
    , shapes::ColourInterface::Colour colour);

protected:

};
} // namespace shapes
#endif // Prism_HPP_
