% Define the symbolic variables
mass_quadrotor = 1.07;
g = 9.81;
lever = 0.124; % meters ; assumed form picture as half of rotor length

% The moment of inertia for the whole body
I = [ 0.0093, 0, 0;
      0, 0.0092, 0;
      0, 0, 0.0151
    ];

% thrust coefficient
b_thrust_coeff = 1.5108*10^(-5);

% inertia of the whole propeller is
Ip_inertia = 4.439*10^(-5);

% moment of inertia
Jl_mom_inertia = 4.927*10^(-6);
Jm_mom_inertia = 2.506*10^(-6);
%time constant 
taunp = 0.5;
% drag factor 
d_grag_factor = 4.406*10*(-7);
% ???
wm0 = 82*2*pi;

% TODO change me later ?
phi = deg2rad(30);
theta = deg2rad(30);
psi = deg2rad(30);

% Construct the 3x3 matrix Rx (Rotation around x-axis)
Rx = [
    1, 0, 0;
    0, cos(phi), sin(phi);
    0, -sin(phi), cos(phi)
    ];

% Construct the 3x3 matrix Ry (Rotation around y-axis)
Ry = [
    cos(theta), 0, -sin(theta);
    0, 1, 0;
    sin(theta), 0, cos(theta)
    ];

% Construct the 3x3 matrix Rz (Rotation around z-axis)
Rz = [
    cos(psi), sin(psi), 0;
    -sin(psi), cos(psi), 0;
    0, 0, 1
    ];

% Display the resulting matrices
% disp('Matrix Rx:');
% disp(Rx);
% 
% disp('Matrix Ry:');
% disp(Ry);
% 
% disp('Matrix Rz:');
% disp(Rz);

DCM = Rx*Ry*Rz;

