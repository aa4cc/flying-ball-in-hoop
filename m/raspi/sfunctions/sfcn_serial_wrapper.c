

/*
 * Include Files
 *
 */
#if defined(MATLAB_MEX_FILE)
#include "tmwtypes.h"
#include "simstruc_types.h"
#else
#include "rtwtypes.h"
#endif

/* %%%-SFUNWIZ_wrapper_includes_Changes_BEGIN --- EDIT HERE TO _END */
# ifndef MATLAB_MEX_FILE
#include <stdio.h>
#include <stdint.h>
#include <wiringPi.h>
#include <wiringSerial.h>
#include <time.h>

#define TORQREF_CMDID 0x21
#define VELPOSMEAS_CMDID 0x70
#define IQMEAS_CMDID 0x71

uint8_t frame[8];
int fd;

# endif
/* %%%-SFUNWIZ_wrapper_includes_Changes_END --- EDIT HERE TO _BEGIN */
#define u_width 1
#define y_width 1
/*
 * Create external references here.  
 *
 */
/* %%%-SFUNWIZ_wrapper_externs_Changes_BEGIN --- EDIT HERE TO _END */
/* extern double func(double a); */
# ifndef MATLAB_MEX_FILE

union float2bytes
{
    float f;
    char b[sizeof(float)];
};

void float2bytes(float f, unsigned char* bytes) {
    union float2bytes f2b;
    f2b.f = f;
    bytes[0] = f2b.b[0];
    bytes[1] = f2b.b[1];
    bytes[2] = f2b.b[2];
    bytes[3] = f2b.b[3];
}

float bytes2float(uint8_t * bytes) {
    union float2bytes f2b;
    f2b.b[0] = bytes[0];
    f2b.b[1] = bytes[1];
    f2b.b[2] = bytes[2];
    f2b.b[3] = bytes[3];
    return f2b.f;
}

void buildFrame(float torq_ref, uint8_t * frame) {
    uint8_t ref_bytes[4];
    float2bytes(torq_ref, ref_bytes);

    frame[0] = 0xFF;
    frame[1] = 8;
    frame[2] = TORQREF_CMDID;
    frame[3] = ref_bytes[0];
    frame[4] = ref_bytes[1];
    frame[5] = ref_bytes[2];
    frame[6] = ref_bytes[3];
    frame[7] = 0;
}

void readFrame(int fd, uint8_t * id, uint8_t * length, uint8_t * frame) {
  uint8_t c;
  while((c = serialGetchar(fd)) != 0xFF) {}

  *length = serialGetchar(fd) - 4; // 3 bytes are for the header, lenght and id and one byte is for the checksum
  *id = serialGetchar(fd);

  uint8_t i;
  for(i = 0; i < *length && i < 8; i++) {
    frame[i] = serialGetchar(fd);
  }

  // Read the checksum byte
  uint8_t chsum = serialGetchar(fd);
}

void openSerial() {
  fd = serialOpen("/dev/ttyUSB0", 115200);
    // Check if serial port can be opened   
    if(fd < 0)
    {
        printf("Unable to open serial device: %s\r");
        return;
    }

    // Flush all the data already present in the buffer (Not sure whether there actually can be some data...)
    serialFlush(fd);
}

void setTorque(float torq_ref, float * pos, float * vel, float * iq) {

    // Build the frame for sending the reference torque
    buildFrame(torq_ref, frame);

    // Send the frame
    uint8_t i;
    for (i = 0; i < 8; ++i)
    {
      serialPutchar(fd, frame[i]);
    }

    // Read position and velocity
    uint8_t id, length;
    readFrame(fd, &id, &length, frame);
    if(id != VELPOSMEAS_CMDID || length != 8) {
        printf("Position and velocity were not received from the BLDC controller!\r");
    }

    *vel = bytes2float(frame);
    *pos = bytes2float((frame + 4));

    // Read iq current
    readFrame(fd, &id, &length, frame);
    if(id != IQMEAS_CMDID || length != 4) {
        printf("Iq current was not received from the BLDC controller!\r");
        return;
    }

    *iq = bytes2float(frame);
}
# endif
/* %%%-SFUNWIZ_wrapper_externs_Changes_END --- EDIT HERE TO _BEGIN */

/*
 * Output functions
 *
 */
void sfcn_serial_Outputs_wrapper(const real32_T *in,
			real32_T *pos,
			real32_T *vel,
			real32_T *iq,
			const real_T *xD,
			const real_T  *Ts, const int_T  p_width0)
{
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_BEGIN --- EDIT HERE TO _END */
if (xD[0]==1) {
    
    /* don't do anything for mex file generation */
    # ifndef MATLAB_MEX_FILE
    // Update Output:
    
    // digitalWrite (29, HIGH) ;
        
    setTorque(in[0], &pos[0], &vel[0], &iq[0]);
    
    // digitalWrite (29,  LOW) ;
    
    // Subtract offset in position
    pos[0] -= xD[1];
    
    # endif    
}
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_END --- EDIT HERE TO _BEGIN */
}

/*
  * Updates function
  *
  */
void sfcn_serial_Update_wrapper(const real32_T *in,
			real32_T *pos,
			real32_T *vel,
			real32_T *iq,
			real_T *xD,
			const real_T  *Ts,  const int_T  p_width0)
{
  /* %%%-SFUNWIZ_wrapper_Update_Changes_BEGIN --- EDIT HERE TO _END */
if (xD[0]!=1){
    
    #ifndef MATLAB_MEX_FILE
    wiringPiSetup () ;
    pinMode(29, OUTPUT) ;
    
    openSerial();
   
    float pos, vel, iq;
    
    // digitalWrite (29, HIGH);
    
    setTorque(0, &pos, &vel, &iq);
    
    // digitalWrite (29, LOW) ;
        
    xD[1] = pos;
 
    
    #endif
    
    xD[0] = 1;

}
/* %%%-SFUNWIZ_wrapper_Update_Changes_END --- EDIT HERE TO _BEGIN */
}
