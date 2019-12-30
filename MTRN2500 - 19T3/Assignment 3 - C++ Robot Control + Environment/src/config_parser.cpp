// Copyright 2019 Zhihao Zhang License MIT
 
#include "config_parser.hpp"
 
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <unordered_map>
#include <algorithm>
 
namespace assignment3
{
ConfigReader::ConfigReader(std::istream & config_file)
{
    std::cout << "Reading file line by line" << std::endl;
    std::string input;
    int i = 1;
     
    while (config_file.good()) {
        std::getline(config_file, input);
 
        // Break if it reaches an empty line
        if (input.empty()) {
            break;
        }
 
        std::cout << "Line " << i++ << " : " << input << std::endl;
 
        // Remove blank space
        input.erase(remove_if(input.begin(), input.end(), isspace), input.end());
 
        // Get the first value and turn it into a string
        std::string key = input.substr(0, input.find(":")); // substr( postion, length of string)
        std::string value = input.substr(input.find(":") + 1);
 
        // Map the key to values as an array
        config_[key] = value;
 
    }
    std::cout << " " << std::endl;
    std::cout << "Reading by key-value format" << std::endl;
    std::cout << "Unordered map" << std::endl;
 
    for( auto const& [key, val] : config_ ) {
        // Second printing but only the key-value pair
        std::cout << "Key " << key << ", value: " << val << std::endl;
    }
 
}
 
auto ConfigReader::find_config(std::string const & key,
    std::string const & default_value) const -> std::string
{
    
    // Locates the key in the config_ map and returns its value
    // if there was no value found, return the default value
 
    auto i = default_value;
    std::string type = "Is default value ";
 
    if (config_.find(key) != config_.end()) {
        i = config_.at(key);
        type = "Is file value ";
        
    }
 
    
    return i;
}
 
ConfigParser::ConfigParser(ConfigReader const & config)
    : zid_{
        config.find_config("zid", std::string{"z0000000"})}
        , joy_config_{stoi(config.find_config("speed_plus_axis", std::string{"0"}))
        , stoi(config.find_config("speed_minus_axis", std::string{"1"}))
        , stoi(config.find_config("steering_axis", std::string{"3"}))
        , stod(config.find_config("steering_deadzone", std::string{"0.1"}))
        , stod(config.find_config("speed_deadzone", std::string{"0.2"}))
        , stoi(config.find_config("LT", std::string{"4"}))
        , stoi(config.find_config("RT", std::string{"5"}))
        , stoi(config.find_config("dropButton", std::string{"0"}))
        , stoi(config.find_config("clearButton", std::string{"1"}))
    }
 
    , kinematic_config_{
        stod(config.find_config("max_linear_speed", std::string{"1"}))
        , stod(config.find_config("max_angular_speed", std::string{"45"}))
        , stod(config.find_config("max_linear_acceleration", std::string{"0.5"}))
        , stod(config.find_config("max_angular_acceleration", std::string{"10"}))
    }
    , refresh_period_{
        std::chrono::milliseconds(stoi(config.find_config("refresh_rate", std::string{"10"})))
    }
{
 
}
 
auto ConfigParser::get_zid() const -> std::string { return zid_; }
 
auto ConfigParser::get_refresh_period() const -> std::chrono::milliseconds
{
    return refresh_period_;
}
 
auto ConfigParser::get_joystick_config() const -> JoystickConfig
{
    return joy_config_;
}
 
auto ConfigParser::get_kinematic_config() const -> KinematicLimits
{
    return kinematic_config_;
}
} // namespace assignment3