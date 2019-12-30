#include "background.hpp"
#include "sphere.hpp"
#include "cube.hpp"
#include "cone.hpp"
#include "cylinder.hpp"
#include "pyramid.hpp"
#include "prism.hpp"
#include "cone.hpp"
#include "parallelepiped.hpp"
#include "flatplane.hpp"

#include "student_helper.hpp"

#include <memory>
#include <string>
#include <utility>
#include <vector>

namespace assignment3
{
Background::Background(
    std::shared_ptr<visualization_msgs::msg::MarkerArray> shape_list_ptr)
    : shape_list_ptr_{shape_list_ptr}
{
    int static_object_counter = 600;
    shapes::Sphere(static_object_counter++,1,shape_list_ptr_, 0, 0, 0, 0, shapes::ColourInterface::Colour::yellow);
    shapes::Cube(static_object_counter++,1,shape_list_ptr_, 10, 0, 0, 0, shapes::ColourInterface::Colour::yellow);
    shapes::Cone(static_object_counter++,1,shape_list_ptr_, -10, 0, 0, 0, shapes::ColourInterface::Colour::yellow);
    shapes::Cylinder(static_object_counter++,1,1,shape_list_ptr_, 0, 10, 0, 0, shapes::ColourInterface::Colour::yellow);
    shapes::Pyramid(static_object_counter++,1,1,4,shape_list_ptr_, 0, -10, 0, 0, shapes::ColourInterface::Colour::yellow);
    shapes::Prism(static_object_counter++,1,1,5,shape_list_ptr_, 10, 10, 0, 0, shapes::ColourInterface::Colour::yellow);
    shapes::Parallelepiped(static_object_counter++,1,shape_list_ptr_, -10, -10, 0, 0, shapes::ColourInterface::Colour::yellow);
    shapes::Flatplane(static_object_counter++,10,shape_list_ptr_,0,0,0, 0, shapes::ColourInterface::Colour::green);

}
  
}