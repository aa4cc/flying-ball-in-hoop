

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
#include <string.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <time.h>

int soc;
int read_can_port;
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
extern unsigned char read_frame(int soc, struct can_frame * frame_rd)
{
    int recvbytes = 0;
    // set timeout to 1 ms
    struct timeval timeout = {0, 1000};
    fd_set readSet;
    FD_ZERO(&readSet);
    FD_SET(soc, &readSet);
    if (select((soc + 1), &readSet, NULL, NULL, &timeout) >= 0)
    {
        if (FD_ISSET(soc, &readSet))
        {
            recvbytes = read(soc, frame_rd, sizeof(struct can_frame));
            if(recvbytes)
            {
                return recvbytes; 
            }
        }
    }
}
# endif
/* %%%-SFUNWIZ_wrapper_externs_Changes_END --- EDIT HERE TO _BEGIN */

/*
 * Output functions
 *
 */
void sfcn_can_Outputs_wrapper(const real32_T *in,
			real32_T *pos,
			real32_T *vel,
			real32_T *iq,
			const real_T *xD)
{
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_BEGIN --- EDIT HERE TO _END */
if (xD[0]==1) {
    
    /* don't do anything for mex file generation */
    # ifndef MATLAB_MEX_FILE
    // Update Output:

    struct can_frame tx_frame;
    tx_frame.can_id = 0x21;
	memcpy((char *) tx_frame.data, &in[0], 4);
	tx_frame.can_dlc = 4;
    
    int retval = write(soc, &tx_frame, sizeof(struct can_frame));
    if (retval != sizeof(struct can_frame))
    {
        fprintf (stderr, "Unable to send a CAN frame\r\n");
    }
    
    // Read the velocity and position
	vel[0] = 0;
    pos[0] = 0;
    iq[0] = 0;
    
    struct can_frame frame_rd;
    clock_t t1 = clock();   
    unsigned char f_maxTimeExceeded = 0;
    unsigned char f_posAndVelRead = 0;
    unsigned char f_iqRead = 0;
    // Check whether the the correct number of bytes was received and whether
    // the CAN ID corresponds to the messge containing velocity and position
    // measurement. If this check fails try to read another frame.
    
    float duration = 0;
    while (true) {
        // Read a CAN frame
        int recvbytes = read_frame(soc, &frame_rd);
    
        while(recvbytes != sizeof(struct can_frame)) {
            // Check the time elapsed since the first try. If the time is longer
            // than 10 milliseconds, go to an error state. !TODO!
            clock_t t2 = clock();
            duration = 1000*((float)(t2 - t1) / CLOCKS_PER_SEC); // duration in ms
            if(duration > 10) {
                fprintf (stderr, "No CAN frame was received\r\n");
                f_maxTimeExceeded = 1;
                break;
            }

            // Read another CAN frame
            int recvbytes = read_frame(soc, &frame_rd);
        }
    
        // If maximum time is not exceeded, extract data from the read CAN frame
        if(!f_maxTimeExceeded) {
            if (frame_rd.can_id == 0x70) {
                vel[0] = *((float*)frame_rd.data);
                pos[0] = *((float*)frame_rd.data + 1);
                f_posAndVelRead = 1;
            } else if(frame_rd.can_id == 0x71) {
                iq[0] = *((float*)frame_rd.data);  
                f_iqRead = 1;   
            }
        } else {
            // Max time exceeded, break the while loop
            break;
        }
        
        // If position, velocity and iq current were read, break the while loop
        if (f_posAndVelRead == 1 && f_iqRead == 1) {
            break;
        }
        
    }
    
    # endif    
}
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_END --- EDIT HERE TO _BEGIN */
}

/*
  * Updates function
  *
  */
void sfcn_can_Update_wrapper(const real32_T *in,
			real32_T *pos,
			real32_T *vel,
			real32_T *iq,
			real_T *xD)
{
  /* %%%-SFUNWIZ_wrapper_Update_Changes_BEGIN --- EDIT HERE TO _END */
if (xD[0]!=1){
    
    #ifndef MATLAB_MEX_FILE
    struct ifreq ifr;
    struct sockaddr_can addr;
    /* open socket */
    soc = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if(soc < 0)
    {
        fprintf (stderr, "Unable to open CAN socket\r\n");
        return;
    }
    addr.can_family = AF_CAN;
    strcpy(ifr.ifr_name, "can0");
    if (ioctl(soc, SIOCGIFINDEX, &ifr) < 0)
    {
        fprintf (stderr, "Unable to open CAN socket\r\n");
        return;
    }

    addr.can_ifindex = ifr.ifr_ifindex;
    fcntl(soc, F_SETFL, O_NONBLOCK);
    if (bind(soc, (struct sockaddr *)&addr, sizeof(addr)) < 0)
    {
        fprintf (stderr, "Unable to open CAN socket\r\n");
        return;
    }
    
    #endif
    
    xD[0] = 1;

}
/* %%%-SFUNWIZ_wrapper_Update_Changes_END --- EDIT HERE TO _BEGIN */
}
