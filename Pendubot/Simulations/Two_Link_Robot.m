%% Two-Link Robot Script
% Author:Salvatore Macchia
%% Prepare Command Window and Workspace
clear;
clc;
close('all');
%% Description of Physical System
% Link 1 is a slender rod which is connected to ground at Point O which
% is a revolute joint.
% Link 1's Center of Mass is at point C. 
% Link 1 and Link 2 are connected to one another at revolute joint A.
% The Length of Link 1 is from Point O to Point A.
%% Engineering Assumptions
% Link 1 and Link 2 are Rigid Bodies.
% Link 1 has fixed axis rotation about Point O.
% Link 2 has general plane motion.
% Only Planar Motion
% Two DOF System
% Both Link 1 and Link 2 are Slender Rods (I = 1/12*M*L^2)
% Uniform mass distribution
% 6061 Aluminum used for rods. (rho = 2700kg/m^3)
% McMaster Carr Part Number: 4634T41
% Link 1 and Link 2 are made of the same material (density is constant)
%% Two Link Robot Parameter Definition
rho_alum = 2700; % kg/m^3
L1 = .244; % Length of Link 1 (M)
D1 = 16e-3; % Diameter of Link 1 (M)
L2 = .366; % Length of Link 2 (M)
D2 = 16e-3; % Diameter of Link 2 (M)
Loc = L1/2; % Center of Mass Location Link 1 (M)
Lac = L2/2; % Center of Mass Location Link 2 (M)
VolL1 = pi*(D1/2)^2*L1; % Volume of Link 1 (M^3)
VolL2 = pi*(D2/2)^2*L2; % Volume of Link 2 (M^3)
M1 = rho_alum*VolL1; % Mass of Link 1 (kg)
M2 = rho_alum*VolL2; % Mass of Link 2 (kg)
I1 = (1/12)*(M1)*(L1^2); % Mass Moment of Inertia Link 1 (kg*M^2)
I2 = (1/12)*(M2)*(L2^2); % Mass Moment of Inertia Link 2 (kg*M^2)
Mp = 0; % Mass applied at the end point (Point B) of Link 2 (kg)
g = 9.81; % Gravitational Constant (M/sec^2)
Ts = 0.001; % Step Time
E_Target = (M1*g*Loc*sin(pi/2))+ (M2*g)*[Lac*sin(pi/2)+L1*sin(pi/2)];
%% Notation
% F_1x = Reaction Force at Revolute Joint O in X-direction (N)
% F_1y = Reaction Force at Revolute Joint O in Y-direction (N)
% F_12x = Reaction Force at Revolute Joint A in X-direction (N)
% F_12y = Reaction Force at Revolute Joint A in Y-direction (N)
% Loa = Link 1 Length (M)
% Tm1 = Motor Torque applied to Link 1 at Revolute Joint O (N-M)
% Tm2 = Motor Torque applied to Link 2 at Revolute Joint A (N-M)
% T_FFO = Rotational Friction at Revolute Joint O (N-M)
% T_FFA = Rotational Friction at Revolute Joint A (N-M)
% Theta1 = Angle Link 1 makes with horizontal ground x-axis (rad)
% Theta1_dot = Angular Velocity Link 1 (rad/s)
% Theta1_ddot = Angular Acceleration of Link 1 (rad/s^2)
% Beta = Relative Angle Link 2 makes with Link 1 (rad)
% Beta_dot = Relative angular velocity Link 2 makes with Link 1 (rad/s)
% Beta_ddot = Relative ang acceleration Link 2 makes with Link 1 (rad/s^2)
% Theta2 = Absolute Angle Link 2 makes with Ground (rad)
% Theta2_dot = Absolute angular velocity Link 2 makes with ground (rad/s)
% Theta2_ddot = Abs ang acceleration Link 2 makes with ground (rad/s^2)
% Theta2 = Theta1+Beta;
% F_dx = Dist Force Applied at End Point B on Link 2 X-Dir (N)
% F_dy = Dist Force Applied at End Point B on Link 2 y-Dir (N)

% %% Calculation Simplifications
% S1 = sin(Theta1);
% C1 = cos(Theta1);
% Theta2 = Theta1+Beta;
% S2 = sin(Theta2);
% C2 = cos(Theta2);
% S3 = sin(Beta);
% C3 = cos(Beta);
% Theta1_dot_sq = Theta1_dot*Theta1_dot;
% Theta2_dot_sq = (Theta1_dot+Beta_dot)*(Theta1_dot+Beta_dot);
%% X-Matrix-Setup
% X = zeros(6,1);
% X(1) = F_1x;
% X(2) = F_12x;
% X(3) = F_1y;
% X(4) = F_12y;
% X(5) = Theta1_ddot;
% X(6) = Beta_ddot;
% %% Setting Up the Forward Newton Euler Matrix
% A = zeros(6,6); % Define a Zero matrix of 6x6 size
% B = zeros(6,1); % Define a Zero Vector
% % Indexing Row 1 Of A which is Equation 1.
% % F_1x + F_12x + (M1*Loc*sin(Theta1))*Theta1_ddot 
% % Cleaned up Equation
% % F_1x + F_12x + (M1*Loc*S1)*Theta1_ddot
% A(1,1) = 1; 
% A(1,2) = 1;
% A(1,3) = 0;
% A(1,4) = 0;
% A(1,5) = (M1*Loc*S1);
% A(1,6) = 0;
% 
% % Indexing Row 2 Of A which is Equation 2.
% % -F_1y + F_12y -(M1*Loc*cos(Theta1))*Theta1_ddot 
% % Cleaned up Equation
% % -F_1y + F_12y -(M1*Loc*C1)*Theta1_ddot 
% A(2,1) = 0; 
% A(2,2) = 0;
% A(2,3) = -1;
% A(2,4) = 1;
% A(2,5) = -(M1*Loc*C1);
% A(2,6) = 0;
% 
% % Indexing Row 3 Of A which is Equation 3.
% % - L1*sin(Theta1)*F_12x + L1*cos(Theta1)*F_12y - (I1+(M1*(Loc^2)))*Theta1_ddot
% % Cleaned up Equation
% % -(L1*S1)*F_12x +(L1*C1)*F_12y -(I1+(M1*(Loc*Loc)))*Theta1_ddot
% A(3,1) = 0; 
% A(3,2) = -(L1*S1);
% A(3,3) = 0;
% A(3,4) = (L1*C1);
% A(3,5) = -(I1+(M1*(Loc*Loc)));
% A(3,6) = 0;
% 
% % Indexing Row 4 Of A which is Equation 4.
% % -F_12x + M2*((L1*sin(Theta1))+(Lac*sin(Beta+Theta1)))*Theta1_ddot +
% % (M2*Lac*sin(Beta+Theta1))*Beta_ddot
% % Cleaned up Equation
% % -F_12x + M2*((L1*S1)+(Lac*S2))*Theta1_ddot + (M2*Lac*S2)*Beta_ddot
% A(4,1) = 0; 
% A(4,2) = -1;
% A(4,3) = 0;
% A(4,4) = 0;
% A(4,5) = M2*((L1*S1)+(Lac*S2));
% A(4,6) = (M2*Lac*S2);
% 
% % Indexing Row 5 Of A which is Equation 5.
% % -F_12y - M2*((L1*cos(Theta1))+(Lac*cos(Beta+Theta1)))*Theta1_ddot -
% % (M2*Lac*cos(Beta+Theta1))*Beta_ddot
% % Cleaned up Equation
% % -F_12y - M2*((L1*C1)+(Lac*C2))*Theta1_ddot -(M2*Lac*C2)*Beta_ddot
% A(5,1) = 0; 
% A(5,2) = 0;
% A(5,3) = 0;
% A(5,4) = -1;
% A(5,5) = - M2*((L1*C1)+(Lac*C2));
% A(5,6) = -(M2*Lac*C2);
% 
% % Indexing Row 6 Of A which is Equation 6.
% % (I2+((M2*Lac)*(L1*cos(Beta)+Lac)))*Theta1_ddot + ((M2*Lac^2)+I2)*Beta_ddot
% % Cleaned Up Equation
% % (I2+((M2*Lac)*(L1*C3+Lac)))*Theta1_ddot + ((M2*Lac*Lac)+I2)*Beta_ddot
% A(6,1) = 0; 
% A(6,2) = 0;
% A(6,3) = 0;
% A(6,4) = 0;
% A(6,5) = (I2+((M2*Lac)*(L1*C3+Lac)));
% A(6,6) = ((M2*Lac*Lac)+I2);
% 
% % Setting Up the B Matrix
% 
% % Indexing Row 1 of B which is RHS of EQ1
% % -(M1*Loc*cos(Theta1)*(Theta1_dot^2))
% % Cleaned Up Equation
% % -(M1*Loc*C1*(Theta1_dot*Theta1_dot))
% % -(M1*Loc*C1*Theta1_dot_sq)
% B(1) = -(M1*Loc*C1*Theta1_dot_sq);
% 
% % Indexing Row 2 of B which is RHS of EQ2
% % -(M1*Loc*sin(Theta1)*(Theta1_dot^2))+(M1*g)
% % Cleaned Up Equation
% % -(M1*Loc*S1*(Theta1_dot*Theta1_dot))+(M1*g)
% % -(M1*Loc*S1*(Theta1_dot_sq))+(M1*g)
% B(2) = -(M1*Loc*S1*(Theta1_dot_sq))+(M1*g);
% 
% % Indexing Row 3 of B which is RHS of EQ3
% % -Tm1+T_FFO-T_FFA+(Loc*M1*g*cos(Theta1))-Tm2
% % Cleaned Up Equation
% % -Tm1+T_FFO-T_FFA+(Loc*M1*g*C1)-Tm2
% B(3) = -Tm1+T_FFO-T_FFA+(Loc*M1*g*C1)-Tm2;
% 
% % Indexing Row 4 of B which is RHS of EQ4
% % - (M2*L1*cos(Theta1)*(Theta1_dot^2)) - M2*Lac*cos(Beta+Theta1)*(Beta_dot+Theta1_dot)^2 - F_dx
% % Cleaned Up Equation
% % -(M2*L1*C1*(Theta1_dot*Theta1_dot)) - (M2* Lac*C2*(Beta_dot+Theta1_dot)*(Beta_dot+Theta1_dot)) - F_dx
% % -(M2*L1*C1*(Theta1_dot_sq)) - (M2*Lac*C2*Theta2_dot_sq) - F_dx
% B(4) = -(M2*L1*C1*(Theta1_dot_sq)) - (M2*Lac*C2*Theta2_dot_sq) - F_dx;
% 
% % Indexing Row 5 of B which is RHS of EQ5
% % -(M2*L1*sin(Theta1)*(Theta1_dot^2)) - M2*Lac*sin(Beta+Theta1)*(Beta_dot+Theta1_dot)^2 + g*(M2+Mp) + F_dy
% % Cleaned Up Equation
% % -(M2*L1*S1*(Theta1_dot*Theta1_dot)) - (M2*Lac*S2*(Beta_dot+Theta1_dot)*(Beta_dot+Theta1_dot)) + g*(M2+Mp) + F_dy
% % -(M2*L1*S1*(Theta1_dot_sq)) - (M2*Lac*S2*Theta2_dot_sq) + g*(M2+Mp) + F_dy
% B(5) = -(M2*L1*S1*(Theta1_dot_sq)) - (M2*Lac*S2*Theta2_dot_sq) + g*(M2+Mp) + F_dy;
% 
% % Indexing Row 6 of B which is RHS of EQ6
% % Tm2 - T_FFA - cos(Beta+Theta1)*((Lac*M2*g)+(L2*(Mp*g+F_dy))-(L2*sin(Beta+Theta1)*F_dx)-(M2*Lac*L1*sin(Beta)*(Theta1_dot^2))
% % Cleaned Up Equation
% % Tm2 - T_FFA - C2*((Lac*M2*g)+(L2*(Mp*g+F_dy)))-(L2*S2*F_dx) -(M2*Lac*L1*S3*(Theta1_dot*Theta1_dot))
% % Tm2 - T_FFA - C2*((Lac*M2*g)+(L2*(Mp*g+F_dy)))-(L2*S2*F_dx) -(M2*Lac*L1*S3*(Theta1_dot_sq))
% B(6) = Tm2 - T_FFA - C2*((Lac*M2*g)+(L2*(Mp*g+F_dy)))-(L2*S2*F_dx) -(M2*Lac*L1*S3*(Theta1_dot_sq));
% 
% 
