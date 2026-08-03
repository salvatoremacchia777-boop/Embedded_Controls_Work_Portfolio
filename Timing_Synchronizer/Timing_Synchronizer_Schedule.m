%% Timing Synchronizer Test Harness - Input Schedule
% Author: Salvatore Macchia
%
% This script is the single source of truth for the test schedule below.
% It builds Cycle_Time, Duty_Fraction, and Trigger as timeseries objects
% directly from the schedule table, for use with "From Workspace" blocks
% in the harness (one per signal) instead of switch-based logic. This
% removes any ambiguity about which value is "active" at a given time --
% the input signal literally IS the table, so there's nothing to trace
% or misread in the block diagram itself.
%
% Test schedule -- designed to isolate one variable change at a time:
%   0.00 - 3.00s : Cycle_Time=0.50, Duty_Fraction=0.50, Trigger=1   (baseline)
%   3.00 - 3.35s : Cycle_Time=0.50, Duty_Fraction=0.50, Trigger=1
%   3.35 - 3.70s : Cycle_Time=0.50, Duty_Fraction=0.25, Trigger=1   (Duty_Fraction changes mid-cycle)
%   3.70 - 6.00s : Cycle_Time=1.00, Duty_Fraction=0.25, Trigger=1   (Cycle_Time changes, boundary-aligned)
%   6.00 - 8.00s : Cycle_Time=1.00, Duty_Fraction=0.25, Trigger=0   (Trigger drops)
%   8.00 - 12.00s: Cycle_Time=0.50, Duty_Fraction=0.60, Trigger=1   (Trigger re-rises)

clear; clc; close('all');

Step_Time = 0.01;
T_Finish  = 12;

%% Schedule breakpoints
% A one-sample epsilon is inserted just before each change so the
% From Workspace block produces a clean step, not an interpolated ramp.
eps_t = Step_Time;

sched_t = [0, 3.00-eps_t, 3.00, 3.35-eps_t, 3.35, 3.70-eps_t, 3.70, 6.00-eps_t, 6.00, 8.00-eps_t, 8.00, T_Finish];

sched_CycleTime = [0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 1.00, 1.00, 1.00, 1.00, 0.50, 0.50];
sched_DutyFrac  = [0.50, 0.50, 0.50, 0.50, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.60, 0.60];
sched_Trigger   = [1,    1,    1,    1,    1,    1,    1,    1,    0,    0,    1,    1   ];

Cycle_Time_ts    = timeseries(sched_CycleTime, sched_t, 'Name', 'Cycle_Time');
Duty_Fraction_ts = timeseries(sched_DutyFrac,  sched_t, 'Name', 'Duty_Fraction');
Trigger_ts       = timeseries(sched_Trigger,   sched_t, 'Name', 'Trigger');

fprintf('Schedule timeseries built: Cycle_Time_ts, Duty_Fraction_ts, Trigger_ts\n');
fprintf('Run the model, then run Timing_Synchronizer_Verification.m to check results.\n');
