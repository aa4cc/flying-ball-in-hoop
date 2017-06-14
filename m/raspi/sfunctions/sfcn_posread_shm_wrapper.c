

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
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdint.h>

struct Position {
   uint16_t  x;
   uint16_t  y;
};
typedef struct Position position;

position* meas_pos;
char *shm;
# endif
/* %%%-SFUNWIZ_wrapper_includes_Changes_END --- EDIT HERE TO _BEGIN */
#define y_width 1
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
void sfcn_posread_shm_Outputs_wrapper(int32_T *pos_x,
			int32_T *pos_y,
			const real_T *xD,
			const real_T  *Ts, const int_T  p_width0)
{
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_BEGIN --- EDIT HERE TO _END */
#ifndef MATLAB_MEX_FILE
if (shm==0) {    
    int shmid;
    key_t key;
    key = 3145914;

    /*
     * Locate the segment.
     */
    if ((shmid = shmget(key, 2*sizeof(*meas_pos), 0666)) < 0) {
        perror("shmget");
        return(1);
    }

    /*
     * Now we attach the segment to our data space.
     */
    if ((shm = shmat(shmid, NULL, 0)) == (char *) -1) {
        perror("shmat");
        return(1);
    }
}
    
// Update Output:
meas_pos = (position*)shm;

pos_x[0] = meas_pos->x;
pos_y[0] = meas_pos->y;
# endif
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_END --- EDIT HERE TO _BEGIN */
}

/*
  * Updates function
  *
  */
void sfcn_posread_shm_Update_wrapper(int32_T *pos_x,
			int32_T *pos_y,
			real_T *xD,
			const real_T  *Ts,  const int_T  p_width0)
{
  /* %%%-SFUNWIZ_wrapper_Update_Changes_BEGIN --- EDIT HERE TO _END */
// if (xD[0]!=1){
//     
//     #ifndef MATLAB_MEX_FILE
//     int shmid;
//     key_t key;
//     key = 3145914;
// 
//     /*
//      * Locate the segment.
//      */
//     if ((shmid = shmget(key, 2*sizeof(*meas_pos), 0666)) < 0) {
//         perror("shmget");
//         return(1);
//     }
// 
//     /*
//      * Now we attach the segment to our data space.
//      */
//     if ((shm = shmat(shmid, NULL, 0)) == (char *) -1) {
//         perror("shmat");
//         return(1);
//     }
//     
//     #endif
//     
//     xD[0] = 1;
// 
// }
/* %%%-SFUNWIZ_wrapper_Update_Changes_END --- EDIT HERE TO _BEGIN */
}
