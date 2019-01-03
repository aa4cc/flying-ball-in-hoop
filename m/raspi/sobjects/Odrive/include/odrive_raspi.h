#ifndef _ODRIVE_RASPI_H_
#define _ODRIVE_RASPI_H_
#include "rtwtypes.h"

void digitalIOSetup();
void odriveSetup(int axis,int vel_limit,int current_limit);
void openCommunication();
void driveCommand(int axis,char type, float setpoint);
float readPosition(int axis);
float readCurrent(int axis);
float readVoltage();
#endif //_DIGITALIO_RASPI_H_