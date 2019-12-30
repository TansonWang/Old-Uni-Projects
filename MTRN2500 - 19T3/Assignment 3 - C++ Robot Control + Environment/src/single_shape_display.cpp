// Copyright 2019 Zhihao Zhang License MIT

#include "single_shape_display.hpp"

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
SingleShapeDisplay::SingleShapeDisplay(std::string const & node_name,
    std::chrono::milliseconds const refresh_period)
    : rclcpp::Node{node_name}
    , marker_publisher_{create_publisher<visualization_msgs::msg::Marker>(
          "z0000000/singlemarker", 10)} // Set the publisher name
    , timer_{create_wall_timer(
          refresh_period, [this]() -> void { marker_publisher_callback(); })} // Periodically publish
{
}

auto SingleShapeDisplay::display_object_imple(
    std::shared_ptr<shapes::DisplayableInterface> const display_object) -> void // Displayable Interface from interfaces.hpp
{
    object_to_be_displayed_ = display_object; // set the shared pointer to a different name
}

// ReSharper disable once CppMemberFunctionMayBeConst
auto SingleShapeDisplay::marker_publisher_callback() -> void
{
    auto const shapes_list = object_to_be_displayed_->get_display_markers(); // Get a list of the shapes
    if (shapes_list)
    {
        for (auto & shape : *shapes_list) // Loops through using shapes_list as the range
        {
            shape.header.stamp = rclcpp::Time{0}; // Change the time stamp for each shape
            marker_publisher_->publish(shape); // Publish the changed shape
        }
    }
}
} // namespace display
