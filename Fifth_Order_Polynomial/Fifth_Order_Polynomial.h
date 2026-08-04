

#ifndef RTW_HEADER_Fifth_Order_Polynomial_h_
#define RTW_HEADER_Fifth_Order_Polynomial_h_
#include <math.h>
#include <stddef.h>
#ifndef Fifth_Order_Polynomial_COMMON_INCLUDES_
#define Fifth_Order_Polynomial_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "zero_crossing_types.h"
#endif                             /* Fifth_Order_Polynomial_COMMON_INCLUDES_ */

#include "Fifth_Order_Polynomial_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

/* Block signals (default storage) */
typedef struct {
  real_T Switch;                       /* '<S7>/Switch' */
  real_T Product;                      /* '<S7>/Product' */
  real_T Product1;                     /* '<S7>/Product1' */
  real_T Product2;                     /* '<S7>/Product2' */
  real_T Product3;                     /* '<S7>/Product3' */
  real_T In[7];                        /* '<S4>/In' */
  real_T Coeff[6];                     /* '<S2>/MATLAB Function' */
  real_T Switch2[6];                   /* '<S1>/Switch2' */
  boolean_T Logic[2];                  /* '<S10>/Logic' */
} B_Fifth_Order_Polynomial_T;

/* Block states (default storage) for system '<Root>' */
typedef struct {
  real_T Delay3_DSTATE;                /* '<S3>/Delay3' */
  real_T Delay1_DSTATE;                /* '<S7>/Delay1' */
  real_T Memory_PreviousInput[3];      /* '<S8>/Memory' */
  real_T Memory_PreviousInput_j;       /* '<S7>/Memory' */
  boolean_T Delay1_DSTATE_j;           /* '<S1>/Delay1' */
  boolean_T UnitDelay_DSTATE;          /* '<S7>/Unit Delay' */
  boolean_T icLoad;                    /* '<S3>/Delay3' */
  boolean_T icLoad_m;                  /* '<S1>/Delay1' */
  boolean_T Memory_PreviousInput_p;    /* '<S6>/Memory' */
  boolean_T Memory_PreviousInput_e;    /* '<S10>/Memory' */
  boolean_T Time_Vector_Calculator_MODE;/* '<S1>/Time_Vector_Calculator' */
} DW_Fifth_Order_Polynomial_T;

/* Zero-crossing (trigger) state */
typedef struct {
  ZCSigState Coefficient_Calculator_Trig_ZCE;/* '<S1>/Coefficient_Calculator' */
} PrevZCX_Fifth_Order_Polynomia_T;

/* Constant parameters (default storage) */
typedef struct {
  /* Pooled Parameter (Expression: [0 1;1 0;0 1;0 1;1 0;1 0;0 0;0 0])
   * Referenced by:
   *   '<S6>/Logic'
   *   '<S10>/Logic'
   */
  boolean_T pooled5[16];
} ConstP_Fifth_Order_Polynomial_T;

/* External inputs (root inport signals with default storage) */
typedef struct {
  real_T Po;                           /* '<Root>/Po' */
  real_T Pf;                           /* '<Root>/Pf' */
  real_T Vo;                           /* '<Root>/Vo' */
  real_T Vf;                           /* '<Root>/Vf' */
  real_T Ao;                           /* '<Root>/Ao' */
  real_T Af;                           /* '<Root>/Af' */
  real_T dT;                           /* '<Root>/dT' */
  real_T Trigger;                      /* '<Root>/Trigger' */
  real_T Step_Time;                    /* '<Root>/Step_Time' */
} ExtU_Fifth_Order_Polynomial_T;

/* External outputs (root outports fed by signals with default storage) */
typedef struct {
  real_T Position_Trajectory;          /* '<Root>/Position_Trajectory' */
  real_T Velocity_Trajectory;          /* '<Root>/Velocity_Trajectory' */
  real_T Acceleration_Trajectory;      /* '<Root>/Acceleration_Trajectory' */
} ExtY_Fifth_Order_Polynomial_T;

/* Real-time Model Data Structure */
struct tag_RTM_Fifth_Order_Polynomia_T {
  const char_T * volatile errorStatus;
};

/* Block signals (default storage) */
extern B_Fifth_Order_Polynomial_T Fifth_Order_Polynomial_B;

/* Block states (default storage) */
extern DW_Fifth_Order_Polynomial_T Fifth_Order_Polynomial_DW;

/* Zero-crossing (trigger) state */
extern PrevZCX_Fifth_Order_Polynomia_T Fifth_Order_Polynomial_PrevZCX;

/* External inputs (root inport signals with default storage) */
extern ExtU_Fifth_Order_Polynomial_T Fifth_Order_Polynomial_U;

/* External outputs (root outports fed by signals with default storage) */
extern ExtY_Fifth_Order_Polynomial_T Fifth_Order_Polynomial_Y;

/* Constant parameters (default storage) */
extern const ConstP_Fifth_Order_Polynomial_T Fifth_Order_Polynomial_ConstP;

/* Model entry point functions */
extern void Fifth_Order_Polynomial_initialize(void);
extern void Fifth_Order_Polynomial_step(void);
extern void Fifth_Order_Polynomial_terminate(void);

/* Real-time Model object */
extern RT_MODEL_Fifth_Order_Polynomi_T *const Fifth_Order_Polynomial_M;

/*-
 * These blocks were eliminated from the model due to optimizations:
 *
 * Block '<S5>/Manual Switch' : Eliminated due to constant selection input
 * Block '<S5>/Constant' : Unused code path elimination
 */

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'Fifth_Order_Polynomial'
 * '<S1>'   : 'Fifth_Order_Polynomial/5th_Order_Trajectory_Generation'
 * '<S2>'   : 'Fifth_Order_Polynomial/5th_Order_Trajectory_Generation/Coefficient_Calculator'
 * '<S3>'   : 'Fifth_Order_Polynomial/5th_Order_Trajectory_Generation/Detect_Signal_Rise1'
 * '<S4>'   : 'Fifth_Order_Polynomial/5th_Order_Trajectory_Generation/Grab_and_Hold'
 * '<S5>'   : 'Fifth_Order_Polynomial/5th_Order_Trajectory_Generation/Prevent_Division_By_Zero'
 * '<S6>'   : 'Fifth_Order_Polynomial/5th_Order_Trajectory_Generation/S-R Flip-Flop1'
 * '<S7>'   : 'Fifth_Order_Polynomial/5th_Order_Trajectory_Generation/Time_Vector_Calculator'
 * '<S8>'   : 'Fifth_Order_Polynomial/5th_Order_Trajectory_Generation/Trajectories'
 * '<S9>'   : 'Fifth_Order_Polynomial/5th_Order_Trajectory_Generation/Coefficient_Calculator/MATLAB Function'
 * '<S10>'  : 'Fifth_Order_Polynomial/5th_Order_Trajectory_Generation/Time_Vector_Calculator/S-R Flip-Flop'
 */
#endif                                /* RTW_HEADER_Fifth_Order_Polynomial_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
