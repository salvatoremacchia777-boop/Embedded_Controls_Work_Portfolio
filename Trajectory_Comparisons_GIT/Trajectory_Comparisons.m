 % Cubic
tcubic = cubic_out.tout;
Cubic_Pos = cubic_out.logsout.getElement('Cubic_Pos').Values.Data;
Cubic_Vel = cubic_out.logsout.getElement('Cubic_Vel').Values.Data;


% Quintic
tquin = quintic_out.tout;
Quin_Pos = quintic_out.logsout.getElement('Quin_Pos').Values.Data;
Quin_Vel = quintic_out.logsout.getElement('Quin_Vel').Values.Data;
Quin_Accel = quintic_out.logsout.getElement('Quin_Accel').Values.Data;


% Septic
tseptic = septic_out.tout;
Septic_Pos = septic_out.logsout.getElement('Septic_Pos').Values.Data;
Septic_Vel = septic_out.logsout.getElement('Septic_Vel').Values.Data;
Septic_Accel = septic_out.logsout.getElement('Septic_Accel').Values.Data;
Septic_Jerk= septic_out.logsout.getElement('Septic_Jerk').Values.Data;

figure
plot(tcubic, Cubic_Pos,'b', tquin, Quin_Pos,'k', tseptic, Septic_Pos,'r')
grid('on')
xlabel('Time (seconds)')
ylabel('Position')
legend('3rd','5th','7th')
title('Position Comparison Trajectories')

figure
plot(tcubic, Cubic_Vel,'b', tquin, Quin_Vel,'k', tseptic, Septic_Vel,'r')
grid('on')
xlabel('Time (seconds)')
ylabel('Velocity')
legend('3rd','5th','7th')
title('Velocity Comparison Trajectories')

figure
plot(tquin, Quin_Accel,'k', tseptic, Septic_Accel,'r')
grid('on')
xlabel('Time (seconds)')
ylabel('Acceleration')
legend('5th','7th')
title('Acceleration Comparison Trajectories')
