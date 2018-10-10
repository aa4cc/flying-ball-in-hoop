---
layout: page
title: Building Instructions
subtitle: How to build your own Ball in Hoop laboratory model
---
<!--
# Ball in Hoop

## Introduction -->

# Install procedure
1) go the the home directory and clone the repository by
```
cd /home/pi/
git clone https://github.com/aa4cc/flying-ball-in-hoop.git
```

## Shutdown button service
Copy the service checking whether the shutdown button is pressed to the system directory with other services
```
sudo cp ~/flying-ball-in-hoop/scripts/pi_shutdown.service /lib/systemd/system/
``` 

Enable the service to automatically start when raspberry pi boots
```
sudo systemctl enable pi_shutdown.service
```
Run the service so you don not have to reboot the raspberry pi
```
sudo systemctl start pi_shutdown.service
```
Now you can check the status of the service by running
```
sudo systemctl status pi_shutdown.service
```

## Install OpenCV

This guide vaguely follows a guide written [here](https://www.pyimagesearch.com/2016/04/18/install-guide-raspberry-pi-3-raspbian-jessie-opencv-3/) but this one is altered and valid for Raspbian Stretch.

 1. Log in and change password.
 
 2. Connect to the Internet.

 3. Skip Step #1 in the above-mentioned guide and go to Step #2 - with Raspbian Stretch there is no need to expand the filesystem.

 4. Update packages:

	sudo apt-get update

 5. Upgrade packages:

 	sudo apt-get upgrade

 6. Install CMake:

 	sudo apt-get install build-essential cmake pkg-config

 7. Get image file formats support:

    sudo apt-get install libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev

 8. Get video file formats support:

    sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev

    sudo apt-get install libxvidcore-dev libx264-dev

 9. Install GTK development library:

    sudo apt-get install libgtk2.0-dev

 10. Install other useful dependencies:

     sudo apt-get install libatlas-base-dev gfortran

 11. Install Python:

     sudo apt-get install python2.7-dev python3-dev

 12. Get OpenCV archive:

     cd ~ (or cd /home/pi)

     wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.4.3.zip

     unzip opencv.zip

 13. Install pip:

     sudo apt-get install python3-pip

 14. Install NumPy:

     pip3 install numpy

 15. Setup build via CMake:

     cd ~/opencv-3.4.3/

     mkdir build

     cd build

     cmake -D CMAKE_BUILD_TYPE=RELEASE \
       -D CMAKE_INSTALL_PREFIX=/usr/local \
       -D INSTALL_PYTHON_EXAMPLES=ON \
       -D ENABLE_PRECOMPILED_HEADERS=OFF \
       -D BUILD_EXAMPLES=ON ..

 16. Compile OpenCV:

     make -j4

 17. Install OpenCV:

     sudo make install

     sudo ldconfig
