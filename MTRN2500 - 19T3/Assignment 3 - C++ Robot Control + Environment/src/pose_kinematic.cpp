// Copyright 2019 Zhihao Zhang License MIT

#include "pose_kinematic.hpp"

#include "student_helper.hpp"

#include <cassert>
#include <memory>
#include <string>
#include <utility>
#include <math.h>

namespace assignment3
{
PoseKinematic::PoseKinematic(
    std::string const & zid, std::chrono::milliseconds const refresh_period)
    : rclcpp::Node(helper::pose_node_name(zid))
    ,zid_{zid}

{
     // Make unique pointers
    velocity_ = std::make_unique<geometry_msgs::msg::TwistStamped>();
    pose_ = std::make_unique<geometry_msgs::msg::PoseStamped>();
 
    // Subscribe to Velocity
    auto callback = std::bind(&PoseKinematic::velocity_callback, this, std::placeholders::_1);
    this->velocity_input_ = create_subscription<geometry_msgs::msg::PoseStamped>(std::string{"/z0000000/velocity"}, 10, callback);
    
    // Subscribe to Joy

    // Publish to Velocity Kinematic
    pose_output_ = create_publisher<geometry_msgs::msg::PoseStamped>(std::string{"/z0000000/pose"}, 10);
 
    // Periodic call from timer
    this->timer_ = create_wall_timer(std::chrono::milliseconds{refresh_period},
                    [this]() {
                            PoseKinematic::pose_callback();
                        }
            );
}

auto PoseKinematic::velocity_callback(
    geometry_msgs::msg::TwistStamped::UniquePtr input_message) -> void
{
    
    std::cout << "Pose" << std::endl;
    // Integrates the velocity from subscription
    double dt = (now()-input_message->header.stamp).seconds();
    auto time = now() - input_message->header.stamp;
 
    pose_->pose.position.x += dt * input_message->twist.linear.x * std::cos(input_message->twist.angular.z);
    pose_->pose.position.y += dt * input_message->twist.linear.x * std::sin(input_message->twist.angular.z);
    
    pose_->pose.orientation.z += dt * input_message->twist.angular.z;
    pose_->header.stamp = input_message->header.stamp;
   
    pose_->header.frame_id = this ->zid_;
    // Show the current values for x, y and orientation periodically
    std::cout << ">------------------------------------------<" << std::endl;
    std::cout << "X:" << pose_->pose.position.x << std::endl;
    std::cout << "Y:" << pose_->pose.position.y << std::endl;
    std::cout << "O:" << pose_->pose.orientation.z << std::endl;
    std::cout << ">------------------------------------------<" << std::endl;
}

auto PoseKinematic::pose_callback() -> void
{
    // Publish the information
    pose_output_->publish(*pose_);
}
} // namespace assignment3
