
 * File: Timing_Synchronizer.c
 *
 * Code generated for Simulink model 'Timing_Synchronizer'.
 *
 * Model version                  : 1.14
 * Simulink Coder version         : 9.6 (R2021b) 14-May-2021
 * C/C++ source code generated on : Mon Aug  3 15:10:52 2026
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "Timing_Synchronizer.h"
#include "Timing_Synchronizer_private.h"

/* Block signals (default storage) */
B_Timing_Synchronizer_T Timing_Synchronizer_B;

/* Block states (default storage) */
DW_Timing_Synchronizer_T Timing_Synchronizer_DW;

/* External inputs (root inport signals with default storage) */
ExtU_Timing_Synchronizer_T Timing_Synchronizer_U;

/* External outputs (root outports fed by signals with default storage) */
ExtY_Timing_Synchronizer_T Timing_Synchronizer_Y;

/* Real-time model */
static RT_MODEL_Timing_Synchronizer_T Timing_Synchronizer_M_;
RT_MODEL_Timing_Synchronizer_T *const Timing_Synchronizer_M =
  &Timing_Synchronizer_M_;

/* Model step function */
void Timing_Synchronizer_step(void)
{
  /* Delay: '<S1>/Delay' incorporates:
   *  Inport: '<Root>/Trigger'
   *  Logic: '<S1>/Logical Operator'
   *  Logic: '<S1>/Logical Operator1'
   *  UnitDelay: '<S1>/Unit Delay1'
   */
  if ((!(Timing_Synchronizer_U.Trigger != 0.0)) ||
      Timing_Synchronizer_DW.UnitDelay1_DSTATE) {
    Timing_Synchronizer_DW.Delay_DSTATE = 0.0;
  }

  /* Product: '<S1>/Product' incorporates:
   *  Delay: '<S1>/Delay'
   *  Inport: '<Root>/Step_Time'
   */
  Timing_Synchronizer_Y.Time = Timing_Synchronizer_U.Step_Time *
    Timing_Synchronizer_DW.Delay_DSTATE;

  /* Delay: '<S1>/Delay1' */
  if (Timing_Synchronizer_DW.icLoad) {
    Timing_Synchronizer_DW.Delay1_DSTATE = Timing_Synchronizer_Y.Time;
  }

  /* Outputs for Enabled SubSystem: '<S1>/Subsystem1' incorporates:
   *  EnablePort: '<S2>/Enable'
   */
  /* Logic: '<S1>/Logical Operator3' incorporates:
   *  Delay: '<S1>/Delay1'
   *  Delay: '<S1>/Delay2'
   *  Inport: '<Root>/Cycle_Time'
   *  Inport: '<Root>/Duty_Fraction'
   *  Inport: '<Root>/Trigger'
   *  Inport: '<S2>/Raw_Signals'
   *  RelationalOperator: '<S1>/Relational Operator'
   *  RelationalOperator: '<S1>/Relational Operator1'
   */
  if ((Timing_Synchronizer_Y.Time < Timing_Synchronizer_DW.Delay1_DSTATE) ||
      (Timing_Synchronizer_U.Trigger > Timing_Synchronizer_DW.Delay2_DSTATE)) {
    Timing_Synchronizer_B.Raw_Signals[0] = Timing_Synchronizer_U.Cycle_Time;
    Timing_Synchronizer_B.Raw_Signals[1] = Timing_Synchronizer_U.Duty_Fraction;
  }

  /* End of Logic: '<S1>/Logical Operator3' */
  /* End of Outputs for SubSystem: '<S1>/Subsystem1' */

  /* Switch: '<S1>/Switch1' incorporates:
   *  Inport: '<Root>/Trigger'
   */
  if (Timing_Synchronizer_U.Trigger > 0.5) {
    boolean_T rtb_LessThan1;

    /* RelationalOperator: '<S1>/Less Than1' incorporates:
     *  Inport: '<Root>/Step_Time'
     *  Product: '<S1>/Product1'
     *  Sum: '<S1>/Sum1'
     */
    rtb_LessThan1 = (Timing_Synchronizer_Y.Time >=
                     Timing_Synchronizer_B.Raw_Signals[0] *
                     Timing_Synchronizer_B.Raw_Signals[1] -
                     Timing_Synchronizer_U.Step_Time);

    /* Outport: '<Root>/Synchronization_Signals' incorporates:
     *  Logic: '<S1>/Logical Operator2'
     */
    Timing_Synchronizer_Y.Synchronization_Signals[0] = rtb_LessThan1;
    Timing_Synchronizer_Y.Synchronization_Signals[1] = !rtb_LessThan1;
  } else {
    /* Outport: '<Root>/Synchronization_Signals' incorporates:
     *  Constant: '<S1>/Constant'
     */
    Timing_Synchronizer_Y.Synchronization_Signals[0] = 0.0;
    Timing_Synchronizer_Y.Synchronization_Signals[1] = 0.0;
  }

  /* End of Switch: '<S1>/Switch1' */

  /* RelationalOperator: '<S1>/Less Than' incorporates:
   *  Inport: '<Root>/Step_Time'
   *  Sum: '<S1>/Sum2'
   *  UnitDelay: '<S1>/Unit Delay1'
   */
  Timing_Synchronizer_DW.UnitDelay1_DSTATE = (Timing_Synchronizer_Y.Time >=
    Timing_Synchronizer_B.Raw_Signals[0] - Timing_Synchronizer_U.Step_Time);

  /* Sum: '<S1>/Sum' incorporates:
   *  Constant: '<S1>/Constant1'
   *  Delay: '<S1>/Delay'
   */
  Timing_Synchronizer_DW.Delay_DSTATE++;

  /* Update for Delay: '<S1>/Delay1' */
  Timing_Synchronizer_DW.icLoad = false;
  Timing_Synchronizer_DW.Delay1_DSTATE = Timing_Synchronizer_Y.Time;

  /* Update for Delay: '<S1>/Delay2' incorporates:
   *  Inport: '<Root>/Trigger'
   */
  Timing_Synchronizer_DW.Delay2_DSTATE = Timing_Synchronizer_U.Trigger;
}

/* Model initialize function */
void Timing_Synchronizer_initialize(void)
{
  /* InitializeConditions for Delay: '<S1>/Delay1' */
  Timing_Synchronizer_DW.icLoad = true;
}

/* Model terminate function */
void Timing_Synchronizer_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
