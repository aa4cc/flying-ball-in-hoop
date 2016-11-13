

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
#include <errno.h>
#include <wiringPi.h>
#include <wiringSerial.h>

int fd;
# endif
/* %%%-SFUNWIZ_wrapper_includes_Changes_END --- EDIT HERE TO _BEGIN */
#define u_width 1
/*
 * Create external references here.  
 *
 */
/* %%%-SFUNWIZ_wrapper_externs_Changes_BEGIN --- EDIT HERE TO _END */
/* extern double func(double a); */
/* %%%-SFUNWIZ_wrapper_externs_Changes_END --- EDIT HERE TO _BEGIN */

/*
 * Output functions
 *
 */
void sfcn_serial_Outputs_wrapper(const real32_T *in,
			const real_T *xD)
{
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_BEGIN --- EDIT HERE TO _END */
/* wait until after initialization is done */
if (xD[0]==1) {
    
    /* don't do anything for mex file generation */
    # ifndef MATLAB_MEX_FILE
    // Update Output:
    serialPrintf(fd, "run %.5f\r", in[0]) ;
    # endif
    
}
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_END --- EDIT HERE TO _BEGIN */
}

/*
  * Updates function
  *
  */
void sfcn_serial_Update_wrapper(const real32_T *in,
			real_T *xD)
{
  /* %%%-SFUNWIZ_wrapper_Update_Changes_BEGIN --- EDIT HERE TO _END */
if (xD[0]!=1){
    
    #ifndef MATLAB_MEX_FILE
    fd = serialOpen("/dev/serial0", 115200);
    // Check if serial port can be opened   
    if(fd < 0)
    {
        printf (stderr, "Unable to open serial device: %s\r", strerror(errno));
        return 1;
    }
    serialPrintf(fd, "\r\r");
    serialPrintf(fd, "guest\r");
    serialPrintf(fd, "guest\r");
    serialPrintf(fd, "\r\r");
    #endif
    
    xD[0] = 1;

}
/* %%%-SFUNWIZ_wrapper_Update_Changes_END --- EDIT HERE TO _BEGIN */
}
