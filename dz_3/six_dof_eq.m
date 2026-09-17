% 6 Degree of Freedom (6DOF) with Euler's angles

% symbolic notations
syms mass real
% inertia tensor variables
syms Ixx Iyy Izz Ixy Ixz Iyz real
syms u v w real
syms p q r real 
syms Fx Fy Fz real 
syms Mx My Mz real
syms phi theta psi real

% Velocity and Rate vectors
V_b = [u; v; w];
Omega = [p; q; r];
Forces = [Fx; Fy; Fz];
Moments = [Mx; My; Mz];

% Inertia tensor that assumes symmetry of the body
% as I12==I21, I13==I31, I23==I32
I = [Ixx, Ixy, Ixz; 
     Ixy, Iyy, Iyz; 
     Ixz, Iyz, Izz];

% 1. Accelerations
% from Second Newton's law
% F = m * V_dot
% Transport theorem
% Vector_inertial = Vector_local + Omega X Vector
% combining those gives us
% F = m * (V_dot + Omega x V_b)
% solve for V_dot
% V_dot = F/m - (Omega x V_b)
V_dot = (Forces / mass) - cross(Omega, V_b);
u_dot = V_dot(1);
v_dot = V_dot(2);
w_dot = V_dot(3);

% 2. Body rotations rates
% M = H_dot
% H_dot = I * Omega_dot - angular momentum
% and using Transport theorem
% Moments = I * Omega_dot + Omega x (I * Omega)
% solve for Omega_dot
% Omega_dot = inv(I) * (Moments - Omega x (I * Omega))
Omega_dot = inv(I) * (Moments - cross(Omega, I * Omega));
p_dot = Omega_dot(1);
q_dot = Omega_dot(2);
r_dot = Omega_dot(3);

% 3. Transformation of body rates to Euler angle rates
% Transform matrix for rotational rates
E = [ 1, 0,         -sin(theta);
    0, cos(phi),  sin(phi)*cos(theta);
    0, -sin(phi), cos(phi)*cos(theta)];

% Omega = E * Euler_rates
% therefore if E is inverted
Euler_rates = inv(E) * Omega;

% Earth-Relative Velocities
% The Direction Cosine Matrix (DCM) for standard Yaw-Pitch-Roll sequence
DCM = [cos(theta)*cos(psi), sin(phi)*sin(theta)*cos(psi) - cos(phi)*sin(psi), cos(phi)*sin(theta)*cos(psi) + sin(phi)*sin(psi);
    cos(theta)*sin(psi), sin(phi)*sin(theta)*sin(psi) + cos(phi)*cos(psi), cos(phi)*sin(theta)*sin(psi) - sin(phi)*cos(psi);
    -sin(theta),          sin(phi)*cos(theta),                              cos(phi)*cos(theta)];

% Transforms body velocity to velocity in Earth frame of reference
V_e = DCM * V_b;

% Earth speed after transformation
V_ex = V_e(1);
V_ey = V_e(2);
V_ez = V_e(3);

disp('--- Inverse of the Euler Transformation Matrix (Euler to Body Rates) ---');
pretty(simplify(inv(E)))

disp('--- Body-Frame X-Axis Translational Acceleration (u_dot) ---');
pretty(simplify(u_dot))

disp('--- Body-Frame Y-Axis Translational Acceleration (v_dot) ---');
pretty(simplify(v_dot))

disp('--- Body-Frame Z-Axis Translational Acceleration (w_dot) ---');
pretty(simplify(w_dot))

disp('--- Body-Frame X-Axis Rotational Acceleration (p_dot) ---');
pretty(simplify(p_dot))

disp('--- Body-Frame Y-Axis Rotational Acceleration (q_dot) ---');
pretty(simplify(q_dot))

disp('--- Body-Frame Z-Axis Rotational Acceleration (r_dot) ---');
pretty(simplify(r_dot))

disp('--- Earth-Frame Roll Rate (phi_dot) ---');
pretty(simplify(phi_dot))

disp('--- Earth-Frame Pitch Rate (theta_dot) ---');
pretty(simplify(theta_dot))

disp('--- Earth-Frame Yaw Rate (psi_dot) ---');
pretty(simplify(psi_dot))

disp('--- Earth-Relative X-Axis Velocity (misnamed V_ex_dot) ---');
pretty(simplify(V_ex_dot))

disp('--- Earth-Relative Y-Axis Velocity (misnamed V_ey_dot) ---');
pretty(simplify(V_ey_dot))

disp('--- Earth-Relative Z-Axis Velocity (misnamed V_ez_dot) ---');
pretty(simplify(V_ez_dot))
