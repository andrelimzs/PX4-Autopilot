cd ~/Github/PX4-Autopilot
DONT_RUN=1 make px4_sitl_default gazebo_iris_2d_lidar
source ~/catkin_ws/devel/setup.bash    # (optional)
source Tools/setup_gazebo.bash $(pwd) $(pwd)/build/px4_sitl_default
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd)
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd)/Tools/sitl_gazebo
roslaunch px4 mavros_posix_sitl.launch vehicle:=iris_2d_lidar fcu_url:="udp://:14540@127.0.0.1:14557"
