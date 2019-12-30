// Made by Tanson Wang, built off code produced by Zhihao Zhang (2019)

#include "Base.hpp"

#include "rclcpp/rclcpp.hpp" // http://docs.ros2.org/dashing/api/rclcpp/
#include "student_helper.hpp"
#include "tf2/LinearMath/Quaternion.h"
#include "tf2_geometry_msgs/tf2_geometry_msgs.h"
#include "tf2/convert.h"
#include "geometry_msgs/msg/quaternion.hpp"

#include <chrono>
#include <memory>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

namespace shapes
{
Base::Base(int id, double  side_length, std::shared_ptr<visualization_msgs::msg::MarkerArray> vector_ptr
, double x_pos, double y_pos, double z_pos, float angle
, shapes::ColourInterface::Colour colour)
    :  side_length_{ side_length}
    , parent_frame_name_{"local_frame"}
    , shapes_list_ptr_{vector_ptr}
    , id_{id}
    , colour_{colour}
{
    // Parent frame name
    shape.header.frame_id = helper::world_frame_name("z0000000");

    // namespace the marker will be in
    shape.ns = "";

    // Used to identify which marker we are adding/modifying/deleting
    // Must be unique between shape objects.
    shape.id = id;

    // Add, modify or delete.
    shape.action = visualization_msgs::msg::Marker::ADD;

    // Position
    shape.pose.position.x = x_pos;
    shape.pose.position.y = y_pos;
    shape.pose.position.z = z_pos;

    tf2::Quaternion quaternion;
    quaternion.setRPY(0,0,angle);
    geometry_msgs::msg::Quaternion quat;
    quat = tf2::toMsg(quaternion);
    // Orientation in quaternion. Check transform marker in assignment 2
    // for how to manipulate it.
    shape.pose.orientation.x = quat.x;
    shape.pose.orientation.y = quat.y;
    shape.pose.orientation.z = quat.z;
    shape.pose.orientation.w = quat.w;

    shape.color.a = 1;
    shape.color.r = 0;
    shape.color.b = 0;
    shape.color.g = 0;

    if (colour == Colour::red) {
        shape.color.r = 1;
        std::cout << "Colour was RED\n";
    } else if (colour == Colour::yellow) {
        shape.color.r = 1;
        shape.color.g = 1;
        std::cout << "Colour was YELLOW\n";
    } else if (colour == Colour::green) {
        shape.color.g = 1;
        std::cout << "Colour was GREEN\n";
    } else if (colour == Colour::blue) {
        shape.color.b = 1;
        std::cout << "Colour was BLUE\n";
    } else if (colour == Colour::white) {
        shape.color.r = 1;
        shape.color.g = 1;
        shape.color.b = 1;
        std::cout << "Colour was WHITE\n";
    } // Black is shown by the standard values

    // body.colors.emplace_back();
    using namespace std::chrono_literals;
    shape.lifetime =
        rclcpp::Duration{1s}; // HOw long our marker message is valid for

}



auto Base::resize_imple(AllAxis const new_size) -> void
{
    auto & marker_list = shapes_list_ptr_->markers;
    int target_id = this->id_;
    auto target_marker_ptr = std::find_if(marker_list.begin(), marker_list.end(), [target_id](visualization_msgs::msg::Marker n){
        return (n.id == target_id);
    });
    auto &target_marker = *target_marker_ptr;

    target_marker.scale.x = new_size.get_value();
    target_marker.scale.y = new_size.get_value();
    target_marker.scale.z = new_size.get_value();
}

auto Base::rescale_imple(AnyAxis const factor) -> void
{
    auto & marker_list = shapes_list_ptr_->markers;
    int target_id = this->id_;
    auto target_marker_ptr = std::find_if(marker_list.begin(), marker_list.end(), [target_id](visualization_msgs::msg::Marker n){
        return (n.id == target_id);
    });
    auto &target_marker = *target_marker_ptr;

    target_marker.scale.x = factor.get_value();
    target_marker.scale.y = factor.get_value();
    target_marker.scale.z = factor.get_value();
}

auto Base::get_colour_imple() const -> Colour {
    return this->colour_;
}

auto Base::set_colour_imple(Colour colour) -> void 
{
    auto & marker_list = shapes_list_ptr_->markers;
    int target_id = this->id_;
    auto target_marker_ptr = std::find_if(marker_list.begin(), marker_list.end(), [target_id](visualization_msgs::msg::Marker n){
        return (n.id == target_id);
    });
    auto &target = *target_marker_ptr;
    
    target.color.a = 1;
    target.color.r = 0;
    target.color.b = 0;
    target.color.g = 0;

    if (colour == Colour::red) {
        target.color.r = 1;
        std::cout << "Colour was RED\n";
    } else if (colour == Colour::yellow) {
        target.color.r = 1;
        target.color.g = 1;
        std::cout << "Colour was YELLOW\n";
    } else if (colour == Colour::green) {
        target.color.g = 1;
        std::cout << "Colour was GREEN\n";
    } else if (colour == Colour::blue) {
        target.color.b = 1;
        std::cout << "Colour was BLUE\n";
    } else if (colour == Colour::white) {
        target.color.r = 1;
        target.color.g = 1;
        target.color.b = 1;
        std::cout << "Colour was WHITE\n";
    } // Black is shown by the standard values
    
    this->colour_ = colour; // Store the new colour into the object.
    
}

auto Base::set_parent_frame_name_imple(std::string frame_name) -> void
{
    parent_frame_name_ = std::move(frame_name);
}



auto Base::get_location_imple() const -> std::tuple<XAxis, YAxis, ZAxis>
{
    return std::tuple{XAxis{shapes_list_ptr_->markers[this->id_].pose.position.x}
    , YAxis{shapes_list_ptr_->markers[this->id_].pose.position.y}
    , ZAxis{shapes_list_ptr_->markers[this->id_].pose.position.z}};
}

auto Base::move_to_imple(XAxis const x) -> void {
    auto & marker_list = shapes_list_ptr_->markers;
    int target_id = this->id_;
    auto target_marker_ptr = std::find_if(marker_list.begin(), marker_list.end(), [target_id](visualization_msgs::msg::Marker n){
        return (n.id == target_id);
    });
    auto &target_marker = *target_marker_ptr;
    target_marker.pose.position.x = x.get_value();
}

auto Base::move_to_imple(YAxis const y) -> void {
    auto & marker_list = shapes_list_ptr_->markers;
    int target_id = this->id_;
    auto target_marker_ptr = std::find_if(marker_list.begin(), marker_list.end(), [target_id](visualization_msgs::msg::Marker n){
        return (n.id == target_id);
    });
    auto &target_marker = *target_marker_ptr;
    target_marker.pose.position.y = y.get_value();
}

auto Base::move_to_imple(ZAxis const z) -> void {
    auto & marker_list = shapes_list_ptr_->markers;
    int target_id = this->id_;
    auto target_marker_ptr = std::find_if(marker_list.begin(), marker_list.end(), [target_id](visualization_msgs::msg::Marker n){
        return (n.id == target_id);
    });
    auto &target_marker = *target_marker_ptr;
    target_marker.pose.position.z = z.get_value();
}

/**
 * \brief Move the shape to a new location.
 * \param x new x location
 * \param y new y location
 * \param z new z location
 */

auto Base::move_to_imple(XAxis const x, YAxis const y, ZAxis const z) -> void
{
    auto & marker_list = shapes_list_ptr_->markers;
    int target_id = this->id_;
    auto target_marker_ptr = std::find_if(marker_list.begin(), marker_list.end(), [target_id](visualization_msgs::msg::Marker n){
        return (n.id == target_id);
    });
    auto &target_marker = *target_marker_ptr;
    target_marker.pose.position.x = x.get_value();
    target_marker.pose.position.y = y.get_value();
    target_marker.pose.position.z = z.get_value();
}

auto Base::move_by_imple(XAxis const x) -> void {
    auto & marker_list = shapes_list_ptr_->markers;
    int target_id = this->id_;
    auto target_marker_ptr = std::find_if(marker_list.begin(), marker_list.end(), [target_id](visualization_msgs::msg::Marker n){
        return (n.id == target_id);
    });
    auto &target_marker = *target_marker_ptr;
    target_marker.pose.position.x += x.get_value();
}

auto Base::move_by_imple(YAxis const y) -> void {
    auto & marker_list = shapes_list_ptr_->markers;
    int target_id = this->id_;
    auto target_marker_ptr = std::find_if(marker_list.begin(), marker_list.end(), [target_id](visualization_msgs::msg::Marker n){
        return (n.id == target_id);
    });
    auto &target_marker = *target_marker_ptr;
    target_marker.pose.position.y += y.get_value();
}

auto Base::move_by_imple(ZAxis const z) -> void {
    auto & marker_list = shapes_list_ptr_->markers;
    int target_id = this->id_;
    auto target_marker_ptr = std::find_if(marker_list.begin(), marker_list.end(), [target_id](visualization_msgs::msg::Marker n){
        return (n.id == target_id);
    });
    auto &target_marker = *target_marker_ptr;
    target_marker.pose.position.z += z.get_value();
}

auto Base::move_by_imple(XAxis const x, YAxis const y, ZAxis const z) -> void {
    auto & marker_list = shapes_list_ptr_->markers;
    int target_id = this->id_;
    auto target_marker_ptr = std::find_if(marker_list.begin(), marker_list.end(), [target_id](visualization_msgs::msg::Marker n){
        return (n.id == target_id);
    });
    auto &target_marker = *target_marker_ptr;

    target_marker.pose.position.x += x.get_value();
    target_marker.pose.position.y += y.get_value();
    target_marker.pose.position.z += z.get_value();
}

/**
 * \brief Return marker message for displaying the shape
 * \return shape marker message
 * ====================== Doesn't actually work due to usage of marker array rather than a vector of markers
 */
auto Base::get_display_markers_imple()
    -> std::shared_ptr<std::vector<visualization_msgs::msg::Marker>>
{
    std::shared_ptr<std::vector<visualization_msgs::msg::Marker>> marker_vector;
    return marker_vector;
}

} // namespace shapes
