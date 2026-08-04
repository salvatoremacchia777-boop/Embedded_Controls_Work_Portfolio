

#include "Fifth_Order_Polynomial.h"
#include "Fifth_Order_Polynomial_private.h"

/* Block signals (default storage) */
B_Fifth_Order_Polynomial_T Fifth_Order_Polynomial_B;

/* Block states (default storage) */
DW_Fifth_Order_Polynomial_T Fifth_Order_Polynomial_DW;

/* Previous zero-crossings (trigger) states */
PrevZCX_Fifth_Order_Polynomia_T Fifth_Order_Polynomial_PrevZCX;

/* External inputs (root inport signals with default storage) */
ExtU_Fifth_Order_Polynomial_T Fifth_Order_Polynomial_U;

/* External outputs (root outports fed by signals with default storage) */
ExtY_Fifth_Order_Polynomial_T Fifth_Order_Polynomial_Y;

/* Real-time model */
static RT_MODEL_Fifth_Order_Polynomi_T Fifth_Order_Polynomial_M_;
RT_MODEL_Fifth_Order_Polynomi_T *const Fifth_Order_Polynomial_M =
  &Fifth_Order_Polynomial_M_;

/* Model step function */
void Fifth_Order_Polynomial_step(void)
{
  real_T deltaP;
  real_T invdT1;
  real_T invdT2;
  real_T invdT3;
  real_T invdT4;
  int16_T i;
  boolean_T rtb_LogicalOperator3;

  /* Delay: '<S3>/Delay3' incorporates:
   *  Inport: '<Root>/Trigger'
   */
  if (Fifth_Order_Polynomial_DW.icLoad) {
    Fifth_Order_Polynomial_DW.Delay3_DSTATE = Fifth_Order_Polynomial_U.Trigger;
  }

  /* Logic: '<S3>/Logical Operator3' incorporates:
   *  Constant: '<S3>/Constant6'
   *  Constant: '<S3>/Constant7'
   *  Delay: '<S3>/Delay3'
   *  Inport: '<Root>/Trigger'
   *  RelationalOperator: '<S3>/Relational Operator6'
   *  RelationalOperator: '<S3>/Relational Operator7'
   */
  rtb_LogicalOperator3 = ((Fifth_Order_Polynomial_U.Trigger >= 0.5) &&
    (Fifth_Order_Polynomial_DW.Delay3_DSTATE < 0.5));

  /* Outputs for Enabled SubSystem: '<S1>/Grab_and_Hold' incorporates:
   *  EnablePort: '<S4>/Enable'
   */
  if (rtb_LogicalOperator3) {
    /* Inport: '<S4>/In' incorporates:
     *  Gain: '<S5>/Gain'
     *  Inport: '<Root>/Af'
     *  Inport: '<Root>/Ao'
     *  Inport: '<Root>/Pf'
     *  Inport: '<Root>/Po'
     *  Inport: '<Root>/Step_Time'
     *  Inport: '<Root>/Vf'
     *  Inport: '<Root>/Vo'
     *  Inport: '<Root>/dT'
     *  MinMax: '<S5>/Max'
     */
    Fifth_Order_Polynomial_B.In[0] = Fifth_Order_Polynomial_U.Po;
    Fifth_Order_Polynomial_B.In[1] = Fifth_Order_Polynomial_U.Pf;
    Fifth_Order_Polynomial_B.In[2] = Fifth_Order_Polynomial_U.Vo;
    Fifth_Order_Polynomial_B.In[3] = Fifth_Order_Polynomial_U.Vf;
    Fifth_Order_Polynomial_B.In[4] = Fifth_Order_Polynomial_U.Ao;
    Fifth_Order_Polynomial_B.In[5] = Fifth_Order_Polynomial_U.Af;
    Fifth_Order_Polynomial_B.In[6] = fmax(Fifth_Order_Polynomial_U.dT, 10.0 *
      Fifth_Order_Polynomial_U.Step_Time);
  }

  /* End of Outputs for SubSystem: '<S1>/Grab_and_Hold' */

  /* Delay: '<S1>/Delay1' */
  if (Fifth_Order_Polynomial_DW.icLoad_m) {
    Fifth_Order_Polynomial_DW.Delay1_DSTATE_j = rtb_LogicalOperator3;
  }

  /* Outputs for Triggered SubSystem: '<S1>/Coefficient_Calculator' incorporates:
   *  TriggerPort: '<S2>/Trigger'
   */
  if (Fifth_Order_Polynomial_DW.Delay1_DSTATE_j &&
      (Fifth_Order_Polynomial_PrevZCX.Coefficient_Calculator_Trig_ZCE !=
       POS_ZCSIG)) {
    /* MATLAB Function: '<S2>/MATLAB Function' */
    invdT1 = 1.0 / Fifth_Order_Polynomial_B.In[6];
    invdT2 = invdT1 * invdT1;
    invdT3 = invdT2 * invdT1;
    invdT4 = invdT3 * invdT1;
    deltaP = Fifth_Order_Polynomial_B.In[1] - Fifth_Order_Polynomial_B.In[0];
    Fifth_Order_Polynomial_B.Coeff[0] = (invdT4 * invdT1 * 6.0 * deltaP - 3.0 *
      invdT4 * (Fifth_Order_Polynomial_B.In[2] + Fifth_Order_Polynomial_B.In[3]))
      + 0.5 * invdT3 * (Fifth_Order_Polynomial_B.In[5] -
                        Fifth_Order_Polynomial_B.In[4]);
    Fifth_Order_Polynomial_B.Coeff[1] = ((7.0 * Fifth_Order_Polynomial_B.In[3] +
      8.0 * Fifth_Order_Polynomial_B.In[2]) * invdT3 + -15.0 * invdT4 * deltaP)
      - (Fifth_Order_Polynomial_B.In[5] - 1.5 * Fifth_Order_Polynomial_B.In[4]) *
      invdT2;
    Fifth_Order_Polynomial_B.Coeff[2] = (10.0 * invdT3 * deltaP - (2.0 *
      Fifth_Order_Polynomial_B.In[3] + 3.0 * Fifth_Order_Polynomial_B.In[2]) *
      (2.0 * invdT2)) + (Fifth_Order_Polynomial_B.In[5] - 3.0 *
                         Fifth_Order_Polynomial_B.In[4]) * (0.5 * invdT1);
    Fifth_Order_Polynomial_B.Coeff[3] = 0.5 * Fifth_Order_Polynomial_B.In[4];
    Fifth_Order_Polynomial_B.Coeff[4] = Fifth_Order_Polynomial_B.In[2];
    Fifth_Order_Polynomial_B.Coeff[5] = Fifth_Order_Polynomial_B.In[0];
  }

  Fifth_Order_Polynomial_PrevZCX.Coefficient_Calculator_Trig_ZCE =
    Fifth_Order_Polynomial_DW.Delay1_DSTATE_j;

  /* End of Outputs for SubSystem: '<S1>/Coefficient_Calculator' */

  /* Outputs for Enabled SubSystem: '<S1>/Time_Vector_Calculator' incorporates:
   *  EnablePort: '<S7>/Enable'
   */
  /* CombinatorialLogic: '<S6>/Logic' incorporates:
   *  Delay: '<S1>/Delay1'
   *  Inport: '<Root>/Trigger'
   *  Logic: '<S1>/Logical Operator1'
   *  Memory: '<S6>/Memory'
   */
  Fifth_Order_Polynomial_DW.Memory_PreviousInput_p =
    Fifth_Order_Polynomial_ConstP.pooled5[((((uint16_T)
    Fifth_Order_Polynomial_DW.Delay1_DSTATE_j << 1) +
    !(Fifth_Order_Polynomial_U.Trigger != 0.0)) << 1) +
    Fifth_Order_Polynomial_DW.Memory_PreviousInput_p];
  if (Fifth_Order_Polynomial_DW.Memory_PreviousInput_p) {
    uint16_T rowIdx;
    if (!Fifth_Order_Polynomial_DW.Time_Vector_Calculator_MODE) {
      /* InitializeConditions for UnitDelay: '<S7>/Unit Delay' */
      Fifth_Order_Polynomial_DW.UnitDelay_DSTATE = false;

      /* InitializeConditions for Delay: '<S7>/Delay1' */
      Fifth_Order_Polynomial_DW.Delay1_DSTATE = 0.0;

      /* InitializeConditions for Memory: '<S10>/Memory' */
      Fifth_Order_Polynomial_DW.Memory_PreviousInput_e = false;

      /* InitializeConditions for Memory: '<S7>/Memory' */
      Fifth_Order_Polynomial_DW.Memory_PreviousInput_j = 0.0;
      Fifth_Order_Polynomial_DW.Time_Vector_Calculator_MODE = true;
    }

    /* Delay: '<S7>/Delay1' incorporates:
     *  UnitDelay: '<S7>/Unit Delay'
     */
    if (Fifth_Order_Polynomial_DW.UnitDelay_DSTATE) {
      Fifth_Order_Polynomial_DW.Delay1_DSTATE = 0.0;
    }

    /* Product: '<S7>/Product4' incorporates:
     *  Delay: '<S7>/Delay1'
     *  Inport: '<Root>/Step_Time'
     */
    Fifth_Order_Polynomial_B.Switch = Fifth_Order_Polynomial_DW.Delay1_DSTATE *
      Fifth_Order_Polynomial_U.Step_Time;

    /* CombinatorialLogic: '<S10>/Logic' incorporates:
     *  Memory: '<S10>/Memory'
     *  RelationalOperator: '<S7>/Relational Operator'
     */
    rowIdx = ((uint16_T)(Fifth_Order_Polynomial_B.Switch >=
                         Fifth_Order_Polynomial_B.In[6]) << 2) +
      Fifth_Order_Polynomial_DW.Memory_PreviousInput_e;
    Fifth_Order_Polynomial_B.Logic[0U] =
      Fifth_Order_Polynomial_ConstP.pooled5[rowIdx];
    Fifth_Order_Polynomial_B.Logic[1U] =
      Fifth_Order_Polynomial_ConstP.pooled5[rowIdx + 8U];

    /* Switch: '<S7>/Switch' */
    if (Fifth_Order_Polynomial_B.Logic[0]) {
      /* Product: '<S7>/Product4' incorporates:
       *  Memory: '<S7>/Memory'
       *  Switch: '<S7>/Switch'
       */
      Fifth_Order_Polynomial_B.Switch =
        Fifth_Order_Polynomial_DW.Memory_PreviousInput_j;
    }

    /* End of Switch: '<S7>/Switch' */

    /* Product: '<S7>/Product' */
    Fifth_Order_Polynomial_B.Product = Fifth_Order_Polynomial_B.Switch *
      Fifth_Order_Polynomial_B.Switch;

    /* Product: '<S7>/Product1' */
    Fifth_Order_Polynomial_B.Product1 = Fifth_Order_Polynomial_B.Switch *
      Fifth_Order_Polynomial_B.Product;

    /* Product: '<S7>/Product2' */
    Fifth_Order_Polynomial_B.Product2 = Fifth_Order_Polynomial_B.Switch *
      Fifth_Order_Polynomial_B.Product1;

    /* Product: '<S7>/Product3' */
    Fifth_Order_Polynomial_B.Product3 = Fifth_Order_Polynomial_B.Switch *
      Fifth_Order_Polynomial_B.Product2;

    /* Sum: '<S7>/Sum1' incorporates:
     *  Constant: '<S7>/Constant1'
     *  Delay: '<S7>/Delay1'
     */
    Fifth_Order_Polynomial_DW.Delay1_DSTATE++;

    /* Update for UnitDelay: '<S7>/Unit Delay' */
    Fifth_Order_Polynomial_DW.UnitDelay_DSTATE = Fifth_Order_Polynomial_B.Logic
      [0];

    /* Update for Memory: '<S10>/Memory' */
    Fifth_Order_Polynomial_DW.Memory_PreviousInput_e =
      Fifth_Order_Polynomial_B.Logic[0];

    /* Update for Memory: '<S7>/Memory' */
    Fifth_Order_Polynomial_DW.Memory_PreviousInput_j =
      Fifth_Order_Polynomial_B.Switch;
  } else {
    Fifth_Order_Polynomial_DW.Time_Vector_Calculator_MODE = false;
  }

  /* End of Outputs for SubSystem: '<S1>/Time_Vector_Calculator' */

  /* Switch: '<S8>/Switch' incorporates:
   *  Gain: '<S8>/Gain1'
   *  Gain: '<S8>/Gain2'
   *  Gain: '<S8>/Gain3'
   *  Gain: '<S8>/Gain4'
   *  Gain: '<S8>/Gain5'
   *  Gain: '<S8>/Gain6'
   *  Gain: '<S8>/Gain7'
   *  Gain: '<S8>/Gain8'
   *  Product: '<S8>/Product'
   *  Product: '<S8>/Product1'
   *  Product: '<S8>/Product10'
   *  Product: '<S8>/Product11'
   *  Product: '<S8>/Product12'
   *  Product: '<S8>/Product2'
   *  Product: '<S8>/Product4'
   *  Product: '<S8>/Product5'
   *  Product: '<S8>/Product6'
   *  Product: '<S8>/Product7'
   *  Product: '<S8>/Product8'
   *  Product: '<S8>/Product9'
   *  Sum: '<S8>/Sum'
   *  Sum: '<S8>/Sum1'
   *  Sum: '<S8>/Sum10'
   *  Sum: '<S8>/Sum11'
   *  Sum: '<S8>/Sum12'
   *  Sum: '<S8>/Sum2'
   *  Sum: '<S8>/Sum4'
   *  Sum: '<S8>/Sum5'
   *  Sum: '<S8>/Sum6'
   *  Sum: '<S8>/Sum7'
   *  Sum: '<S8>/Sum8'
   *  Sum: '<S8>/Sum9'
   */
  if (!Fifth_Order_Polynomial_B.Logic[0]) {
    /* Switch: '<S1>/Switch3' incorporates:
     *  Constant: '<S1>/Constant5'
     */
    if (Fifth_Order_Polynomial_DW.Memory_PreviousInput_p) {
      invdT1 = Fifth_Order_Polynomial_B.Product3;
      invdT2 = Fifth_Order_Polynomial_B.Product2;
      invdT3 = Fifth_Order_Polynomial_B.Product1;
      invdT4 = Fifth_Order_Polynomial_B.Product;
      deltaP = Fifth_Order_Polynomial_B.Switch;

      /* Switch: '<S1>/Switch2' */
      for (i = 0; i < 6; i++) {
        Fifth_Order_Polynomial_B.Switch2[i] = Fifth_Order_Polynomial_B.Coeff[i];
      }
    } else {
      invdT1 = 0.0;
      invdT2 = 0.0;
      invdT3 = 0.0;
      invdT4 = 0.0;
      deltaP = 0.0;

      /* Switch: '<S1>/Switch2' incorporates:
       *  Constant: '<S1>/Constant3'
       *  Constant: '<S1>/Constant5'
       *  Gain: '<S1>/Gain'
       *  Inport: '<Root>/Ao'
       *  Inport: '<Root>/Po'
       *  Inport: '<Root>/Vo'
       */
      Fifth_Order_Polynomial_B.Switch2[0] = 0.0;
      Fifth_Order_Polynomial_B.Switch2[1] = 0.0;
      Fifth_Order_Polynomial_B.Switch2[2] = 0.0;
      Fifth_Order_Polynomial_B.Switch2[3] = 0.5 * Fifth_Order_Polynomial_U.Ao;
      Fifth_Order_Polynomial_B.Switch2[4] = Fifth_Order_Polynomial_U.Vo;
      Fifth_Order_Polynomial_B.Switch2[5] = Fifth_Order_Polynomial_U.Po;
    }

    /* End of Switch: '<S1>/Switch3' */
    Fifth_Order_Polynomial_DW.Memory_PreviousInput[0] =
      ((((Fifth_Order_Polynomial_B.Switch2[0] * invdT1 +
          Fifth_Order_Polynomial_B.Switch2[1] * invdT2) +
         Fifth_Order_Polynomial_B.Switch2[2] * invdT3) +
        Fifth_Order_Polynomial_B.Switch2[3] * invdT4) +
       Fifth_Order_Polynomial_B.Switch2[4] * deltaP) +
      Fifth_Order_Polynomial_B.Switch2[5];
    Fifth_Order_Polynomial_DW.Memory_PreviousInput[1] =
      (((Fifth_Order_Polynomial_B.Switch2[0] * invdT2 * 5.0 +
         Fifth_Order_Polynomial_B.Switch2[1] * invdT3 * 4.0) +
        Fifth_Order_Polynomial_B.Switch2[2] * invdT4 * 3.0) +
       Fifth_Order_Polynomial_B.Switch2[3] * deltaP * 2.0) +
      Fifth_Order_Polynomial_B.Switch2[4];
    Fifth_Order_Polynomial_DW.Memory_PreviousInput[2] =
      ((Fifth_Order_Polynomial_B.Switch2[0] * invdT3 * 20.0 +
        Fifth_Order_Polynomial_B.Switch2[1] * invdT4 * 12.0) +
       Fifth_Order_Polynomial_B.Switch2[2] * deltaP * 6.0) + 2.0 *
      Fifth_Order_Polynomial_B.Switch2[3];
  }

  /* End of Switch: '<S8>/Switch' */

  /* Outport: '<Root>/Position_Trajectory' */
  Fifth_Order_Polynomial_Y.Position_Trajectory =
    Fifth_Order_Polynomial_DW.Memory_PreviousInput[0];

  /* Outport: '<Root>/Velocity_Trajectory' */
  Fifth_Order_Polynomial_Y.Velocity_Trajectory =
    Fifth_Order_Polynomial_DW.Memory_PreviousInput[1];

  /* Outport: '<Root>/Acceleration_Trajectory' */
  Fifth_Order_Polynomial_Y.Acceleration_Trajectory =
    Fifth_Order_Polynomial_DW.Memory_PreviousInput[2];

  /* Update for Delay: '<S3>/Delay3' incorporates:
   *  Inport: '<Root>/Trigger'
   */
  Fifth_Order_Polynomial_DW.icLoad = false;
  Fifth_Order_Polynomial_DW.Delay3_DSTATE = Fifth_Order_Polynomial_U.Trigger;

  /* Update for Delay: '<S1>/Delay1' */
  Fifth_Order_Polynomial_DW.icLoad_m = false;
  Fifth_Order_Polynomial_DW.Delay1_DSTATE_j = rtb_LogicalOperator3;
}

/* Model initialize function */
void Fifth_Order_Polynomial_initialize(void)
{
  Fifth_Order_Polynomial_PrevZCX.Coefficient_Calculator_Trig_ZCE = POS_ZCSIG;

  /* InitializeConditions for Delay: '<S3>/Delay3' */
  Fifth_Order_Polynomial_DW.icLoad = true;

  /* InitializeConditions for Delay: '<S1>/Delay1' */
  Fifth_Order_Polynomial_DW.icLoad_m = true;
}

/* Model terminate function */
void Fifth_Order_Polynomial_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
