#include <stdio.h>
#include <string.h>
#include <errno.h>

#include <wiringPi.h>
#include <wiringSerial.h>
#include "odrive_raspi.h"

#define timeout 10
int initialized = 0;
int fd;
void digitalIOSetup()
{ 
   // Perform one-time wiringPi initialization
    if (!initialized){
        wiringPiSetupGpio();
        initialized = 1;
    }
   
   
} 
void openCommunication(){
    fd = serialOpen ("/dev/ttyS0", 115200);
}
void odriveSetup(int axis,int vel_limit,int current_limit){
    serialPrintf(fd,"w axis%i.requested_state 3\n",axis);
    delayMicroseconds(15000000);
    serialPrintf(fd,"w axis%i.requested_state 8\n",axis);  
    serialPrintf(fd,"w axis%i.controller.config.vel_limit %i\n",axis, vel_limit);
    serialPrintf(fd,"w axis%i.motor.config.current_lim %i\n",axis,current_limit);
}

void driveCommand(int axis, char type, float setpoint) 
{  
   if (type=='p'){
        serialPrintf(fd,"%c %d %f 0 0\n",type, axis,setpoint);
   }
   else if (type=='v'){
        serialPrintf(fd,"%c %d %f 0\n",type, axis,setpoint);
   }
    else if (type=='c'){
        serialPrintf(fd,"%c %d %f\n",type, axis,setpoint);
   }
     
}


float readPosition(int axis){ 
    serialPrintf(fd,"r axis%i.encoder.pos_estimate\n",axis);
    unsigned int start = millis();
    char message[50];
    int i = 0;
    float output;
    while ( millis()-start<timeout){
        if (serialDataAvail(fd)){
             message[i]=serialGetchar(fd);
             if (message[i]=='\n'){break;}
             i++;
             //start = millis();
            }
        } 
    message[i+1]='\0';
    serialFlush (fd);
    sscanf(message,"%f",&output);
    return output;
    }
float readVoltage(){ 
    //serialFlush (fd);
    serialPrintf(fd,"r vbus_voltage\n");
    unsigned int start = millis();
    char message[50];
    int i = 0;
    float output;
    while ( millis()-start<timeout){
        if (serialDataAvail(fd)){
             message[i]=serialGetchar(fd);
             if (message[i]=='\n'){break;}
             i++;
             //start = millis();
            }
        } 
    message[i+1]='\0';
    sscanf(message,"%f",&output);
    serialFlush (fd);
    return output;
    }

float readCurrent(int axis){ 
    //serialFlush (fd);
    serialPrintf(fd,"r axis%d.motor.current_control.Iq_measured\n",axis);
    unsigned int start = millis();
    char message[50];
    int i = 0;
    float output;
    while ( millis()-start<timeout){
        if (serialDataAvail(fd)){
             message[i]=serialGetchar(fd);
             if (message[i]=='\n'){break;}
             i++;
             //start = millis();
            }
        } 
    message[i+1]='\0';
    sscanf(message,"%f",&output);
    serialFlush (fd);
    return output;
    }
