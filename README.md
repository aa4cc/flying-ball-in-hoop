## Raspi install
# OpenCV3
Follow the instruction in http://www.pyimagesearch.com/2016/04/18/install-guide-raspberry-pi-3-raspbian-jessie-opencv-3/

pip install picamera
pip install click
pip install imutils

sudo apt-get install git
git clone git@gitlab.fel.cvut.cz:gurtnmar/flying-ball.git


pip install virtualenv
virtualenv -p /usr/bin/python3 cv
source cv/bin/activate