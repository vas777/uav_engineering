% =========================================================================
% Configuration Parameters
% =========================================================================
model_name = 'dz_3_simul_model.slx'; % Update this to your exact .slx filename
sim_time = 30;                % Total simulation time in seconds
switch_time = 4;              % Time when inputs change

% Define the time vector (0 to 30 seconds, 1-second increments)
t = (0:sim_time)'; 

% Define the steady-state variations for each run (after 4 seconds)
% Each row is a new simulation model: [u1, u2, u3, u4]
bv = 680;
variations = [
    % +X
    bv+10, bv, bv, bv;
    bv, bv, bv-10, bv;
    % -X
    bv, bv, bv+10, bv;
    bv-10, bv, bv, bv;
    % +Y
    bv, bv+10, bv, bv;
    bv, bv, bv, bv-10;
    % -Y
    bv, bv, bv, bv+10;
    bv, bv-10, bv, bv;
    % +Z
    bv, bv, bv, bv;
    % roll
    bv, bv+10, bv, bv-10;
    bv, bv-10, bv, bv+10;
    % pitch
    bv+10, bv, bv-10, bv;
    bv-10, bv, bv+10, bv;
    % yaw
    bv+10, bv, bv+10, bv;
    bv-10, bv, bv-10, bv;
];

num_runs = size(variations, 1);

% Load the system to ensure it is ready for batch processing
load_system(model_name);
run('dz_3_model.m');

% =========================================================================
% Batch Simulation and Plotting Loop
% =========================================================================
for i = 1:num_runs
    
    % 1. Construct the input data matrix for this specific run
    % Pre-allocate the data array (31 time steps x 4 variables)
    u_data = zeros(length(t), 4);
    
    % Apply initial conditions (680 for all inputs) for t <= 4
    init_indices = t <= switch_time;
    u_data(init_indices, :) = repmat([bv, bv, bv, bv], sum(init_indices), 1);
    
    % Apply the varying conditions for t > 4
    rest_indices = t > switch_time;
    u_data(rest_indices, :) = repmat(variations(i, :), sum(rest_indices), 1);
    
    % Combine time and data for the 'From Workspace' block: [time, u1, u2, u3, u4]
    simin = [t, u_data];
    
    % Push to base workspace so Simulink can read it
    assignin('base', 'simin', simin);
    
    % 2. Execute the Simulation
    % Overriding StopTime ensures it strictly runs for the defined 30 seconds
    try
        simOut = sim(model_name, 'StopTime', num2str(sim_time));
    catch ME
        fprintf('Simulation failed on run %d. Error: %s\n', i, ME.message);
        continue; % Skip to the next run if this one crashes
    end
    
% 3. Extract the Output Data
logged_vars = simOut.who; % Get list of all variables returned

if ismember('simout', logged_vars)
    % Extract the data using the object method
    sim_data = simOut.get('simout');
    sim_data_angle = simOut.get('simout_angle');
    
    
    % Handle different save formats (Timeseries vs Array)
    if isa(sim_data, 'timeseries')
        out_time = sim_data.Time;
        out_data = sim_data.Data;
    else
        out_time = simOut.tout;
        out_data = sim_data;
    end
    
    if isa(sim_data_angle, 'timeseries')
        out_tim_angle = sim_data_angle.Time;
        out_data_angle = sim_data_angle.Data;
    else
        out_time_angle = simOut.tout;
        out_data_angle = sim_data_angle;
    end

else
    % Print exactly what was returned so you can debug the name mismatch
    fprintf('Error: simout not found in run %d. Available variables: %s\n', i, strjoin(logged_vars, ', '));
    continue;
end
    
    % 4. Generate and Save the Figure Invisibly
    fig = figure('Visible', 'off', 'Color', [0.15 0.15 0.15]);
    
    % Initialize a 2-row by 3-column grid layout
    tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

    line_colors = {'r', 'g', 'm','#FFD700','#FFD700', '#FFD700'};
    line_styles = {'-', '-', '-','--',      '--',     '--'};
    
    % Loop through each of the 6 outputs and plot them in the grid
    for col = 1:6
        nexttile;
        
        % Ensure data indexing matches the Mux output structure
        if i <= 9 
            plot(out_time, out_data(:, col), ...
            'Color', line_colors{col}, ...
            'LineStyle', line_styles{col}, ...
            'LineWidth', 1.5);
        else
            plot(out_time_angle, out_data_angle(:, col), ...
                'Color', line_colors{col}, ...
                'LineStyle', line_styles{col}, ...
                'LineWidth', 1.5);
        end

        % Force axes background to black and all text/grid elements to white
        set(gca, 'Color', [0.1 0.1 0.1], ...
            'XColor', 'white', ...
            'YColor', 'white', ...
            'GridColor', 'white', ...
            'GridAlpha', 0.4);
        
        if     col == 1
            title(sprintf('Reference X'), 'Color', 'white');
        elseif col == 2
            title(sprintf('Reference Y'), 'Color', 'white');
        elseif col == 3
            title(sprintf('Reference Z'), 'Color', 'white');
        elseif col == 4
            title(sprintf('Custom X'), 'Color', 'white');
        elseif col == 5
            title(sprintf('Custom Y'), 'Color', 'white');
        elseif col == 6
            title(sprintf('Custom Z'), 'Color', 'white');
        end

        xlabel('Time (s)', 'Color', 'white');

        if     col == 1 || col == 4
            ylabel('X', 'Color', 'white');
        elseif col == 2 || col == 5
            ylabel('Y', 'Color', 'white');
        elseif col == 3 || col == 6
            ylabel('Z', 'Color', 'white');
        end

        grid on;
    end
    
    % Add a master title for the entire figure to identify the model run
    if     i == 1 || i == 2
        t_obj = sgtitle(sprintf('Simulation +X %s', num2str(variations(i, :))));
    elseif i == 3 || i == 4
        t_obj = sgtitle(sprintf('Simulation -X %s', num2str(variations(i, :))));
    elseif i == 5 || i == 6
        t_obj = sgtitle(sprintf('Simulation +Y %s', num2str(variations(i, :))));
    elseif i == 7 || i == 8
        t_obj = sgtitle(sprintf('Simulation -Y %s', num2str(variations(i, :))));
    elseif i == 9
        t_obj = sgtitle(sprintf('Simulation +Z %s', num2str(variations(i, :))));
    else
        t_obj = sgtitle(sprintf('Angles roll, pitch, yaw %s', num2str(variations(i, :))));
    end
    
    t_obj.Color = 'white';

    % Save and destroy the figure
    filename = sprintf('Simulation_Result_%d.png', i);
    exportgraphics(fig, filename, 'Resolution', 300);
    close(fig);
    
    fprintf('Completed simulation %d of %d. Saved %s\n', i, num_runs, filename);
end





% Clean up by closing the model
close_system(model_name, 0);