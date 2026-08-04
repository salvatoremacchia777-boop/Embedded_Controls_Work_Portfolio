%% 5th Order Polynomial Trajectory Generator - Verification
% Author: Salvatore Macchia
%
% Checks the 5th_Order_Trajectory_Generation block against the 5
% requirements it's meant to satisfy:
%   1) Coefficients are computed exactly once per Trigger rising edge
%   2) The active trajectory is unaffected by input changes while
%      Trigger remains high (requirements 1 and 2 are verified together,
%      since a violation of either shows up as an unexpected change in
%      the output during the jitter window)
%   3) dT_Protected prevents a division-by-zero when dT is commanded to 0
%   4) A new trajectory can be triggered mid-flight, starting from the
%      block's actual current (non-rest) state -- not an arbitrary or
%      synthetic value, but the trajectory's own real measured state at
%      the moment of interruption
%   5) The block holds its final values once a trajectory's dT has elapsed
%
% Units: boom angle (deg), angular velocity (deg/s), angular
% acceleration (deg/s^2) -- modeled after a hydraulic mining shovel boom.
%
% Only Position_Trajectory, Velocity_Trajectory, and Acceleration_Trajectory
% are logged from the model. All expected values are computed independently
% here using the same closed-form solve_quintic math, evaluated against the
% known schedule (built in FifthOrder_Trajectory_Schedule.m) -- this is a
% second, independent implementation of the coefficient math used purely
% for cross-checking, not a call into the block's own MATLAB Function.
%
% Run FifthOrder_Trajectory_Schedule.m FIRST, then run this script.

clc;

%% Run the model
modelName = 'Fifth_Order_Polynomial_Test_Harness';
simOut = sim(modelName);
logsout = simOut.logsout;

P_sig = logsout.getElement('Position_Trajectory').Values;
V_sig = logsout.getElement('Velocity_Trajectory').Values;
A_sig = logsout.getElement('Acceleration_Trajectory').Values;

t = P_sig.Time;
P = squeeze(P_sig.Data);
V = squeeze(V_sig.Data);
Acc = squeeze(A_sig.Data);

Step_Time = median(diff(t));
fprintf('\n=== 5th Order Trajectory Generator - Verification ===\n');
fprintf('Step_Time inferred from log: %.4f s\n\n', Step_Time);

solve_quintic_check = @(Po,Pf,Vo,Vf,Ao,Af,dT) local_solve_quintic(Po,Pf,Vo,Vf,Ao,Af,dT);

%% ---- Requirements 1 & 2: latching / jitter immunity (inside Move 1) ----
% Move 1 (rest-to-rest): Trigger rises at t=1.0, Po=0,Vo=0,Ao=0 -> Pf=5,Vf=0,Af=0, dT1=5
% Raw inputs jitter (scale-appropriate) from t=2.00-2.30 while Trigger stays high.
coeff_move1 = solve_quintic_check(0,5,0,0,0,0,5);
idx_jitter = find(t >= 2.00 & t <= 2.30);
tl_jitter = t(idx_jitter) - 1.0;
[P_exp, ~, ~] = eval_quintic(coeff_move1, tl_jitter);
dev12 = max(abs(P(idx_jitter) - P_exp));
req12_pass = dev12 < 0.2;

%% ---- Requirement: Move 1 ends at rest (rest-to-rest boundary check) ----
idx_move1_end = find(t >= 5.95 & t <= 6.05, 1, 'last');
move1_rest_pass = ~isempty(idx_move1_end) && abs(V(idx_move1_end)) < 0.1 && abs(Acc(idx_move1_end)) < 0.1;

%% ---- Requirement 5a: hold (6.00 - 10.00s) ----
idx_hold1 = find(t >= 6.10 & t <= 9.90);
hold1_pass = all(abs(P(idx_hold1) - 5) < 0.05) && all(abs(V(idx_hold1)) < 0.05);

%% ---- Requirement: Move 2 actually runs (10.02 - 11.50s) ----
% Confirms Move 2 is genuinely executing (not stuck holding Move 1's
% value) before the saturation interrupt hits.
coeff_move2 = solve_quintic_check(5,15,0,0,0,0,3);
idx_m2 = find(t >= 10.02 & t < 11.50);
tl_m2 = t(idx_m2) - 10.01;
[P_exp_m2, ~, ~] = eval_quintic(coeff_move2, tl_m2);
dev_m2 = max(abs(P(idx_m2) - P_exp_m2));
move2_running_pass = dev_m2 < 0.2;

%% ---- Requirement 4: saturation interrupt, genuine mid-flight non-rest handoff ----
% Verify the schedule's hardcoded handoff (Po=10.0, Vo=6.25, Ao=0) truly
% matches Move 2's own math at its halfway point (local t=1.5).
[Po_real, Vo_real, Ao_real] = eval_quintic(coeff_move2, 1.5);
handoff_consistent = abs(Po_real-10.0)<0.01 && abs(Vo_real-6.25)<0.01 && abs(Ao_real-0)<0.01;

% Move 3: same target as Move 2 (Pf=15,Vf=0,Af=0), dT3=1.5, starts at t=11.52
coeff_move3 = solve_quintic_check(10.0, 15, 6.25, 0, 0, 0, 1.5);
idx_r3 = find(t >= 11.52 & t < 13.01);
tl_r3 = t(idx_r3) - 11.52;
[P_exp3, ~, ~] = eval_quintic(coeff_move3, tl_r3);
[dev4, worst_idx] = max(abs(P(idx_r3) - P_exp3));
fprintf('Req 4 worst deviation at t=%.3f: actual=%.4f, expected=%.4f\n', ...
    t(idx_r3(worst_idx)), P(idx_r3(worst_idx)), P_exp3(worst_idx));
req4_pass = dev4 < 0.2 && handoff_consistent;

%% ---- Requirement: Move 3 reaches target with no overshoot ----
idx_m3 = find(t >= 11.52 & t <= 13.02);
no_overshoot_pass = max(P(idx_m3)) <= 15 + 0.1;

%% ---- Requirement 5b: hold after Move 3 (13.02 - 15.00s) ----
idx_hold2 = find(t >= 13.15 & t <= 14.90);
hold2_pass = all(abs(P(idx_hold2) - 15) < 0.05) && all(abs(V(idx_hold2)) < 0.05);

%% ---- Requirement 3: dT=0 protection ----
idx_dt0 = find(t >= 15.01);
no_nan_inf = all(isfinite(P(idx_dt0))) && all(isfinite(V(idx_dt0))) && all(isfinite(Acc(idx_dt0)));
expected_protected_dT = 10*Step_Time;
idx_hold3 = find(t >= 15.01+expected_protected_dT+0.05 & t <= 18.0);
hold3_pass = ~isempty(idx_hold3) && all(abs(P(idx_hold3) - 10) < 0.1);
req3_pass = no_nan_inf && hold3_pass;

%% ---- Compact Summary ----
fprintf('%-48s %-10s %-12s\n', 'Requirement', 'Result', 'Max Dev (deg)');
fprintf('%s\n', repmat('-', 1, 71));
fprintf('%-48s %-10s %-12.4f\n', '1&2: Latch / jitter immunity', string(req12_pass), dev12);
fprintf('%-48s %-10s %-12s\n', 'Move 1 ends at rest (V=A=0)', string(move1_rest_pass), 'n/a');
fprintf('%-48s %-10s %-12s\n', '5a: Hold (6-10s)', string(hold1_pass), 'n/a');
fprintf('%-48s %-10s %-12.4f\n', 'Move 2 actually runs', string(move2_running_pass), dev_m2);
fprintf('%-48s %-10s %-12.4f\n', '4: Saturation interrupt (real mid-flight)', string(req4_pass), dev4);
fprintf('%-48s %-10s %-12s\n', 'Move 3 reaches target with no overshoot', string(no_overshoot_pass), 'n/a');
fprintf('%-48s %-10s %-12s\n', '5b: Hold after Move 3', string(hold2_pass), 'n/a');
fprintf('%-48s %-10s %-12s\n', '3: dT=0 protection (no NaN/Inf + holds)', string(req3_pass), 'n/a');
fprintf('%s\n', repmat('-', 1, 71));
all_pass = req12_pass && move1_rest_pass && hold1_pass && move2_running_pass && ...
    req4_pass && no_overshoot_pass && hold2_pass && req3_pass;
fprintf('Overall: %s\n\n', string(all_pass));

%% ---- Verification Plot (Main) ----
% Cropped to the working phases only (through the hold after Move 3),
% excluding the dT=0 edge case -- that case uses a very different
% acceleration/velocity scale and would otherwise flatten this entire
% plot into an unreadable near-zero line. See the separate supplementary
% figure below for the dT=0 edge case specifically.
main_plot_end = 14.9;
idx_main = t <= main_plot_end;

figure('Name', '5th Order Trajectory Verification - Main', 'Position', [100 100 1000 750]);
transition_t = [1.0, 6.0, 10.0, 11.51, 13.02];
transition_labels = {'Move 1 (rest-to-rest)', 'Hold begins', 'Move 2 rises', ...
                      'Saturation interrupt', 'Hold begins'};

ax1 = subplot(3,1,1);
plot(t(idx_main), P(idx_main), 'Color', [0 0.45 0.85], 'LineWidth', 1.5); hold on;
for k = 1:length(transition_t)
    xline(transition_t(k), '--k', 'LineWidth', 1);
end
ylabel('Boom Angle (deg)'); title('Position Trajectory'); grid on;

ax2 = subplot(3,1,2);
plot(t(idx_main), V(idx_main), 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5); hold on;
for k = 1:length(transition_t)
    xline(transition_t(k), '--k', 'LineWidth', 1);
end
ylabel('Angular Velocity (deg/s)'); title('Velocity Trajectory'); grid on;

ax3 = subplot(3,1,3);
plot(t(idx_main), Acc(idx_main), 'Color', [0 0.6 0], 'LineWidth', 1.5); hold on;
for k = 1:length(transition_t)
    xline(transition_t(k), '--k', transition_labels{k}, 'LabelOrientation', 'horizontal', 'FontSize', 7);
end
ylabel('Angular Accel (deg/s^2)'); xlabel('Time (s)'); title('Acceleration Trajectory'); grid on;

linkaxes([ax1, ax2, ax3], 'x');
xlim(ax1, [0 main_plot_end]);

%% ---- Verification Plot (Supplementary): dT=0 Edge Case Only ----
% Shown separately, at its own natural scale, since the acceleration/
% velocity magnitudes here are roughly two orders of magnitude larger
% than the working phases above -- plotting them together would make
% the main verification unreadable.
idx_edge = t >= 14.5;

figure('Name', '5th Order Trajectory Verification - dT=0 Edge Case', 'Position', [100 100 700 600]);

ax4 = subplot(3,1,1);
plot(t(idx_edge), P(idx_edge), 'Color', [0 0.45 0.85], 'LineWidth', 1.5); hold on;
xline(15.0, '--k', 'dT=0 edge case', 'LabelOrientation', 'horizontal', 'FontSize', 7);
ylabel('Boom Angle (deg)'); title('dT=0 Edge Case: Position'); grid on;

ax5 = subplot(3,1,2);
plot(t(idx_edge), V(idx_edge), 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5); hold on;
xline(15.0, '--k', 'LineWidth', 1);
ylabel('Angular Velocity (deg/s)'); title('dT=0 Edge Case: Velocity'); grid on;

ax6 = subplot(3,1,3);
plot(t(idx_edge), Acc(idx_edge), 'Color', [0 0.6 0], 'LineWidth', 1.5); hold on;
xline(15.0, '--k', 'LineWidth', 1);
ylabel('Angular Accel (deg/s^2)'); xlabel('Time (s)'); title('dT=0 Edge Case: Acceleration'); grid on;

linkaxes([ax4, ax5, ax6], 'x');

%% ---- Local functions (must be at the end of the script file) ----
function coeff = local_solve_quintic(Po,Pf,Vo,Vf,Ao,Af,dT)
    invdT1 = 1/dT; invdT2 = invdT1*invdT1; invdT3 = invdT2*invdT1;
    invdT4 = invdT3*invdT1; invdT5 = invdT4*invdT1;
    deltaP = Pf-Po; deltaA = Af-Ao;
    F = Po; E = Vo; D = 0.5*Ao;
    C = (10*invdT3*deltaP)-(2*invdT2*((2*Vf)+(3*Vo))) + (0.5*invdT1)*(Af-(3*Ao));
    B = (-15*invdT4*deltaP)+(invdT3*((7*Vf)+(8*Vo))) - (invdT2)*(Af-(1.5*Ao));
    A = (6*invdT5*deltaP)-(3*invdT4*((Vf)+(Vo)))+((0.5*invdT3)*(deltaA));
    coeff = [A,B,C,D,E,F];
end

function [P,V,Acc] = eval_quintic(coeff, tl)
    A=coeff(1); B=coeff(2); C=coeff(3); D=coeff(4); E=coeff(5); F=coeff(6);
    P = A*tl.^5 + B*tl.^4 + C*tl.^3 + D*tl.^2 + E*tl + F;
    V = 5*A*tl.^4 + 4*B*tl.^3 + 3*C*tl.^2 + 2*D*tl + E;
    Acc = 20*A*tl.^3 + 12*B*tl.^2 + 6*C*tl + 2*D;
end