// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#ifndef Cubelist_HPP_
#define Cubelist_HPP_

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
class Cubelist : public Base
{
public:
    explicit Cubelist(int id
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptry);

protected:

};
} // namespace shapes
#endif // Cubelist_HPP_
