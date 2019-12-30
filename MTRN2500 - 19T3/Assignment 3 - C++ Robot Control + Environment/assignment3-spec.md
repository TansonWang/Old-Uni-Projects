# Assignment 3: Vehicle Game

## Relevant course learning objectives
1.	Be well versed with structured and modular programming using C/C++ and to appreciate the use of software to communicate with external devices.  
2.	Understand how to interface to an external device through a computer program to effect control action.  
3.	Be able to develop prototype user interfaces to assist in the development of controlled Mechatronic systems.  

## Assignment learning objectives
* Structure a set of classes appropriately, handling inheritance, access and polymorphism.
* Make use of external libraries (including ROS) to parse user input from config files and an external device.
* Implement real-time visualisation and control of simulated objects in response to user input.
* Follow a prescribed C++ coding style.
* Collaborate within a small team effectively using code management tools and practices.

## Getting started
Choose a team member from within your tutorial as you will be working in pairs. You will be be collaborating with your team member using the private Github assignment3 repository created for your team.

After the repository was created, you must do the following:

1. Both members need to add an empty file to the root directory of the repository with their zid as the filename in the format `z0000000.txt`. 
2. One member only will create a `review` branch. The style task will be assessed on that branch. **Do not merge anything into this branch**. This branch must be named `review`.
3. Each member must create their own development branches, each with a meaningful branch name (ie `process_input`). You should be doing work in a development branch and only merge tested working code into the `master` branch after you have completed a requirement. Failure to correctly branch off may lead to team members' code being lost.

**Do not modify `interfaces.hpp`, you may modify all other `hpp` and `cpp` files. If you want to add extra `hpp` or `cpp` files, you need to update `CMakeLists.txt`, in the `target_sources` section.**


## Submission process
One member will create a **pull request** to pull commits from the `master` into the `review` branch with all your commits. 

## Deadlines
Code will be due by Friday 5 pm week 12 (6 December) for style checking. Your demonstration will be during your lab timeslot in week 13 (during the exam period), and you can edit your demonstration code until that point (but commits after 5pm Friday week 12 will not be checked for style).

There will be no lab class in week 10 (as it has been moved to week 13). However, consultations will be made available between weeks 10 and 13.

At least one member must be available for the final demonstration for presenting your work.
 
## Task Overview
Your team has been tasked with developing a Unmanned Aerial Vehicle (UAV) simulator that shows a single UAV dropping blocks in a Minecraft like game.
Players will use a game controller to fly the UAV and drop blocks.

Begin by looking at the provided interface diagram, and designing the additional classes that are needed, including the methods that will be required in each class (before you even start thinking about coding them!). These classes will include not only shapes, but one or more vehicle related classes. You will probably want a class to represent your UAV, which you will draw using the shapes listed below (see the sections at the bottom of this document).

Once you have designed your classes, consider how they will integrate with the joystick input topic (the same starting topic as Assignment 2), as well as pushing shapes to your marker topic. The provided code only handles pushing one shape at a time, so think about how you will push a whole set of shapes to be displayed - more hints are below. 

### Simulation Scene
In RVIZ2, show the ground using a green `Flat Plane` shape object. 
Add some variety to the simulation scene by including some static objects such as trees and houses. You need to use all the shapes at least once. 

For the UAV, you will be designing your own UAV. You can be as creative as you want with your design, as along as you use each shape at least once. Pick any colour for the starting block, attached to the bottom of your UAV.

## Tasks
This assignment is out of 40 marks scaled to to 20% of your course grade.

### Program Demonstration (20 marks):
1. Show a variety of static objects in RVIZ2, such as trees and rocks. Use each shape at least once. 
1. Display your UAV in RVIZ2. You will not have to modify the shape of the UAV for demonstration. Your UAV will also be holding a coloured block below it.
1. Control your UAV using a joystick controller, further requirements are given in UAV controls section.
1. Release the held block from the UAV by the press of a joystick button. The block will remain at the position and orientation it was released at.
1. Immediately spawn a new block after the previous block has been released. The block should have the next colour from the list of colours given in the ColourInterface section. Cycle back to the beginning once all the colours have been shown.
1. Have a joystick button that will clear all the blocks.

Your tutor will also assess how well your program works overall.

#### UAV controls

1. Left One thumbstick control the x and y position of the UAV.
2. Left and right triggers raise and lower the UAV respectively.
3. Right joystick control the heading (yaw) of the UAV.
5. Button X should release a block. Only release one block per button press.
5. Right shoulder button clear all the blocks.

**Hint: You may be able to modify assignment 2 code for this part. You can make the customisable via a config file (as per assignment 2), but this is not strictly required.**

#### Error handling
Your program should handle all possible errors including but not limited to:
1. Lost connection to the controller.
2. UAV flying too high or too low or lost UAV. You may set these limits, but they must be sensible.
3. Incorrect axis configuration.

Error handling must not crash the program but may exit the program with an error message if it's the most suitable solution. 
The end-user experience will be taken into consideration in your demonstration.

### Program Design Presentation (10 marks):
Prepare a short presentation or talk (around 4 min) for your tutor on the design you have chosen or rejected, and the reasoning behind your design. Discuss how you have applied polymorphism, inheritance, composition, functions, DRY principles, etc, and the overall structure of your program.

This will be presented in person in your demonstration slot. Your tutor will then ask some questions about your design choices.

**Hint: You are not limited to only implementing the 3D shapes required in this assignment spec.**

### Teamwork and style (10 marks):
You need to conduct code reviews and provide feedback on your partner's code in a timely manner. Evidence of this will need to be in GitHub. You are also responsible for testing your partner's code, it is highly recommended you write test cases to make sure your code still works for the demonstration. 

Your tutor may balance the distribution of marks between team members based on objective evidence on GitHub. Please let your tutor or the lecturer know if there are any issues with your group.

**Hint: Github issue tracker, pull requests, and projects can all be used as evidence of a member contribution.**

#### Style
The most important thing with style is to make your code understandable to other people. 

* Follow the course style guide in `style_guide.md` in this repository which is based on ROS2 development guide. When contributing to an existing codebase, you should follow the style already being used. This ensures consistency between developers and helps to maintain the codebase quality.
* Neat and tidy code, style is consistent throughout. Ensure your code is formatted according to the clang-format file, this ensures your code does not inadvertently get changed when other people work in the same file, polluting the git commit history. Clang-format is commonly used to automatically format the code. Most programming IDE have clang-format integration built in. 
* Good choice of names that are meaningful and descriptive.
* Good use of functions to split code into manageable segments and avoid code duplication (DRY principle).
* Appropriate use of C++ features.
* Good documentation and comments. Comments should explain the technical aspects of your code, not merely restating what you have written.
* No error or warning messages when compiling. Error and warning messages are generally sign something is wrong with your program.
* The master branch must be able to compile and work. This ensures you always have a working copy for demonstration.
* Consistent use of source management. Development should be done in feature based branches and merged into the `master` branch incrementally after milestone development is complete. 
* Keep your Github repository up to date with your work. 
* Write meaningful commit messages.

We use automated tool to check your code compiles and adhere to the style guide. The tool will compile your code when you merge code to the master branch or when you make a pull request to review branch. You can check the result by going to the check tab of your pull request and click the build link. We will run the following tools:
1. Colcon to build the project.
1. Cpplint to check compliance with the style guide.
1. Cppcheck normally doesn't cause any issue.
1. Clang-format to check for formatting.

You can also run the tests locally by running colcon in test mode. Please consult the colcon documentation. 

## Bonus Marks (2 marks each):
Must be fully functioning and impress the tutor to get the marks. Tutors will only provide assistance for the basic tasks.
1. Have the UAV rotors spin with their velocity corresponding to the height of the UAV. For this, you need to show at least two rotors.
2. Rather than have the block stay stationary, show the dropped block falling to the ground at a constant velocity of 0.1m/s and stop on the ground plane. You may ignore collision with other objects.

## Abstract Classes
Through an abstract class, a set of common functionalities shared by all the derived class may be defined. This creates an interface through which user can use any the derived classes. An [interface](https://en.wikipedia.org/wiki/Interface_(computing)) in computing describes the shared boundary between separate components of a program.
In this assignment abstract classes that specify an interface between different section of the program will be denoted with the word `Interface` in their name. For example if `Sphere` is derived from `ShapeCommonInterface`, then `Sphere` is guaranteed to have all the functions specified in `ShapeCommonInterface`.

The interface classes will be implemented using [Non-Virtual Interface](https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Non-Virtual_Interface) pattern. 
Each interface class will specify the public interface through a set of public non-virtual functions. 
The public interface functions will call private virtual implementation functions that a class implementing the interface need to implement. Your class needs to implement those virtual functions.

A brief overview of all the interfaces will be provided here, 
You need to select the appropriate interfaces for your classes.
You may need to add additional interfaces.

How the interfaces fits together is illustrated in inheritance_diagram.png.

### Coordinate System Interfaces
The following interfaces allow the manipulation of a coordinate position and orientation.

#### AxisInterface
`AxisInterface` represents some value with respect to some axis of a coordinate system. The value can be modified or rescaled.
Example of what the value would represent can be location, distance or angle.

For simplicity in this assignment, some components that would be expected from a fully designed axis library are omitted. For example, additional types could be used to express what units the value represents. Math operators are can be provided to make value manipulation easier.

Classes implementing this interface have been provided for you. `XAxis`, `YAxis`, and `ZAxis` represent the x, y, and z-axes respectively. `AllAxis` represents a value that applies to all three axes. `AnyAxis` represents a value that is not associated with a particular axis, it could be applied to any axis.

#### LocationInterface
`LocationInterface` represents the location of an object in 3D space. Essentially a linear translation of the coordinate frame with respect to a parent frame. The point may be moved to a new position or moved by a certain distance. The location of a point can be obtained as a `std::tuple` of `XAxis`, `YAxis`, `ZAxis`. 

#### YawInterface
`YawInterface` represents the rotation of an object about the z-axis, use units in radians.

#### DisplayableInterface
`DisplayableInterface` is able to return a `std::shared_ptr` of `visualization_msgs::msg::Marker` to be used to display the object in RVIZ.

#### DisplayOutputInterface
`DisplayOutputInterface` will get the marker message from `DisplayableInterface` and send the marker to RVIZ.

**Hint: Think about how `std::uniqu_ptr`, `std::shared_ptr` and `std::weak_ptr` can be used to model resource ownership.**

#### ResizeableInterfaceBase
`ResizeableInterfaceBase` represents the ability to resizing the object in one of the axes to a new size or rescaling by a factor,
with respect to certain `AxisInterface`. 
`BasicResizeableInterface` requires equal scaling in the x,y and z-axis.

### ColourInterface
`ColourInterface` get and set the colour of a displayable object.
Colour may be one of the following: 
* red
* yellow
* green
* blue
* black
* white

Exact RGB values for each colour is not specified, just make it obvious which colour it is.

### ShapeCommonInterface
All shapes need to implement this common interface:
```c++
	class ShapeCommonInterface : 
		public virtual BasicResizeableInterface,
		public virtual LocationInterface,
		public virtual YawInterface,
		public virtual DisplayableInterface
	{
	};
```


## Shapes Specification
You need to design a class hierarchy using polymorphism, class inheritance and composition of the following shapes. 

1. Octagonal Prism
1. Rectangular Prism
1. Triangular Prism
1. Octagonal Pyramid
1. Rectangular Pyramid
1. Triangular Pyramid
1. Square Pyramid
1. Sphere
1. Parallelepiped
1. Cube
1. Cone
1. Cylinder
1. Flat Plane

How to specify the dimension of each shape is an implementation detail you can decide.

**Hint: While RVIZ only have cube, sphere, cylinder, and triangle shapes built in,
other shapes can be constructed using those basic shapes. See section 1.3.12 under the RVIZ visualisation marker documentation at the bottom of this document for how to draw triangles, and use them to compose other shapes.**

## Example Program Overview
The code provided with this assignment will display two circles in RVIZ, one static and one moving at a slow rate.
There are two classes used, 
`Sphere` inheriting from `ShapeCommonInterface` to manage the state of the shape we want to display,
and `SingleShapeDisplay` implementing `DisplayOutputInterface` for displaying the shape.

`ShapeCommonInterface` exposes a set of useful common functions for manipulating the location,
dimension, orientation, colour, etc of a shape
that are implemented through a set of corresponding private virtual functions each derived class needs to implement.
There are multiple valid way to do this, the `Sphere` class shows one example technique. 
You might want to think about what infomation you need to ultimately manipulate and display the shape, eg. are there any common functionalities. Remember [inheritance](https://www.w3resource.com/java-tutorial/inheritance-composition-relationship.php) is best used to represent an `is-a` relationship, while composition is best used for `has-a` relationship.

As its name suggests `SingleShapeDisplay` is a `DisplayOutputInterface` that can be used to display a single shape.
A marker message has a set `lifetime`,
new messages need to be published to the marker topic to keep the shape displayed.
Refreshing the message is handled by using a timer to periodically send new message.
The ROS executor called `ros_worker` needs to `spin` periodically to service the timer.

A shape object can be registered with the `SingleShapeDisplay` using the `display_object` function. Actually generating the `marker` message used for display is delegated back the shape object through the `DisplayableInterface`,
through the `get_display_markers` and `get_display_markers_imple` functions. Of course you can create other classes that also implement `DisplayableInterface` that can be used to display a shape or even the whole UAV at once.

**Hint: Each ROS node needs a unique name to differentiate from other nodes.**

## Additional Resources
* [RVIZ visualisation marker documentation](http://wiki.ros.org/rviz/DisplayTypes/Marker)
* [ROS2 installation](https://index.ros.org/doc/ros2/Installation/Dashing/)
* [ROS2 Publisher and Subcriber Tutorial](https://index.ros.org/doc/ros2/Tutorials/Writing-A-Simple-Cpp-Publisher-And-Subscriber/)
