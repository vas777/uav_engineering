function [V_dot, Euler_rates] = drone_equations(V_b, Omega, Forces, Euler_angles, m)
    % V_b = [u; v; w]
    % Omega = [p; q; r]
    % Forces = [Fx; Fy; Fz]
    % Euler_angles = [phi; theta; psi]

    % Unpack angles for the H matrix
    phi = Euler_angles(1);
    theta = Euler_angles(2);
    % psi is unused in this transformation

    % 1. Translational Dynamics
    % V_dot = F/m - (Omega x V_b)
    V_dot = (Forces / m) - cross(Omega, V_b);

    % 2. Rotational Kinematics (H Matrix)
    H = [1, sin(phi)*tan(theta), cos(phi)*tan(theta);
         0, cos(phi),           -sin(phi);
         0, sin(phi)/cos(theta), cos(phi)/cos(theta)];
         
    Euler_rates = H * Omega;
end