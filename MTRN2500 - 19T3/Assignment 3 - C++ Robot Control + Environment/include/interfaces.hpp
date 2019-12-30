// Copyright 2019 Zhihao Zhang License MIT

#ifndef INTERFACES_HPP_
#define INTERFACES_HPP_

#include "visualization_msgs/msg/marker.hpp"

#include <memory>
#include <string>
#include <tuple>
#include <type_traits>
#include <utility>
#include <vector>

namespace helper
{
class PolymorphicInterface
{
public:
    PolymorphicInterface() = default;
    PolymorphicInterface(PolymorphicInterface const &) = delete;
    PolymorphicInterface(PolymorphicInterface &&) = default;
    auto operator=(PolymorphicInterface const &) = delete;
    auto operator=(PolymorphicInterface &&) -> PolymorphicInterface & = default;
    virtual ~PolymorphicInterface() = default;
};
} // namespace helper
namespace shapes
{
using helper::PolymorphicInterface;
struct AxisInterface
{
    [[nodiscard]] auto get_value() const { return value_; } // Method to return value for other classes
    auto set_value(double const value) { value_ = value; } // Method to change value

protected:
    double value_;
    explicit AxisInterface(double const initial_value) // Constructor which sets value_ to value
        : value_{initial_value} {};
};

struct AnyAxis final : public AxisInterface /* Derived from Axis Interface */
{
public:
    explicit AnyAxis(double const initial_value)
        : AxisInterface{initial_value} // Constructore as from Axis Interface
    {
    }
    template <class OtherAxis,
        class = std::enable_if_t<std::is_base_of_v<AxisInterface, OtherAxis>>>
    // ReSharper disable once CppNonExplicitConversionOperator
    operator OtherAxis() const
    {
        return OtherAxis{value_};
    }
};

struct XAxis final : public AxisInterface
{
public:
    explicit XAxis(double const initial_value)
        : AxisInterface{initial_value}
    {
    }
};

struct YAxis final : public AxisInterface
{
public:
    explicit YAxis(double const initial_value)
        : AxisInterface{initial_value}
    {
    }
};

struct ZAxis final : public AxisInterface
{
public:
    explicit ZAxis(double const initial_value)
        : AxisInterface{initial_value}
    {
    }
};

struct AllAxis final : public AxisInterface
{
public:
    explicit AllAxis(double const initial_value)
        : AxisInterface{initial_value}
    {
    }
    template <class OtherAxis,
        class = std::enable_if_t<std::is_base_of_v<AxisInterface, OtherAxis>>>
    operator OtherAxis() const
    {
        return OtherAxis{value_};
    }
};

template <class Axis>
class ResizeableInterfaceBase : public PolymorphicInterface
{
public:
    auto resize(Axis new_size) { return resize_imple(new_size); }
    auto rescale(AnyAxis const factor) { return rescale_imple(factor); }

private:
    virtual auto resize_imple(Axis new_size) -> void = 0;
    virtual auto rescale_imple(AnyAxis factor) -> void = 0;
};

using BasicResizeableInterface = ResizeableInterfaceBase<AllAxis>;

class LocationInterface : public PolymorphicInterface
{
public:
    auto set_parent_frame_name(std::string frame_name)
    {
        return set_parent_frame_name_imple(std::move(frame_name));
    }
    [[nodiscard]] auto get_location() const { return get_location_imple(); }

    auto move_to(XAxis const new_location)
    {
        return move_to_imple(new_location);
    }
    auto move_to(YAxis const new_location)
    {
        return move_to_imple(new_location);
    }
    auto move_to(ZAxis const new_location)
    {
        return move_to_imple(new_location);
    }
    auto move_to(XAxis const new_x, YAxis const new_y, ZAxis const new_z)
    {
        return move_to_imple(new_x, new_y, new_z);
    }

    auto move_by(XAxis const distance) { return move_by_imple(distance); }
    auto move_by(YAxis const distance) { return move_by_imple(distance); }
    auto move_by(ZAxis const distance) { return move_by_imple(distance); }
    auto move_by(XAxis const dx, YAxis const dy, ZAxis const dz)
    {
        return move_by_imple(dx, dy, dz);
    }

private:
    virtual auto set_parent_frame_name_imple(std::string frame_name)
        -> void = 0;
    [[nodiscard]] virtual auto get_location_imple() const
        -> std::tuple<XAxis, YAxis, ZAxis> = 0;
    virtual auto move_to_imple(XAxis new_location) -> void = 0;
    virtual auto move_to_imple(YAxis new_location) -> void = 0;
    virtual auto move_to_imple(ZAxis new_location) -> void = 0;
    virtual auto move_to_imple(XAxis new_x, YAxis new_y, ZAxis new_z)
        -> void = 0;
    virtual auto move_by_imple(XAxis distance) -> void = 0;
    virtual auto move_by_imple(YAxis distance) -> void = 0;
    virtual auto move_by_imple(ZAxis distance) -> void = 0;
    virtual auto move_by_imple(XAxis dx, YAxis dy, ZAxis dz) -> void = 0;
};

class YawInterface : public PolymorphicInterface
{
public:
    auto rotate_about_axis_to(ZAxis const radians)
    {
        return rotate_about_axis_to_imple(radians);
    }

    [[nodiscard]] auto get_orientation() const
    {
        return get_orientation_imple();
    }

private:
    virtual auto rotate_about_axis_to_imple(ZAxis radians) -> void = 0;

    [[nodiscard]] virtual auto get_orientation_imple() const -> ZAxis = 0;
};

class ColourInterface : public PolymorphicInterface
{
public:
    enum class Colour : unsigned char
    {
        red,
        yellow,
        green,
        blue,
        black,
        white
    };

    auto set_colour(Colour const new_colour)
    {
        return set_colour_imple(new_colour);
    }
    [[nodiscard]] auto get_colour() const { return get_colour_imple(); }

private:
    virtual auto set_colour_imple(Colour new_colour) -> void = 0;
    [[nodiscard]] virtual auto get_colour_imple() const -> Colour = 0;
};

class DisplayableInterface : public PolymorphicInterface
{
public:
    auto get_display_markers() { return get_display_markers_imple(); }

private:
    virtual auto get_display_markers_imple()
        -> std::shared_ptr<std::vector<visualization_msgs::msg::Marker>> = 0;
};

class ShapeCommonInterface : public virtual BasicResizeableInterface,
                             public virtual LocationInterface,
                             public virtual ColourInterface,
                             public virtual DisplayableInterface
{
};
} // namespace shapes

namespace display
{
using helper::PolymorphicInterface;
class DisplayOutputInterface : public PolymorphicInterface
{
public:
    auto display_object(
        std::shared_ptr<shapes::DisplayableInterface> object) // Intakes an object
    {
        return display_object_imple(std::move(object)); // Goes to single_shape_display and sets it as object to be displayed
    }

private:
    virtual auto display_object_imple(
        std::shared_ptr<shapes::DisplayableInterface> object)
        -> void = 0;
};
} // namespace display
#endif // INTERFACES_HPP_
