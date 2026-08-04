# Timing Synchronizer

## https://github.com/salvatoremacchia777-boop/Embedded_Controls_Work_Portfolio
A modular Simulink block for coordinating periodic, out-of-phase events on a shared, resettable, pausable schedule — without a dedicated hardware timer.
 
## Overview
 
Many control and test applications need two behaviors to alternate on a repeating schedule — sampling vs. settling, extend vs. retract, active vs. cooldown — while staying synchronized to a single shared time base. This block provides that: a resettable timer plus a complementary boolean output pair, both derived from externally-configurable `Cycle_Time` and `Duty_Fraction` inputs, with a `Trigger` input that allows the whole schedule to be paused and resumed without corrupting timing already in progress.
 
## Applications
 
**Hydraulic actuator life-cycle testing.** A common reliability test runs a cylinder through repeated extend/retract cycles to validate seal life and cycle-count ratings before a product ships. This block maps directly onto that setup: `Low_First_Boolean`/`High_First_Boolean` command the extend and retract solenoids on a directional control valve, `Duty_Fraction` sets an asymmetric dwell (e.g. a longer loaded extend stroke, a shorter unloaded retract), `Cycle_Time` sets the test rate, and `Trigger` allows the test to be paused mid-run — for an inspection, an out-of-spec reading, or an e-stop — and resumed later without corrupting the schedule already in progress.
 
**Other applicable use cases:**
- Motor intermittent-duty scheduling (e.g. IEC S3-style run/rest cycling to stay within thermal limits)
- Lead/lag alternation between two redundant actuators or pumps, to balance runtime and wear
- Any two-phase repeating process — sampling vs. settling, active vs. cooldown — that needs to run on a shared, resettable, pausable schedule without a dedicated hardware timer
## Implementation
 
### Inputs / Outputs
 
**Inputs:**
- `Cycle_Time` — duration of one complete periodic cycle (should be a multiple of `Step_Time`)
- `Step_Time` — solver/algorithm timestep
- `Duty_Fraction` — a value between 0–1 setting the split between the two synchronization signals (`X% high, (1-X)% low`, where `X = Duty_Fraction × Cycle_Time`)
- `Trigger` — boolean signal that permits the block's logic to run
**Outputs:**
- `Synchronization_Signals` — two mutually-exclusive booleans:
  1. High for `Duty_Fraction × Cycle_Time`
  2. Low for `(1 - Duty_Fraction) × Cycle_Time`
- `Time` — resettable counter
### Internal Logic
 
**Resettable timer (discrete accumulator):**
 
$$Counter(t) = In(t) + In(t-1), \qquad Time = Counter \times Step\_Time$$
 
`In(t-1)` is a unit delay with an initial condition of 0. The accumulator resets (holds at its initial condition) whenever:
- **Condition 1:** `Trigger` is not true, **or**
- **Condition 2:** `Time ≥ Cycle_Time`
**Design note — reset timing correction.** Because the reset condition passes through a one-sample delay (required to avoid an algebraic loop — the reset signal would otherwise depend on the same accumulator output it resets), the accumulator does not see its own reset condition until one step late. This is corrected by comparing against `Cycle_Time − Step_Time` rather than `Cycle_Time` directly, so the timer's actual period matches the commanded `Cycle_Time` exactly rather than overshooting by one sample every cycle.
 
**Generating the synchronization signals:**
 
$$Desired\_On\_Time = Cycle\_Time \times Duty\_Fraction$$
$$Desired\_Adjusted\_Time = Desired\_On\_Time - Step\_Time \quad \text{(removes the one-sample delay from the discrete accumulator)}$$
 
The on/off booleans are then formed by comparing `Time` against this adjusted threshold, muxed into a single vector `[On_Signal; Off_Signal]`. A final switching stage forces both outputs to 0 whenever `Trigger ≤ 0.5`, so the synchronization signals are only ever active while the block is actually enabled.
 
**Design note — live parameter updates.** `Cycle_Time` and `Duty_Fraction` are sampled and held (not read continuously) whenever `Current_Time < Previous_Time` (a cycle wraparound) **or** `Current_Trigger > Previous_Trigger` (a fresh rising edge). Both conditions feed a single enabled subsystem that grabs and holds the raw inputs until the next such event; the held values (`Used_Cycle_Time`, `Used_Duty_Fraction`) are what the rest of the block actually uses internally. This guarantees that a live change to either parameter takes effect only at a clean cycle boundary — never mid-cycle — preventing the timing discontinuity that would otherwise result from reading a changing input directly. Latching on both conditions (rather than wraparound alone) also means the block never needs a separate "first cycle" special case: on `Trigger`'s very first rising edge, the same latch mechanism immediately captures the correct starting values.
 
### Block Diagrams
 
![Top Level Block Diagram](Timing_Synchronizer_Top_Level_Block_Diagram.png)
*Figure 1: Block exterior — inputs and outputs.*
 
![Block Diagram](Timing_Synchronizer_Block_Diagram.jpg)
*Figure 2: Internal logic, corresponding to the description above.*
 
## Verification & Validation
 
The block was tested against five requirements:
 
1. `Time` resets exactly every `Cycle_Time` seconds (steady state)
2. A live `Cycle_Time` change takes effect only at the next reset boundary, not immediately
3. A live `Duty_Fraction` change takes effect only at the next reset boundary, not immediately
4. After a `Trigger` drop and re-rise, the block re-latches correctly (no stale values carried over from before the drop)
5. `Low_First_Boolean` and `High_First_Boolean` are always mutually exclusive while `Trigger` is high, and both are 0 while `Trigger` is low
**Methodology.** Verification is done "black box" — only top-level, externally observable signals are used (`Time`, `Cycle_Time`, `Duty_Fraction`, `Trigger`, `Low_First_Boolean`, `High_First_Boolean`). No internal block signals are referenced, so this proves correct behavior the same way any user of the block would observe it, rather than relying on knowledge of the internal implementation.
 
**Note on the expected on-fraction formula (requirements 3 and 4).** `Time` is a discrete counter, so any `Time ≥ Threshold` comparison resolves one sample late — the counter can only cross a threshold at its next scheduled increment, never exactly on it. The block corrects for this by subtracting one `Step_Time` from the on/off-duration threshold, so the expected on-time is `(Duty_Fraction × Cycle_Time) − Step_Time`, not the raw product — the same one-sample correction described in the reset-timing design note above, applied here to the duty-cycle threshold instead of the period threshold.
 
![Verification Results](Timing_Synchronizer_Results.jpg)
*Figure 3: Simulation results across a schedule exercising all five requirements, including live `Cycle_Time`/`Duty_Fraction` changes and a `Trigger` drop/re-rise.*
 
## Conclusion
 
This block provides a lightweight, hardware-timer-free way to coordinate two out-of-phase periodic behaviors on a shared, pausable schedule, with two verified correctness guarantees that are easy to get subtly wrong in a naive implementation: live parameter changes never corrupt an in-progress cycle, and one-sample discretization effects (both in the reset timing and the duty-cycle threshold) are explicitly corrected rather than left as unaccounted-for drift.
 
## Files
 
1. `Timing_Synchronizer.slx` — library-style subsystem block, all inputs/outputs external
2. `Timing_Synchronizer_Test_Harness.slx` — used to test against the five requirements above
3. `Timing_Synchronizer_Schedule.m` — defines test harness parameters
4. `Timing_Synchronizer_Verification.m` — runs the test harness and presents results
5. `Timing_Synchronizer_Results.jpg` — verification results plot
6. `Timing_Synchronizer_README.md`
7. `Timing_Synchronizer.c`
8. `Timing_Synchronizer.h`
9. `Timing_Synchronizer_Block_Diagram.jpg`
10. `Timing_Synchronizer_Top_Level_Block_Diagram.jpg`