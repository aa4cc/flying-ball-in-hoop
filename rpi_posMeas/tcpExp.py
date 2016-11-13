import io
import time
import threading
import picamera
import numpy as np
import cv2
import socket, struct
import click
import re
import sys

from imutils.video import FPS

# Global variables
params = {}

fps = []
# Create a pool of image processors
done = False
num_frames = 0
lock = threading.Lock()
pool = []

sock = []

class ImageProcessor(threading.Thread):
    def __init__(self, id):
        super(ImageProcessor, self).__init__()
        self.id = id
        self.stream = io.BytesIO()
        self.event = threading.Event()
        self.terminated = False
        self.start()

    def run(self):
        # This method runs in a separate thread
        global done, num_frames, fps, sock
        while not self.terminated:
            if self.event.wait(1):
                try:
                    self.stream.seek(0)

                    if params["verbose"] > 0:
                        e1 = cv2.getTickCount()

                    data_raw = self.stream.getvalue()
                    data = np.fromstring(data_raw, dtype=np.uint8)
                    image = np.resize(data,(480,480,3))

                    # image_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
                    # cv2.circle(image_gray, (50, 50), 10, 255, -1)
                    # cv2.putText(image_gray, str(num_frames), (240, 240), cv2.FONT_HERSHEY_SIMPLEX, 2, 255)

                    if params['ip'] is not None:
                        # sock.sendall(image_gray.tostring())
                        sock.sendall(image.tostring())

                    if params['verbose']:
                        e2 = cv2.getTickCount()
                        elapsed_time = (e2 - e1)/ cv2.getTickFrequency()
                        print('Threads in pool: {}, elapsed time: {}'.format(len(pool), elapsed_time))

                except ValueError as ve:
                    print(ve)

                # except:
                    # print("Ooops! Something wrong happend in an image processing thread...")
                    # print(sys.exc_info()[0])

                finally:
                    # Set done to True if you want the script to terminate
                    # at some point
                    num_frames += 1
                    if num_frames >= params["num_frames"]:
                        done=True

                    fps.update()

                    # Reset the stream and event
                    self.stream.seek(0)
                    self.stream.truncate()
                    self.event.clear()
                    # Return ourselves to the pool
                    with lock:
                        pool.append(self)


def streams():
    # intialize dummy stream, steam which is used for images that are not supposed to be processed
    dummy_stream = io.BytesIO()

    while not done:
        with lock:
            # if the pool of image processing thread is not empty, take out one of the threads
            if len(pool) > 0:
                processor = pool.pop()
            else:               
                processor = None

        # if there was an image processing thread in the pool, give it the stream with the image. Otherwise, give the stream with the image to a dummy stream
        if processor is not None:
            yield processor.stream
            processor.event.set()
        else:
            yield dummy_stream
            # Move the cursor in the dummy stream to the begining and get rid of the data in the stream by the truncation
            dummy_stream.seek(0)
            dummy_stream.truncate()

@click.command()
@click.option('--num_frames', '-n', default=1, help='Total number of frames to process')
@click.option('--frame_rate', '-f', default=10, help='Number of frames per second to process')
@click.option('--exposition_time', '-e', default=10, help='Exposition time (shutter speed) in milliseconds.')
@click.option('--verbose', '-v', is_flag=True, default=False, help='Display time needed for processing of each frame and the measured position.')
@click.option('--debug', '-d', is_flag=True, default=False, help='Save masks and ROIs together with the identified position of the ball.')
@click.option('--tracking', '-t', is_flag=True, default=False, help='Enable tracking of the object only in a neighborhood of the last measured position.')
@click.option('--ip_port', '-i', type=(str, int), default=(None, 0), help='Specify the ip address and port of the host the measured position will be sending to.')
def main(num_frames, frame_rate, exposition_time, verbose, debug, tracking, ip_port):
    global params, pool, fps, sock

    params['ip'] = ip_port[0]
    params['port'] = ip_port[1]
    params['num_frames'] = num_frames
    params['framerate'] = frame_rate
    params['exposition_time'] = exposition_time
    params['verbose'] = verbose
    params['debug'] = debug
    params['tracking'] = tracking

    click.echo('Number of frames: %d' % params['num_frames'])
    click.echo('FPS: %d' % params['framerate'])

    if params['ip'] is not None:
        aa = re.match(r"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$", params['ip'])
        if aa is not None:
            params['ip'] = aa.group()
            click.echo('IP: %s, port: %d' % (params['ip'], params['port']))

            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect((params['ip'], params['port']))            
        else:
            params['ip'] = None

    if params['verbose']:
        click.echo('Verbose')
    if params['tracking']:
        click.echo('Tracking')

    with picamera.PiCamera() as camera:
        pool = [ImageProcessor(i) for i in range (4)]
        camera.resolution = (480, 480)
        # Set the framerate appropriately; too fast and the image processors
        # will stall the image pipeline and crash the script
        camera.framerate = params['framerate']        
        camera.shutter_speed = params['exposition_time']*1000
        camera.iso = 600
        camera.exposure_mode = 'off'

        camera.start_preview()

        # Let the camera warm up
        time.sleep(2)

        fps = FPS().start()
        
        camera.capture_sequence(streams(), use_video_port=True, format="rgb")

        fps.stop()
        print("[INFO] elasped time: {:.2f}".format(fps.elapsed()))
        print("[INFO] approx. FPS: {:.2f}".format(fps.fps()))


    # Shut down the processors in an orderly fashion
    while pool:
        with lock:
            processor = pool.pop()
        processor.terminated = True
        processor.join()

    if params['ip'] is not None:
        sock.close()

if __name__=='__main__':
    main()
