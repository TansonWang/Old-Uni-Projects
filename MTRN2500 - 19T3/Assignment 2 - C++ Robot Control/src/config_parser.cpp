// Copyright 2019 Zhihao Zhang License MIT

#include "config_parser.hpp"

#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <unordered_map>
#include <algorithm>

namespace assignment2
{
ConfigReader::ConfigReader(std::istream & config_file)
{
    std::cout << "\n========================================================" << std::endl;
    std::cout << "This is the Config Reader - File Reader section." << std::endl;
    std::string input;
    int i = 1;
     
    while (config_file.good()) {
        std::getline(config_file, input);

        // Terminate if empty line found
        if (input.empty()) {
            break;
        }

        // First printing of Line Number and entire line
        std::cout << "Line " << i++ << " : " << input << std::endl;

        // Remove blank space
        input.erase(remove_if(input.begin(), input.end(), isspace), input.end());

        // Get the first value and turn it into a string
        std::string key = input.substr(0, input.find(":")); // substr( postion, length of string)
        std::string value = input.substr(input.find(":") + 1);

        // Map the key - value
        config_[key] = value;

    }

    std::cout << "\n========================================================" << std::endl;
    std::cout << "This is the Config Reader - Seperated Key-Value section." << std::endl;

    for( auto const& [key, val] : config_ ) {
        // Second printing but only the key-value pair
        std::cout << key << " : " << val << std::endl;
    }

}

auto ConfigReader::find_config(std::string const & key,
    std::string const & default_value) const -> std::string
{
    // std::cout << "\n========================================================" << std::endl;
    // std::cout << "This is the Find Config section." << std::endl;
    
    // Locates the key in the config_ map and returns its value
    // if there was no value found, return the default value

    auto i = default_value;
    std::string type = "Is default value ";

    if (config_.find(key) != config_.end()) {
        i = config_.at(key);
        type = "Is file value ";
        //std::cout << key << " : " << i << std::endl;
    }

    // std::cout << type << key << " : " << i << std::endl;
    return i;
}

ConfigParser::ConfigParser(ConfigReader const & config)
    : zid_{
        config.find_config("zid", std::string{"z0000000"})}
        , joy_config_{stoi(config.find_config("speed_plus_axis", std::string{"2"}))
        , stoi(config.find_config("speed_minus_axis", std::string{"5"}))
        , stoi(config.find_config("steering_axis", std::string{"3"}))
        , stod(config.find_config("steering_deadzone", std::string{"0.1"}))
        , stod(config.find_config("speed_deadzone", std::string{"0.2"}))
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
} // namespace assignment2
