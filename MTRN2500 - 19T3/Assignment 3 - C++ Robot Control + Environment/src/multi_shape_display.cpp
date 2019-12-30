// Copyright 2019 Zhihao Zhang License MIT

#include "multi_shape_display.hpp"

#include "student_helper.hpp"

#include <memory>
#include <string>
#include <vector>

namespace 
{
auto constexpr marker_topic = [](std::string const & zid) {
    return "/" + zid + "/marker";
};
} // namespace

namespace display
{
MultiShapeDisplay::MultiShapeDisplay(std::string const & node_name,
    std::chrono::milliseconds const refresh_period,
    std::shared_ptr<visualization_msgs::msg::MarkerArray> marker_list)
    : rclcpp::Node{node_name}
    , marker_publisher_{create_publisher<visualization_msgs::msg::MarkerArray>(
          "z0000000/marker", 10)} // Set the publisher name
    , timer_{create_wall_timer(
          refresh_period, [this]() -> void { marker_publisher_callback(); })} // Periodically publish
    , marker_list_ {marker_list}
{
}

auto MultiShapeDisplay::display_object_imple(
    std::shared_ptr<shapes::DisplayableInterface> const display_object) -> void // Displayable Interface from interfaces.hpp
{
    object_to_be_displayed_ = display_object; // set the shared pointer to a different name
}

// ReSharper disable once CppMemberFunctionMayBeConst
auto MultiShapeDisplay::marker_publisher_callback() -> void
{
    auto const shapes_list = marker_list_; // Get a list of the shapes
    // std::cout << "Size of Published List is " << shapes_list->markers.size() << std::endl;
    marker_publisher_->publish(shapes_list);
}
} // namespace display
