# UNSW MTRN2500 2019 T3 Assignment 3

The assignment specification is available in `assignment3_spec.md`


## Setup instructions:   
### Clone your repo
1. Open a new terminal or another terminal tab  
    `ctrl + alt + t` or `ctrl + shift + T`  
1. Navigate to your ROS workspace `mtrn2500_ws`
1. Clone your assignment 3 repository in the same way as assignment 2
1. You may remove your assignment 2 code if you like, however it will be useful to compare to and is ok to leave as is   

### Compile and run assignment3:  
1. Open a new terminal or another terminal tab  
    `ctrl + alt + t` or `ctrl + shift + T`  
1. Navigate to your git repository folder
1. Complile:  
    `. mtrn2500_make`  
1. Run the assignment3 program   
    `ros2 run assignment3 assignment3`

### Launching the Joystick Input node
1. Open a new terminal or another terminal tab  
    `ctrl + alt + t` or `ctrl + shift + T`  
1. Complile:  
    `. mtrn2500_make` 
1. Launch the node in the same way as assignment 2
    `ros2 launch assignment3 joy_node.py`

### Running the visualisation environment rviz2:  
1. Open a new terminal or another terminal tab  
    `ctrl + alt + t` or `ctrl + shift + T`  
1. Complile:  
    `. mtrn2500_make`  
1. Start rviz2:
    `ros2 run rviz2 rviz2`
1. Config rviz2 by clicking on `file` in rviz2 and select open config.
    * `rviz_example_config.rviz` in the launch folder set the global frame to `z0000000/world_frame`, this will show the markers from the example program when it runs.

## FAQ

### Q: Why do I need to create the review branch now?
A: The purpose of the review branch is for you to be able to create a pull request with all the commit you have made. By getting you to make the review branch at the start of the project, all the commit you make to the master branch from now on will show up when you make the pull request. This way the tutor will be able to access all of your work.

### Q: Will my work be assessed on the master or review branch?
A: Your last commit to the master branch before the assignment due date will be counted as your submission. You should not be pulling any code into the review branch. You just need to make a pull request from the master branch to the review branch, it will automatically be kept up to date as you add commit to the master branch.

### Q: Is the following the style guide mandatory?
A: Yes, it is important to keep a code base nicely formatted, this make the code easier to understand for other people that are also working on the same project. For lots of the stylistic choices, there are often no clear best option, the key is to pick one style and follow it consistently. The style guide is the documentation of the choices selected for the project. When you are working with an existing code base, you should follow their existing style.

### Q: vscode flashes on the VM, and it's getting really annoying...
A: When starting vscode using the code command, instead start it with `code --disable-gpu`. Alternatively, run:

`echo "alias code=\"code --disable-gpu\"" >> ~/.bash_aliases`

then close all terminals, start vscode using the `code` command as normal and the flashing should not be present anymore.
 
### Q: How do I create a shared folder so I can transfer files between my VM and host machine?
A: Create a shared folder (sf) in the VirtualBox (vbox) settings by adding a folder, selecting the folder within the directory you want and selecting auto mount. This will mount the folder in `/media/sf_FOLDER_NAME`. By default the user is root and the group is vboxsf. Students need to add their user to that group. You can add your username by running `sudo adduser $USER vboxsf` in a terminal and rebooting to take effect. They will now be able to open the folder (will show up on the desktop) without entering a password.

Windows users have shared privileges off by default so they will have to open the shared folder in file explorer:
	
* Right click Preferences > Sharing > Advanced settings
* Select share.

To set up your code for compiling with ROS you will need to commit and push all changes in your repo, move the repo into the shared folder and then link the shared folder into the ROS workspace. This can be done by running:
**NB: <tab> means hit the tab key for tab completion   
`mv ~/mtrn2500_ws/assignment3<tab> /media/sf<tab>`   
`ln -s /media/sf<tab>/assignment3<tab> ~/mtrn2500_ws/`   
`. mtrn2500_make`   

You will now be able to edit files either natively or in the VM and once they refresh whatever they have it open in the changes from the other will appear.

### Q: I'm having problems saving files I edit when I used the `gedit` text editor, how can I work around this problem?
A: See this link: https://askubuntu.com/questions/537799/save-in-gedit-without-in-virtualbox#538095


### Q: List of recommanded plugin for vscode:

* [C/C++ tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools) : Add C++ language support to visual studio code.
* [Cmake tools](https://marketplace.visualstudio.com/items?itemName=vector-of-bool.cmake-tools) : Provides configuration info to power the code completion feature of C/C++ tools.
* [ROS](https://marketplace.visualstudio.com/items?itemName=ms-iot.vscode-ros) : Provide some ros specific tools.
* [Gitlens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) : Additional git features to complement features built into vscode.

If you encountered any problems and figured out a fix to it, let us know and we can add it to the FAQ.
