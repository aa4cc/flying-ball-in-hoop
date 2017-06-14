#!/usr/bin/python3

import io
import time
import picamera
import numpy as np
import cv2
import socket, struct
import click
import re
import sys
import hooppos

from imutils.video import FPS

# TODO


# Global variables
params = {}

fps = None
# Create a pool of image processors
done = False
num_frames = 0
    
tr_window_halfsize = 48
center = (240,240)
img_size = (480,480)

accepted_stream_modes = {'t', 'g', 'd', None}

udp_sock = []

camera = None


# Ball mass - ball is approximately 40 px in diameter in the image hence the mass should be somewhere around pi*20^2=1256. The values are multiplied by 255 because the the pixels in the binary image have values 0 and 255 (weird, isn't it?).
# min_ball_mass = 0.25*1000*255
# max_ball_mass = 8*1800*255

min_ball_mass = 5
max_ball_mass = 8*1800*255

def findTheBall(image, denoise = True, kernel = None, iterations = 2):
    im_red = cv2.subtract(image[:,:,0], image[:,:,1], None)
    im_red = cv2.subtract(im_red, image[:,:,2], None)

    im_thrs = cv2.inRange(im_red, 70,250)
    if denoise:
        # im_denoised = cv2.dilate(im_thrs, kernel, iterations)
        # im_denoised = cv2.erode(im_denoised, kernel, iterations)
        im_denoised = cv2.morphologyEx(im_thrs, cv2.MORPH_OPEN, None)      
    else:
        im_denoised = im_thrs

    # cv2.morphologyEx(img, cv2.MORPH_CLOSE, kernel)
    # ((x, y), radius) = cv2.minEnclosingCircle(c)

    M = cv2.moments(im_denoised)
    if M['m00'] > min_ball_mass and M['m00'] < max_ball_mass:
        center = ( (int(M['m10'] / M['m00']), int(M['m01'] / M['m00'])) ) 
    else:
        center = None

    return center, im_thrs, im_denoised

def processImage(image):
    global done, num_frames, fps, center, udp_sock

    try:
        # Downsample the image
        # e1 = cv2.getTickCount()
        img_dwnsample = image[1::params['downsample'], 1::params['downsample'], :]
        
        # center, im_thrs, im_denoised = findTheBall(img_dwnsample, iterations = 1, kernel = np.ones((2,2),np.uint8))
        center, im_thrs, im_denoised = findTheBall(img_dwnsample, denoise = False)
        if center is not None:
            center = (params['downsample']*center[0], params['downsample']*center[1])

        if center is None and not params["debug"]:
            cv2.imwrite("/home/pi/flying-ball/rpi_posMeas/img/im_dwn_denoised%d.png" % num_frames, im_denoised)
            cv2.imwrite("/home/pi/flying-ball/rpi_posMeas/img/im_dwn%d.png" % num_frames, img_dwnsample)       

        # Save the the region of interest image if the debug option is chosen
        if params['debug']:
            # if center is not None:
                # cv2.circle(img_dwnsample, center, 5, (0, 0, 255), -1)
            cv2.imwrite("/home/pi/flying-ball/rpi_posMeas/img/im_dwn_denoised%d.png" % num_frames, im_denoised)
            cv2.imwrite("/home/pi/flying-ball/rpi_posMeas/img/im_dwn%d.png" % num_frames, img_dwnsample)         

        # e2 = cv2.getTickCount()
        # elapsed_time = (e2 - e1)/ cv2.getTickFrequency()
        # print(elapsed_time)

        # print(center)

        if center is None:
            print('The ball was not found in the whole image!')
            center_inROI = None
        else:
            # Find the ball in smaller image
            ROI_xtop = max((center[1]-tr_window_halfsize), 0)
            ROI_xbottom = min((center[1]+tr_window_halfsize), img_size[1])
            ROI_yleft = max((center[0]-tr_window_halfsize), 0)
            ROI_yright = min((center[0]+tr_window_halfsize), img_size[0])
            imageROI = image[ ROI_xtop:ROI_xbottom,  ROI_yleft:ROI_yright, :]

            # Find the ball in the region of interest
            center_inROI, im_thrs, im_denoised = findTheBall(imageROI)

            # If the ball is not found, raise an exception
            if center_inROI is None:
                print('The ball was not found in the ROI!')
            else:
                # transform the measured position from ROI to full image coordinates
                center = (ROI_yleft + center_inROI[0], ROI_xtop + center_inROI[1])

        # Save the the region of interest image if the debug option is chosen
        if params['debug']:
            # cv2.imwrite("/home/pi/flying-ball/rpi_posMeas/img/im_thrs%d.png" % num_frames, im_thrs)

            if center_inROI is not None:
                cv2.circle(imageROI, center_inROI, 5, (0, 0, 255), -1)
                cv2.imwrite("/home/pi/flying-ball/rpi_posMeas/img/im_roi%d.png" % num_frames, imageROI)         

        # Write the measured position to the shred memory
        if center is not None:
            hooppos.measpos_write(center[0], center[1])
        else:
            hooppos.measpos_write(img_size[0]+1, img_size[1]+1)

        # If the ip ip option is chosen, send the identified position via a UDP packet
        if params['ip'] is not None:
            # If the ball was found, send the identified position, if not, send the size of the image +1 as the identified position
            if center is not None:
                udp_sock.sendto(struct.pack('II', center[0], center[1]), (params['ip'], params['port']))

                if (params['stream'] is not None):
                    if params['stream'] == 't':                                
                        # Send thresholded red channel

                        # If the ball is found, mark it in the ROI image
                        if center is not None:
                            cv2.circle(im_thrs, center_inROI, 5, 255, -1)

                        # Send the position
                        udp_sock.sendto(im_thrs.tostring(), (params['ip'], params['port']+1))

                    elif params['stream'] == 'g':     
                        # Send grayscale image
                        imageROI_gray = cv2.cvtColor(imageROI, cv2.COLOR_BGR2GRAY)

                        # If the ball is found, mark it in the ROI image
                        if center is not None:
                            cv2.circle(imageROI_gray, center_inROI, 5, 255, -1)

                        # Send the position
                        udp_sock.sendto(imageROI_gray.tostring(), (params['ip'], params['port']+1))
                    elif params['stream'] == 'd':
                        # Send denoised image (image after dilation and erosion)

                        # If the ball is found, mark it in the ROI image
                        if center is not None:
                            cv2.circle(im_denoised, center_inROI, 5, 128, -1)

                        # Send the position                                
                        udp_sock.sendto(im_denoised.tostring(), (params['ip'], params['port']+1))                
            else:
                udp_sock.sendto(struct.pack('II', img_size[0]+1, img_size[1]+1), (params['ip'], params['port']))

                if (params['stream'] is not None):
                    # Send an empty image
                    udp_sock.sendto(np.empty((2*tr_window_halfsize, 2*tr_window_halfsize), dtype=np.uint8), (params['ip'], params['port']+1))

    finally:
        # Set done to True if you want the script to terminate
        # at some point
        num_frames += 1
        if num_frames >= params["num_frames"]:
            done=True

        fps.update()

class ImageProcessor(io.BytesIO):
    def __init__(self):
        super().__init__()

    def write(self, b):
        global center

        if params["verbose"] > 0:
            e1 = cv2.getTickCount()

        data = np.fromstring(b, dtype=np.uint8)
        image = np.resize(data,(img_size[1], img_size[0], 3))

        processImage(image)
        
        if params['verbose']:
            e2 = cv2.getTickCount()
            elapsed_time = (e2 - e1)/ cv2.getTickFrequency()
            if center is not None:
                center_to_print = center
            else:
                center_to_print = ('-', '-')

            print('Center ({},{}), elapsed time: {}'.format(center_to_print[0], center_to_print[1], elapsed_time))        


def streams():
    processor = ImageProcessor()

    while not done:
        #e1 = cv2.getTickCount()

        yield processor
        #e2 = cv2.getTickCount()
        #elapsed_time = (e2 - e1)/ cv2.getTickFrequency()
        #print('Freq : {}'.format(round(1/elapsed_time)))

@click.command()
@click.option('--num_frames', '-n', default=1, help='Total number of frames to process')
@click.option('--frame_rate', '-f', default=10, help='Number of frames per second to process')
@click.option('--exposition_time', '-e', default=10, help='Exposition time (shutter speed) in milliseconds.')
@click.option('--verbose', '-v', is_flag=True, default=False, help='Display time needed for processing of each frame and the measured position.')
@click.option('--stream', '-s', default=None, type=str, help='Stream the images with the measured position. In the defualt settings, no image is streamed. \n\t t - the thresholded image I = R-G-B \n\t g - the grayscale image \n\t d - the denoised image')
@click.option('--debug', '-d', is_flag=True, default=False, help='Save masks and ROIs together with the identified position of the ball.')
@click.option('--ip_port', '-i', type=(str, int), default=(None, 0), help='Specify the ip address and port of the host the measured position will be sending to.')
@click.option('--downsample', '-dw', type=int, default=6, help='Specify the down-sample ration for the initial ball localization routine.')
def main(num_frames, frame_rate, exposition_time, verbose, stream, debug, ip_port, downsample):
    global params, pool, fps, udp_sock, center

    try:
        params['ip'] = ip_port[0]
        params['port'] = ip_port[1]
        params['num_frames'] = num_frames
        params['framerate'] = frame_rate
        params['exposition_time'] = exposition_time
        params['verbose'] = verbose
        params['downsample'] = downsample        

        # Check whether the value of the streaming option
        if stream in accepted_stream_modes:
            params['stream'] = stream
        else:
            print('Invalid option for streaming settings. Images will not be streamed.')
            params['stream'] = None

        params['debug'] = debug    

        click.echo('Number of frames: %d' % params['num_frames'])
        click.echo('FPS: %d' % params['framerate'])

        if params['ip'] is not None:
            aa = re.match(r"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$", params['ip'])
            if aa is not None:
                params['ip'] = aa.group()
                click.echo('IP: %s, port: %d' % (params['ip'], params['port']))
                udp_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
            else:
                params['ip'] = None

        if params['verbose']:
            click.echo('Verbose')
        if params['debug']:
            click.echo('Debug')

        with picamera.PiCamera() as camera:
            camera.resolution = img_size
            # Set the framerate appropriately; too fast and the image processors
            # will stall the image pipeline and crash the script
            camera.framerate = params['framerate']        
            camera.shutter_speed = params['exposition_time']*1000
            camera.iso = 200

            # Let the camera warm up
            time.sleep(2)

            print("Exposition time: {}".format(camera.exposure_speed/1000))
            print("camera.awb_gains: {}".format(camera.awb_gains))
            print("camera.iso: {}".format(camera.iso))

            # Now fix the values
            camera.exposure_mode = 'off'
            g = camera.awb_gains
            camera.awb_mode = 'off'
            camera.awb_gains = g

            ## Find the initial positon
            image = np.empty((img_size[1], img_size[0], 3), dtype=np.uint8)
            camera.capture(image, 'rgb')

            center, im_thrs, im_denoised = findTheBall(image)
            if center is not None:
                hooppos.predpos_write(center[0], center[1])
            else:
                hooppos.predpos_write(img_size[0]+1, img_size[1]+1)
                        
            if params['debug']:
                cv2.imwrite("/home/pi/flying-ball/rpi_posMeas/img/im_thrs_init.png", im_thrs)

                if center is not None:
                    cv2.circle(image, center, 5, (0, 0, 255), -1)
                cv2.imwrite("/home/pi/flying-ball/rpi_posMeas/img/im_roi_init.png", image)


            fps = FPS().start()
            
            camera.capture_sequence(streams(), use_video_port=True, format="rgb")

            fps.stop()
            print("[INFO] elasped time: {:.2f}".format(fps.elapsed()))
            print("[INFO] approx. FPS: {:.2f}".format(fps.fps()))

    except (KeyboardInterrupt, SystemExit):
        print('Yes, hold on; I am trying to kill myself!')

    finally:
        # Shut down the processors in an orderly fashion
        if camera is not None:
            camera.close()

if __name__=='__main__':
    main()
