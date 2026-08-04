%% 5th Order Polynomial Trajectory Generator - Test Harness Input Schedule
% Author: Salvatore Macchia
%
% Single source of truth for the test schedule. Builds Po, Pf, Vo, Vf,
% Ao, Af, dT, and Trigger as timeseries objects for use with
% "From Workspace" blocks in the harness -- the schedule table below
% IS the input, so there is nothing to trace or misread in the block
% diagram itself.
%
% Units: boom angle (deg), angular velocity (deg/s), angular
% acceleration (deg/s^2) -- modeled after a hydraulic mining shovel
% boom, where motion is slow and deliberate.
%
% ----------------------------------------------------------------------
% STORY: a rest-to-rest baseline move (Move 1), held for a period, then
% a second rest-to-rest move (Move 2) that gets genuinely interrupted
% partway through by a simulated saturation event. The recovery move
% (Move 3) starts from Move 2's REAL measured state at the moment of
% interruption -- not a synthetic or planned value -- and re-targets the
% SAME final destination Move 2 was headed to. Latch immunity, hold
% behavior, and the dT=0 protection case are all exercised alongside
% this main story rather than in a separate, disconnected test.
% ----------------------------------------------------------------------
%
% Full schedule:
%   0.00 - 1.00s  : idle, Trigger=0, Po=0 (true rest)
%   1.00s         : Trigger rises -- Move 1, rest-to-rest
%                   Po=0, Vo=0, Ao=0 -> Pf=5, Vf=0, Af=0, dT1=5
%                   (runs 1.00 -> 6.00s)
%   2.00 - 2.30s  : raw inputs jitter (scale-appropriate) while Trigger
%                   stays high, inside Move 1's active window --
%                   trajectory must stay unaffected (latched at t=1.0)
%   6.00 - 10.00s : HOLD (4 seconds)
%   10.00s        : Trigger drops 1 step, re-rises at 10.01 -- Move 2,
%                   rest-to-rest
%                   Po=5, Vo=0, Ao=0 -> Pf=15, Vf=0, Af=0, dT2=3
%                   (would run 10.01 -> 13.01s if uninterrupted)
%   11.51s        : SATURATION INTERRUPT -- Trigger drops 1 step,
%                   re-rises at 11.52. This is exactly halfway through
%                   Move 2's 3s run (1.5s in), well before its natural
%                   finish at t=13.01. The handoff values are Move 2's
%                   REAL measured state at this instant (verified against
%                   the closed-form solution in the verification script):
%                   Po=10.0, Vo=6.25, Ao=0 -> Pf=15, Vf=0, Af=0, dT3=1.5
%                   (SAME target as Move 2; dT3 chosen to match the
%                   remaining distance/velocity so the recovery reaches
%                   the target with NO overshoot -- see design notes)
%                   (runs 11.52 -> 13.02s)
%   13.02 - 15.00s: hold after Move 3 completes
%   15.00s        : Trigger drops 1 step, re-rises at 15.01 -- dT=0 edge case
%                   Po=0, Vo=0, Ao=0 -> Pf=10, Vf=0, Af=0, dT=0
%                   (tests Prevent_Division_By_Zero / dT_Protected)
%   18.00s        : simulation end

clear; clc; close('all');

Step_Time = 0.01;
Total_Sim_Time = 18.0;
eps_t = Step_Time; % one-sample epsilon for clean steps, not ramps

%% Schedule breakpoints
% Columns: [t, Po, Pf, Vo, Vf, Ao, Af, dT, Trigger]
S = [ ...
  0.00                0    0      0     0     0     0    5   0;
  1.00-eps_t          0    0      0     0     0     0    5   0;
  1.00                0    5      0     0     0     0    5   1;   % Move 1 rises (rest-to-rest)
  2.00-eps_t          0    5      0     0     0     0    5   1;
  2.00                2   10     -2     3     1    -1    2   1;   % jitter -- scale-appropriate, should have no effect
  2.30-eps_t           2   10     -2     3     1    -1    2   1;
  2.30                0    5      0     0     0     0    5   1;   % revert (cosmetic; latch already holds regardless)
  10.00-eps_t         0    5      0     0     0     0    5   1;   % covers 2.30 -> 10.00, including the 6-10s hold
  10.00               0    5      0     0     0     0    5   0;   % Trigger drop -- required to force a fresh rising edge for Move 2
  10.00+eps_t         5   15      0     0     0     0    3   1;   % Move 2 rises for real (rest-to-rest, will be interrupted)
  11.51-eps_t         5   15      0     0     0     0    3   1;
  11.51             10.0   15   6.25     0     0     0  1.5   0;   % saturation interrupt -- 1-step drop
  11.51+eps_t       10.0   15   6.25     0     0     0  1.5   1;   % re-rise, from the REAL measured mid-flight state
  15.00-eps_t       10.0   15   6.25     0     0     0  1.5   1;   % covers Move 3 running (11.52-13.02) + hold (13.02-15.00)
  15.00             10.0   15   6.25     0     0     0  1.5   0;   % 1-step drop
  15.00+eps_t          0   10      0     0     0     0    0   1;   % re-rise -- dT=0 edge case
  Total_Sim_Time       0   10      0     0     0     0    0   1;
];

sched_t   = S(:,1);
Po_ts     = timeseries(S(:,2), sched_t, 'Name', 'Po');
Pf_ts     = timeseries(S(:,3), sched_t, 'Name', 'Pf');
Vo_ts     = timeseries(S(:,4), sched_t, 'Name', 'Vo');
Vf_ts     = timeseries(S(:,5), sched_t, 'Name', 'Vf');
Ao_ts     = timeseries(S(:,6), sched_t, 'Name', 'Ao');
Af_ts     = timeseries(S(:,7), sched_t, 'Name', 'Af');
dT_ts     = timeseries(S(:,8), sched_t, 'Name', 'dT');
Trigger_ts= timeseries(S(:,9), sched_t, 'Name', 'Trigger');

fprintf('Schedule timeseries built: Po_ts, Pf_ts, Vo_ts, Vf_ts, Ao_ts, Af_ts, dT_ts, Trigger_ts\n');
fprintf('Wire each into a "From Workspace" block in the test harness (variable name must match).\n');
fprintf('Total_Sim_Time = %.2f s, Step_Time = %.3f s\n', Total_Sim_Time, Step_Time);
fprintf('Run the model, then run FifthOrder_Trajectory_Verification.m to check results.\n');
