// Copyright 2019 Zhihao Zhang License MIT

#include "marker_broadcaster.hpp"
#include "sphere.hpp"
#include "cube.hpp"
#include "cone.hpp"
#include "cylinder.hpp"
#include "pyramid.hpp"
#include "prism.hpp"
#include "cone.hpp"
#include "parallelepiped.hpp"

#include "student_helper.hpp"

#include <memory>
#include <string>
#include <utility>
#include <vector>

namespace
{
auto constexpr marker_topic = [](std::string const & zid) {
    return "/" + zid + "/UAV";
};
} // namespace

namespace assignment3
{
MarkerBroadcaster::MarkerBroadcaster(std::string const & zid,
    std::chrono::milliseconds const refresh_period,
    std::shared_ptr<visualization_msgs::msg::MarkerArray> shape_list_ptr)
    : rclcpp::Node{helper::marker_node_name(zid)}
    , marker_publisher_{create_publisher<visualization_msgs::msg::MarkerArray>(
          marker_topic(zid), 10)}
    , timer_{create_wall_timer(
          refresh_period, [this]() -> void { marker_publisher_callback(); })}
    , shape_list_ptr_{std::move(shape_list_ptr)}
    , zid_{zid}
{
    // subscriber code to pose topic
    auto callback = std::bind(&MarkerBroadcaster::pose_callback, this, std::placeholders::_1);
    this->pose_input_ = create_subscription<geometry_msgs::msg::PoseStamped>(std::string("/z0000000/pose"), 10, callback);
    assert(shape_list_ptr_);
    //Make a unique pointer
    pose_ = std::make_unique<geometry_msgs::msg::PoseStamped>();

    //auto & marker_array = shape_list_ptr->markers;
    auto UAV_1 = std::make_shared<shapes::Cylinder>(9001,1,1,shape_list_ptr_, 0, 0, 0, 0, shapes::ColourInterface::Colour::yellow);
    auto UAV_2 = std::make_shared<shapes::Cone>(9002,1,shape_list_ptr_,1,0,0, 0, shapes::ColourInterface::Colour::yellow);
    auto UAV_arrow = std::make_shared<shapes::Cone>(9101,1,shape_list_ptr_, 1, 1, 1, 0, shapes::ColourInterface::Colour::yellow);
    std::cout << "ded\n";
}

// ReSharper disable once CppMemberFunctionMayBeConst
auto MarkerBroadcaster::marker_publisher_callback() -> void
{
    marker_publisher_->publish(shape_list_ptr_);
}

auto MarkerBroadcaster::pose_callback(
geometry_msgs::msg::PoseStamped::UniquePtr input_message) -> void  

{
    // Publish the information
    assert(shape_list_ptr_);

}

} // namespace assignment3

auto assignment3::MarkerBroadcaster::callback(geometry_msgs::msg::PoseStamped input_message) -> void
{
    int x = input_message.pose.position.x;
    int y = input_message.pose.position.y;
    int z = input_message.pose.position.z;

    auto & marker_list = shape_list_ptr_->markers;
    std::cout << "X position is " << x << std::endl;
    marker_list[0].pose.position.x = x;
    marker_list[0].pose.position.y = y;
    marker_list[0].pose.position.z = z;

}
