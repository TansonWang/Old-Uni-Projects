// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#ifndef flatplane_HPP_
#define flatplane_HPP_

#include "visualization_msgs/msg/marker.hpp" 
#include "visualization_msgs/msg/marker_array.hpp"
#include "cube.hpp"

#include <memory>
#include <string>
#include <tuple>
#include <vector>

namespace shapes
{
class Flatplane : public Cube
{
public:
    explicit Flatplane(int id, double side
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
    , double x_pos, double y_pos, double z_pos, float angle
    , shapes::ColourInterface::Colour colour);

protected:
    
};
} // namespace shapes
#endif // Cube_HPP_