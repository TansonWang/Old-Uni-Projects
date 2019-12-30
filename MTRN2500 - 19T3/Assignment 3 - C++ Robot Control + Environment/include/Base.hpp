// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#ifndef ShapesBase_HPP_
#define ShapesBase_HPP_

#include "interfaces.hpp"
#include "visualization_msgs/msg/marker.hpp"
#include "visualization_msgs/msg/marker_array.hpp"

#include <memory>
#include <string>
#include <tuple>
#include <vector>

namespace shapes
{
// ReSharper disable once CppClassCanBeFinal
class Base : public ShapeCommonInterface
{
public:
    explicit Base(int id, double  side_length
    , std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
    , double x_pos, double y_pos, double z_pos, float angle
    , shapes::ColourInterface::Colour colour);

protected:
    AllAxis  side_length_;
    std::string parent_frame_name_;
    std::shared_ptr<visualization_msgs::msg::MarkerArray>
        shapes_list_ptr_;
    int id_;
    Colour colour_;
    visualization_msgs::msg::Marker shape;

    auto resize_imple(AllAxis new_size) -> void override;

    auto rescale_imple(AnyAxis factor) -> void override;

    auto set_colour_imple(Colour colour) -> void override;
    
    [[nodiscard]] auto get_colour_imple() const -> Colour;

    auto set_parent_frame_name_imple(std::string frame_name) -> void override;

    [[nodiscard]] auto get_location_imple() const
        -> std::tuple<XAxis, YAxis, ZAxis> override;

    auto move_to_imple(XAxis) -> void override;
    auto move_to_imple(YAxis) -> void override;
    auto move_to_imple(ZAxis) -> void override;
    auto move_to_imple(XAxis, YAxis, ZAxis) -> void override;

    auto move_by_imple(XAxis) -> void override;
    auto move_by_imple(YAxis) -> void override;
    auto move_by_imple(ZAxis) -> void override;

    auto move_by_imple(XAxis, YAxis, ZAxis) -> void override;

    auto get_display_markers_imple() -> std::shared_ptr<
        std::vector<visualization_msgs::msg::Marker>> override;
};
} // namespace shapes
#endif