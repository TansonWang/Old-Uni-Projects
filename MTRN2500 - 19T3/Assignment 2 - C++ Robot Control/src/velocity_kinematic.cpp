#include "velocity_kinematic.hpp"

#include "student_helper.hpp"

#include <cassert>
#include <memory>
#include <string>
#include <utility>

namespace assignment2
{
VelocityKinematic::VelocityKinematic(std::string const & zid,
    std::chrono::milliseconds const refresh_period, KinematicLimits config)
    : rclcpp::Node(helper::velocity_node_name(zid))
    , zid_{zid}
    , config_{config}

{
    // Subscribe to Acceleration 
    auto callback = std::bind(&VelocityKinematic::acceleration_callback, this, std::placeholders::_1);
    this->acceleration_input_ = create_subscription<geometry_msgs::msg::AccelStamped>(std::string{"/z0000000/acceleration"}, 10, callback); 

    // Publish to Velocity Kinematic
    velocity_output_ = create_publisher<geometry_msgs::msg::TwistStamped>(std::string{"/z0000000/velocity"}, 10); 

    // Creates the unique pointers 
    velocity_ = std::make_unique<geometry_msgs::msg::TwistStamped>();
    acceleration_ = std::make_unique<geometry_msgs::msg::AccelStamped>();  

    // Create the timer wall and apply error checking
    this->timer_ = create_wall_timer(std::chrono::milliseconds{refresh_period},
                    [this]() {
                        double stored_time = velocity_->header.stamp.sec + velocity_->header.stamp.nanosec/1e9;                        
                        
                        if ((now() - velocity_->header.stamp).seconds() >= 10 && stored_time != 0) { // 10 sec inactivity error
                            std::cout << "Communication Lost\n";
                            velocity_->header.stamp.sec = 0;
                            velocity_->header.stamp.nanosec = 0;
                        } 
                        else if (stored_time != 0) {                        // Only executes when subscribed data is is converted at any point
                            VelocityKinematic::velocity_callback();
                        }
                        
                      }
            );

}

auto VelocityKinematic::acceleration_callback(
    geometry_msgs::msg::AccelStamped::UniquePtr input_message) -> void
{
    std::cout << "\n========================================================" << std::endl;
    std::cout << "This is the Velocity Kinematic section." << std::endl;

    // Calculates the difference in time 
    auto curr_time = now();
    double dt = (curr_time-input_message->header.stamp).seconds();

    // Calculates the scaled acceleration
    double scaled_linear_accel = input_message->accel.linear.x * config_.max_linear_acceleration;
    double scaled_angular_accel = input_message->accel.angular.z * config_.max_angular_acceleration;

    // std::cout << scaled_linear_accel << std::endl;
    // std::cout << input_message->accel.linear.x << std::endl;

    // v(t+dt) = v(t) + dt * a(t) where a(t) is scaled by the max acceleration value from config
    velocity_->twist.linear.x += dt * scaled_linear_accel; 
    velocity_->twist.angular.z += dt * scaled_angular_accel;
    velocity_->header.stamp = curr_time; // Storing the time stamp 
    velocity_->header.frame_id = this->zid_; // This-> technically unnecessary but helps in understanding
    
    // Limit velocity within its max
    if (abs(velocity_->twist.linear.x) > config_.max_linear_speed) {
        velocity_->twist.linear.x = config_.max_linear_speed;
    }
    if (abs(velocity_->twist.linear.y) > config_.max_linear_speed) {
        velocity_->twist.linear.y = config_.max_linear_speed;
    }
    if (abs(velocity_->twist.angular.z) > config_.max_angular_speed) {
        velocity_->twist.angular.z = config_.max_angular_speed;
    }
    
    
    // Print everything 
    std::cout << "DT: " << dt; 
    std::cout << ", Linear Acceleration: " << scaled_linear_accel;
    std::cout << ", Linear Velocity: " << velocity_->twist.linear.x;
    std::cout << ", Angular Acceleration: " << scaled_angular_accel;
    std::cout << ", Angular Velocity: " << velocity_->twist.angular.z << std::endl;
    

}

auto VelocityKinematic::velocity_callback() -> void
{
    // Publishes the velocity
    velocity_output_->publish(*velocity_); // Dereferences the pointer 
}
} // namespace assignment2