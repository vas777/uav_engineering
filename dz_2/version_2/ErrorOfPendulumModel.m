clc;
clear;
close all;

%% 1. Параметри системи
M = 0.5;       % маса вагончика, кг
m = 0.2;       % маса маятника, кг
b = 0.1;       % коефіцієнт в'язкого тертя, Н*с/м
l = 0.3;       % відстань від шарніра до центра мас, м
g = 9.81;      % прискорення вільного падіння, м/с^2

% Момент інерції однорідного стержня відносно центра мас
I = (1/3)*m*l^2;

%% 2. Початкові умови
phi0  = 0.01;  % phi(0), рад
dphi0 = 0;     % phi_dot(0), рад/с
x0    = 0;     % x(0), м
dx0   = 0;     % x_dot(0), м/с

%% 3. Час моделювання
% Через нестійкість перевернутого маятника беремо невеликий інтервал
tEnd = 1.0;
t = linspace(0, tEnd, 2000).';   % стовпець

%% 4. Характеристичний поліном аналітичного розв'язку
q = (M + m)*(I + m*l^2) - (m*l)^2;

polynomialCoefficients = [ ...
    q, ...
    b*(I + m*l^2), ...
    -(M + m)*m*g*l, ...
    -b*m*g*l ];

r = roots(polynomialCoefficients);

% Перевіряємо, що корені дійсні
if any(abs(imag(r)) > 1e-10)
    error('Характеристичне рівняння має комплексні корені.');
end

r = real(r);

% Впорядкування коренів
rPositive = r(r > 0);
rNegative = sort(r(r < 0));

r1 = rPositive(1);
r2 = rNegative(1);  % великий від'ємний корінь
r3 = rNegative(2);  % малий від'ємний корінь

fprintf('Характеристичні корені:\n');
fprintf('r0 = 0\n');
fprintf('r1 = %.10f\n', r1);
fprintf('r2 = %.10f\n', r2);
fprintf('r3 = %.10f\n', r3);

%% 5. Зв'язок амплітуд x(t) і phi(t)
A1 = ((I + m*l^2)*r1^2 - m*g*l)/(m*l*r1^2);
A2 = ((I + m*l^2)*r2^2 - m*g*l)/(m*l*r2^2);
A3 = ((I + m*l^2)*r3^2 - m*g*l)/(m*l*r3^2);

%% 6. Визначення сталих інтегрування
%
% phi(t) = C1*exp(r1*t) + C2*exp(r2*t) + C3*exp(r3*t)
%
% x(t) = C0 + A1*C1*exp(r1*t)
%            + A2*C2*exp(r2*t)
%            + A3*C3*exp(r3*t)

Kconstants = [ ...
    1,       1,       1,       0;
    r1,      r2,      r3,      0;
    A1,      A2,      A3,      1;
    A1*r1,   A2*r2,   A3*r3,   0 ];

initialConditions = [phi0; dphi0; x0; dx0];

constants = Kconstants \ initialConditions;

C1 = constants(1);
C2 = constants(2);
C3 = constants(3);
C0 = constants(4);

%% 7. Аналітичний розв'язок
phiAnalytical = ...
      C1*exp(r1*t) ...
    + C2*exp(r2*t) ...
    + C3*exp(r3*t);

xAnalytical = ...
      C0 ...
    + A1*C1*exp(r1*t) ...
    + A2*C2*exp(r2*t) ...
    + A3*C3*exp(r3*t);

%% 8. Модель CTMS у просторі станів
%
% Вектор стану CTMS:
%
% z = [x; x_dot; phi; phi_dot]

p = I*(M + m) + M*m*l^2;

Actms = [ ...
    0,  1,                         0,                      0;
    0, -(I + m*l^2)*b/p,          m^2*g*l^2/p,           0;
    0,  0,                         0,                      1;
    0, -m*l*b/p,                   m*g*l*(M + m)/p,       0 ];

Bctms = [ ...
    0;
    (I + m*l^2)/p;
    0;
    m*l/p ];

% Виходи:
% y(:,1) = x
% y(:,2) = phi
Cctms = [ ...
    1, 0, 0, 0;
    0, 0, 1, 0 ];

Dctms = [0; 0];

systemCTMS = ss(Actms, Bctms, Cctms, Dctms);

%% 9. Початкові умови для CTMS
% Порядок станів: [x; x_dot; phi; phi_dot]

z0ctms = [x0; dx0; phi0; dphi0];

% Вільний рух при u(t) = 0
[yCTMS, tCTMS, stateCTMS] = initial(systemCTMS, z0ctms, t);

xCTMS   = yCTMS(:,1);
phiCTMS = yCTMS(:,2);

% %% 10. Порівняння phi(t)
% figure;
% 
% plot(t, phiAnalytical, 'LineWidth', 1.6);
% hold on;
% plot(tCTMS, phiCTMS, '--', 'LineWidth', 1.4);
% 
% grid on;
% xlabel('t, с');
% ylabel('\phi(t), рад');
% 
% title({
%     'Порівняння аналітичного розв’язку та моделі CTMS'
%     sprintf('\\phi_0 = %.4f рад', phi0)
% });
% 
% legend( ...
%     'Аналітичний розв’язок', ...
%     'Модель CTMS', ...
%     'Location', 'best');

% %% 11. Порівняння x(t)
% figure;
% 
% plot(t, xAnalytical, 'LineWidth', 1.6);
% hold on;
% plot(tCTMS, xCTMS, '--', 'LineWidth', 1.4);
% 
% grid on;
% xlabel('t, с');
% ylabel('x(t), м');
% 
% title({
%     'Порівняння координати вагончика'
%     sprintf('\\phi_0 = %.4f рад', phi0)
% });
% 
% legend( ...
%     'Аналітичний розв’язок', ...
%     'Модель CTMS', ...
%     'Location', 'best');

%% 12. Обидві координати на одному рисунку
figure;

subplot(2,1,1);

plot(t, phiAnalytical, 'LineWidth', 5);
hold on;
plot(tCTMS, phiCTMS, '--', 'LineWidth', 1.5);

grid on;
ylabel('\phi(t), рад');
legend('Аналітичний', 'CTMS', 'Location', 'best');
title(sprintf('Порівняння моделей, \\phi_0 = %.4f рад', phi0));

subplot(2,1,2);

plot(t, xAnalytical, 'LineWidth', 5);
hold on;
plot(tCTMS, xCTMS, '--', 'LineWidth', 1.5);

grid on;
xlabel('t, с');
ylabel('x(t), м');
legend('Аналітичний', 'CTMS', 'Location', 'best');

%% 13. Похибки між моделями
phiError = phiAnalytical - phiCTMS;
xError   = xAnalytical - xCTMS;

figure;

subplot(2,1,1);
plot(t, phiError, 'LineWidth', 1.4);
grid on;
ylabel('\Delta\phi, рад');
title('Різниця між аналітичним розв’язком і CTMS');

subplot(2,1,2);
plot(t, xError, 'LineWidth', 1.4);
grid on;
xlabel('t, с');
ylabel('\Deltax, м');

%% 14. Числові показники збіжності
maxPhiError = max(abs(phiError));
maxXError   = max(abs(xError));

rmsPhiError = sqrt(mean(phiError.^2));
rmsXError   = sqrt(mean(xError.^2));

fprintf('\nПорівняння моделей:\n');
fprintf('Максимальна похибка phi = %.6e рад\n', maxPhiError);
fprintf('Середньоквадратична похибка phi = %.6e рад\n', rmsPhiError);
fprintf('Максимальна похибка x = %.6e м\n', maxXError);
fprintf('Середньоквадратична похибка x = %.6e м\n', rmsXError);