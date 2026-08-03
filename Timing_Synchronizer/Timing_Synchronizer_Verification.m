%% Timing Synchronizer Test Harness - Verification
% Author: Salvatore Macchia
%
% This script checks the Timing_Synchronizer block against the 5
% requirements it's meant to satisfy:
%   1) Time resets exactly every Cycle_Time seconds (steady state)
%   2) A live Cycle_Time change takes effect only at the NEXT reset
%      boundary, not immediately
%   3) A live Duty_Fraction change takes effect only at the NEXT reset
%      boundary, not immediately
%   4) After a Trigger drop and re-rise, the block re-latches correctly
%      (no stale values carried over from before the drop)
%   5) Low_First_Boolean and High_First_Boolean are always mutually
%      exclusive while Trigger is high, and both are 0 while Trigger is low
%
% Verification is done "black box" -- only top-level, externally
% observable signals are used (Time, Cycle_Time, Duty_Fraction, Trigger,
% Low_First_Boolean, High_First_Boolean). No internal block signals are
% referenced, so this proves correct behavior from the outside, the same
% way any user of the block would observe it.
%
% Note on the expected on-fraction formula (requirements 3 and 4):
% Time is a discrete counter, so any "Time >= Threshold" comparison
% resolves one sample late -- the counter can only cross a threshold at
% its next scheduled increment, never exactly on it. The block corrects
% for this by subtracting one Step_Time from the on/off-duration
% threshold, so the expected on-time is (Duty_Fraction * Cycle_Time) -
% Step_Time, not the raw product.
%
% Run Timing_Synchronizer_Schedule.m FIRST to build the input timeseries,
% then run this script.

clc;

%% Run the model
modelName = 'Timing_Synchronizer_Test_Harness';
simOut = sim(modelName);
logsout = simOut.logsout;

Time_sig  = logsout.getElement('Time').Values;
Cyc_sig   = logsout.getElement('Cycle_Time').Values;
Duty_sig  = logsout.getElement('Duty_Fraction').Values;
Trig_sig  = logsout.getElement('Trigger').Values;
Lo_sig    = logsout.getElement('Low_First_Boolean').Values;
Hi_sig    = logsout.getElement('High_First_Boolean').Values;

t    = Time_sig.Time;
Tm   = squeeze(Time_sig.Data);
Cyc  = squeeze(Cyc_sig.Data);
Duty = squeeze(Duty_sig.Data);
Trig = squeeze(Trig_sig.Data);
Lo   = squeeze(Lo_sig.Data);
Hi   = squeeze(Hi_sig.Data);

Step_Time = median(diff(t));

fprintf('\n=== Timing Synchronizer Verification ===\n');
fprintf('Step_Time inferred from log: %.4f s\n\n', Step_Time);

%% ---- Requirement 5 (checked first -- applies at every sample, independent of resets) ----
% Low and High must be exact complements while Trigger is high; both 0 while Trigger is low.
trig_high = Trig > 0.5;
mutually_exclusive_ok = all( (Lo(trig_high) ~= Hi(trig_high)) );  % exactly one high, one low
both_zero_ok = all( Lo(~trig_high) == 0 & Hi(~trig_high) == 0 );

fprintf('--- Requirement 5: Low/High boolean mutual exclusivity ---\n');
fprintf('While Trigger high: Low/High always exactly one true?  %s\n', string(mutually_exclusive_ok));
fprintf('While Trigger low:  both Low and High are 0?            %s\n', string(both_zero_ok));
req5_pass = mutually_exclusive_ok && both_zero_ok;
fprintf('Requirement 5 result: %s\n\n', string(req5_pass));

%% ---- Find reset instants for requirements 1-4 ----
reset_idx = find(diff(Tm) < 0) + 1;

fprintf('--- Requirements 1-4: per-cycle interval and parameter-latching check ---\n');
fprintf('%-8s %-8s %-10s %-10s %-10s %-8s %-10s %-8s\n', ...
    'Cycle#', 'StartT', 'Interval', 'Cyc_cmd', 'Cyc_ok', 'Trig_ok', 'Note', 'Scored?');
fprintf('%s\n', repmat('-', 1, 80));

req1_results = [];
for i = 2:length(reset_idx)
    idx_start = reset_idx(i-1);
    idx_end   = reset_idx(i);

    interval_measured = t(idx_end) - t(idx_start);
    cyc_cmd = Cyc(idx_start); % value commanded at the start of this interval

    trig_ok = all(Trig(idx_start:idx_end-1) > 0.5);
    is_scored = trig_ok; % exclude Trigger-transition intervals from requirement 1/2/3 scoring

    cyc_match = abs(interval_measured - cyc_cmd) < 2*Step_Time;

    note = '';
    if ~trig_ok
        note = 'Trigger transition (excluded)';
    end

    fprintf('%-8d %-8.3f %-10.4f %-10.4f %-10s %-8s %-10s %-8s\n', ...
        i-1, t(idx_start), interval_measured, cyc_cmd, string(cyc_match), ...
        string(trig_ok), note, string(is_scored));

    req1_results = [req1_results; cyc_match, is_scored]; %#ok<AGROW>
end

scored_rows = req1_results(logical(req1_results(:,2)), :);
req1_pass = all(scored_rows(:,1));
fprintf('\nRequirement 1 (Time resets exactly every Cycle_Time): %s  (%d/%d scored cycles matched)\n', ...
    string(req1_pass), sum(scored_rows(:,1)), size(scored_rows,1));

%% ---- Requirement 2: Cycle_Time change at t=3.70 should NOT affect the cycle already in progress ----
% Find the cycle that STARTS just before 3.70 -- its interval should still
% reflect the OLD Cycle_Time (0.50), not the new one (1.00), since the
% change happens mid-cycle relative to the reset schedule.
idx_before_change = find(t(reset_idx(1:end-1)) < 3.70, 1, 'last');
if ~isempty(idx_before_change)
    interval_at_change = t(reset_idx(idx_before_change+1)) - t(reset_idx(idx_before_change));
    old_cyc_value = Cyc(reset_idx(idx_before_change));
    req2_pass = abs(interval_at_change - old_cyc_value) < 2*Step_Time;
    fprintf('\nRequirement 2 (Cycle_Time change deferred to next boundary): %s\n', string(req2_pass));
    fprintf('   Interval spanning the change: %.4f s (expected to match pre-change Cycle_Time %.4f s)\n', ...
        interval_at_change, old_cyc_value);
else
    fprintf('\nRequirement 2: could not locate a cycle boundary near t=3.70 -- check schedule/log data.\n');
end

%% ---- Requirement 3: Duty_Fraction change at t=3.35 should NOT affect the cycle already in progress ----
idx_duty_change = find(t(reset_idx(1:end-1)) < 3.35, 1, 'last');
if ~isempty(idx_duty_change)
    i0 = reset_idx(idx_duty_change);
    i1 = reset_idx(idx_duty_change+1);
    duty_meas = sum(Hi(i0:i1-1) > 0.5) / (i1 - i0);
    duty_cmd_at_start = Duty(i0);
    on_time_expected = (duty_cmd_at_start * Cyc(i0)) - Step_Time;
    duty_expected = on_time_expected / Cyc(i0);
    req3_pass = abs(duty_meas - duty_expected) < 0.1;
    fprintf('\nRequirement 3 (Duty_Fraction change deferred to next boundary): %s\n', string(req3_pass));
    fprintf('   Measured on-fraction: %.3f (expected ~%.3f based on PRE-change Duty_Fraction %.2f)\n', ...
        duty_meas, duty_expected, duty_cmd_at_start);
else
    fprintf('\nRequirement 3: could not locate a cycle boundary near t=3.35 -- check schedule/log data.\n');
end

%% ---- Requirement 4: after Trigger re-rises at t=8, does the block re-latch correctly? ----
% Check the FIRST full cycle after the re-rise uses the NEW Cycle_Time (0.50)
% AND the NEW Duty_Fraction (0.60), not stale values from before the drop
% (1.00 / 0.25).
idx_after_rerise = find(t(reset_idx) >= 8.0, 2, 'first'); % first two resets after re-rise
if length(idx_after_rerise) >= 2
    i0 = reset_idx(idx_after_rerise(1));
    i1 = reset_idx(idx_after_rerise(2));
    interval_after = t(i1) - t(i0);
    cyc_after = Cyc(i0);
    cyc_relatch_pass = abs(interval_after - cyc_after) < 2*Step_Time && abs(cyc_after - 0.50) < 1e-6;

    % Duty_Fraction re-latch check
    duty_after_cmd = Duty(i0);
    duty_after_meas = sum(Hi(i0:i1-1) > 0.5) / (i1 - i0);
    on_time_expected_after = (duty_after_cmd * cyc_after) - Step_Time;
    duty_after_expected = on_time_expected_after / cyc_after;
    duty_relatch_pass = abs(duty_after_meas - duty_after_expected) < 0.1 && abs(duty_after_cmd - 0.60) < 1e-6;

    req4_pass = cyc_relatch_pass && duty_relatch_pass;

    fprintf('\nRequirement 4 (correct re-latch after Trigger drop/re-rise): %s\n', string(req4_pass));
    fprintf('   Cycle_Time re-latch:    interval=%.4f s, commanded Cycle_Time=%.2f s  -> %s\n', ...
        interval_after, cyc_after, string(cyc_relatch_pass));
    fprintf('   Duty_Fraction re-latch: measured on-fraction=%.3f, expected ~%.3f (commanded Duty_Fraction=%.2f)  -> %s\n', ...
        duty_after_meas, duty_after_expected, duty_after_cmd, string(duty_relatch_pass));
else
    fprintf('\nRequirement 4: not enough resets logged after t=8 -- check schedule/log data.\n');
end

%% ---- Overall Summary ----
fprintf('\n=== Summary ===\n');
fprintf('Req 1 (steady-state period match):        %s\n', string(req1_pass));
if exist('req2_pass','var'), fprintf('Req 2 (Cycle_Time change deferred):        %s\n', string(req2_pass)); end
if exist('req3_pass','var'), fprintf('Req 3 (Duty_Fraction change deferred):     %s\n', string(req3_pass)); end
if exist('req4_pass','var'), fprintf('Req 4 (re-latch after Trigger drop):       %s\n', string(req4_pass)); end
fprintf('Req 5 (Low/High mutual exclusivity):       %s\n', string(req5_pass));

%% ---- Verification Plot ----
% Each transition is categorized by WHAT changed, so lines are colored
% consistently across all three subplots:
%   Duty_Fraction only   -> magenta
%   Cycle_Time only      -> green
%   Trigger event         -> black
transition_t      = [3.35,      3.70,       6.00,     8.00];
transition_labels = {'Duty change', 'Cycle\_Time change', 'Trigger drop', 'Trigger re-rise'};
transition_colors = {[0.85 0 0.85], [0 0.6 0], [0 0 0], [0 0 0]};

figure('Name', 'Timing Synchronizer Verification', 'Position', [100 100 1000 750]);

ax1 = subplot(3,1,1);
plot(t, Tm, 'Color', [0 0.45 0.85], 'LineWidth', 1.5); hold on;
for k = 1:length(transition_t)
    xline(transition_t(k), '--', 'Color', transition_colors{k}, 'LineWidth', 1.2);
end
ylabel('Time (s)'); title('Time'); grid on;

ax2 = subplot(3,1,2);
plot(t, Lo, 'Color', [0 0.45 0.85], 'LineWidth', 1.5); hold on;
plot(t, Hi, 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5);
for k = 1:length(transition_t)
    xline(transition_t(k), '--', 'Color', transition_colors{k}, 'LineWidth', 1.2);
end
legend('Low\_First\_Boolean', 'High\_First\_Boolean', 'Location', 'eastoutside');
ylabel('Boolean'); title('Synchronization Signals (mutual exclusivity check)'); grid on;

ax3 = subplot(3,1,3);
plot(t, Cyc, 'Color', [0 0.6 0], 'LineWidth', 1.5); hold on;
plot(t, Duty, 'Color', [0.85 0 0.85], 'LineWidth', 1.5);
plot(t, Trig, 'Color', [0.3 0.3 0.3], 'LineWidth', 1.5, 'LineStyle', ':');
% Stagger label vertical position for transitions that are close together
% (Duty change at 3.35 and Cycle_Time change at 3.70 would otherwise collide)
label_valign = {'top', 'bottom', 'bottom', 'bottom'};
for k = 1:length(transition_t)
    xline(transition_t(k), '--', transition_labels{k}, 'Color', transition_colors{k}, ...
        'LineWidth', 1.2, 'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', label_valign{k}, 'FontSize', 8);
end
legend('Cycle\_Time (cmd)', 'Duty\_Fraction (cmd)', 'Trigger', 'Location', 'eastoutside');
xlabel('Time (s)'); ylabel('Commanded value'); title('Schedule Inputs'); grid on;

linkaxes([ax1, ax2, ax3], 'x');
xlim(ax1, [0 12]);
