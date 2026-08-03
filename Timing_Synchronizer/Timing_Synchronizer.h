
#ifndef RTW_HEADER_Timing_Synchronizer_h_
#define RTW_HEADER_Timing_Synchronizer_h_
#ifndef Timing_Synchronizer_COMMON_INCLUDES_
#define Timing_Synchronizer_COMMON_INCLUDES_
#include "rtwtypes.h"
#endif                                /* Timing_Synchronizer_COMMON_INCLUDES_ */

#include "Timing_Synchronizer_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

/* Block signals (default storage) */
typedef struct {
  real_T Raw_Signals[2];               /* '<S2>/Raw_Signals' */
} B_Timing_Synchronizer_T;

/* Block states (default storage) for system '<Root>' */
typedef struct {
  real_T Delay_DSTATE;                 /* '<S1>/Delay' */
  real_T Delay1_DSTATE;                /* '<S1>/Delay1' */
  real_T Delay2_DSTATE;                /* '<S1>/Delay2' */
  boolean_T UnitDelay1_DSTATE;         /* '<S1>/Unit Delay1' */
  boolean_T icLoad;                    /* '<S1>/Delay1' */
} DW_Timing_Synchronizer_T;

/* External inputs (root inport signals with default storage) */
typedef struct {
  real_T Cycle_Time;                   /* '<Root>/Cycle_Time' */
  real_T Step_Time;                    /* '<Root>/Step_Time' */
  real_T Duty_Fraction;                /* '<Root>/Duty_Fraction' */
  real_T Trigger;                      /* '<Root>/Trigger' */
} ExtU_Timing_Synchronizer_T;

/* External outputs (root outports fed by signals with default storage) */
typedef struct {
  real_T Synchronization_Signals[2];   /* '<Root>/Synchronization_Signals' */
  real_T Time;                         /* '<Root>/Time' */
} ExtY_Timing_Synchronizer_T;

/* Real-time Model Data Structure */
struct tag_RTM_Timing_Synchronizer_T {
  const char_T * volatile errorStatus;
};

/* Block signals (default storage) */
extern B_Timing_Synchronizer_T Timing_Synchronizer_B;

/* Block states (default storage) */
extern DW_Timing_Synchronizer_T Timing_Synchronizer_DW;

/* External inputs (root inport signals with default storage) */
extern ExtU_Timing_Synchronizer_T Timing_Synchronizer_U;

/* External outputs (root outports fed by signals with default storage) */
extern ExtY_Timing_Synchronizer_T Timing_Synchronizer_Y;

/* Model entry point functions */
extern void Timing_Synchronizer_initialize(void);
extern void Timing_Synchronizer_step(void);
extern void Timing_Synchronizer_terminate(void);

/* Real-time Model object */
extern RT_MODEL_Timing_Synchronizer_T *const Timing_Synchronizer_M;

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
 * '<Root>' : 'Timing_Synchronizer'
 * '<S1>'   : 'Timing_Synchronizer/Timing_Synchronizer'
 * '<S2>'   : 'Timing_Synchronizer/Timing_Synchronizer/Subsystem1'
 */
#endif                                 /* RTW_HEADER_Timing_Synchronizer_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
