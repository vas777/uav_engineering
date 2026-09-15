clc;
clear;
close all;

%% Параметри системи
M = 0.5;       % маса вагончика, кг
m = 0.2;       % маса маятника, кг
b = 0.1;       % коефіцієнт в'язкого тертя, Н*с/м
l = 0.3;       % відстань від шарніра до центра мас, м
g = 9.81;      % прискорення вільного падіння, м/с^2

% Момент інерції однорідного стержня відносно центра мас
I = (1/3)*m*l^2;

fprintf('I = %.6f кг*м^2\n', I);

%% Коефіцієнт q
q = (M + m)*(I + m*l^2) - (m*l)^2;

fprintf('q = %.6f\n', q);

%% Характеристичне рівняння
%
% r * [q*r^3 + b*(I+m*l^2)*r^2 ...
%      - (M+m)*m*g*l*r - b*m*g*l] = 0
%
% Один корінь:
% r0 = 0
%
% Інші три корені знаходяться з кубічного рівняння

a3 = q;
a2 = b*(I + m*l^2);
a1 = -(M + m)*m*g*l;
a0 = -b*m*g*l;

coeff = [a3, a2, a1, a0];

fprintf('\nКубічне рівняння:\n');
fprintf('%.6f*r^3 + %.6f*r^2 + %.6f*r + %.6f = 0\n', ...
        a3, a2, a1, a0);

%% Знаходження коренів
rNonzero = roots(coeff);
rAll = [0; rNonzero];

fprintf('\nКорені повної системи:\n');
for k = 1:length(rAll)
    fprintf('r%d = %.10f %+.10fi\n', ...
        k-1, real(rAll(k)), imag(rAll(k)));
end
r1 = rAll(2);
r2 = rAll(3);   
r3 = rAll(4);

%% Початкові умови
%
% Якщо всі початкові умови нульові та u(t)=0,
% тоді phi(t)=0 і x(t)=0.
%
% Для демонстрації задаємо мале початкове відхилення.

phi0  = 0.05;     % phi(0), рад
dphi0 = 0;        % dphi/dt при t=0, рад/с
x0    = 0;        % x(0), м
dx0   = 0;        % dx/dt при t=0, м/с

%% Коефіцієнти зв'язку між x(t) та phi(t)
%
% X_k = A_k * Phi_k
%
% A_k = ((I+m*l^2)*r_k^2 - m*g*l)/(m*l*r_k^2)

A1 = ((I + m*l^2)*r1^2 - m*g*l)/(m*l*r1^2);
A2 = ((I + m*l^2)*r2^2 - m*g*l)/(m*l*r2^2);
A3 = ((I + m*l^2)*r3^2 - m*g*l)/(m*l*r3^2);

fprintf('\nКоефіцієнти A_k:\n');
fprintf('A1 = %.10f\n', A1);
fprintf('A2 = %.10f\n', A2);
fprintf('A3 = %.10f\n', A3);

%% Аналітичні розв'язки
%
% phi(t) = C1*exp(r1*t) + C2*exp(r2*t) + C3*exp(r3*t)
%
% x(t) = C0 ...
%      + A1*C1*exp(r1*t)
%      + A2*C2*exp(r2*t)
%      + A3*C3*exp(r3*t)

%% Система рівнянь для C1, C2, C3, C0
K = [ ...
    1,       1,       1,       0;
    r1,      r2,      r3,      0;
    A1,      A2,      A3,      1;
    A1*r1,   A2*r2,   A3*r3,   0 ];

initialConditions = [phi0; dphi0; x0; dx0];

if rcond(K) < 1e-12
    error('Матриця для визначення сталих близька до виродженої.');
end

C = K \ initialConditions;

C1 = C(1);
C2 = C(2);
C3 = C(3);
C0 = C(4);

fprintf('\nСталі інтегрування:\n');
fprintf('C1 = %.12g\n', C1);
fprintf('C2 = %.12g\n', C2);
fprintf('C3 = %.12g\n', C3);
fprintf('C0 = %.12g\n', C0);

%% Часова сітка
tEnd = 1.0;
t = linspace(0, tEnd, 2000);

%% Обчислення phi(t)
phi = C1*exp(r1*t) ...
    + C2*exp(r2*t) ...
    + C3*exp(r3*t);

%% Обчислення x(t)
x = C0 ...
  + A1*C1*exp(r1*t) ...
  + A2*C2*exp(r2*t) ...
  + A3*C3*exp(r3*t);

%% Швидкості
dphi = r1*C1*exp(r1*t) ...
     + r2*C2*exp(r2*t) ...
     + r3*C3*exp(r3*t);

dx = A1*r1*C1*exp(r1*t) ...
   + A2*r2*C2*exp(r2*t) ...
   + A3*r3*C3*exp(r3*t);

%% Обидві залежності на одному рисунку
figure;

yyaxis left;
plot(t, phi, 'LineWidth', 1.5);
ylabel('\phi(t), рад');

yyaxis right;
plot(t, x, 'LineWidth', 1.5);
ylabel('x(t), м');

grid on;
xlabel('t, с');
%title('Залежності \phi(t) та x(t) від часу');
title({
    'Залежності \phi(t) та x(t) від часу'
    sprintf('\\phi_0 = %.4f рад', phi0)
});
legend('\phi(t)', 'x(t)', 'Location', 'best');
