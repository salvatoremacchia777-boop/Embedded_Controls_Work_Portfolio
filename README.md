This portfolio is a way for technical recruiters, engineers, and anyone curious to review my Simulink and embedded controls work. 
Each project includes the design itself, an explanation of how it works, and a verification test proving it behaves as intended.
This is a work in progress, started August 3, 2026.

Currently included:
Timing Synchronizer — a self-resetting periodic timing block with runtime-tunable cycle time and duty cycle, verified against 5 explicit behavioral requirements.
More projects will be added as they're completed and verified.

Fifth Order Polynomial Trajectory - Creates a quintic, quartic, and cubic profile based on 6 Boundary Conditions. Used in motion planning, tracking control,
this code is optimized for embedded processors (low math overhead + closed form coefficient solutions + can regenerate a trajectory based on a saturation event)

Pendubot -- Newton-Euler Derivation with reaction forces to aid mechanical design. Multibody dynamics. Derivation notes, dynamic simulation, and read me for documentation.
