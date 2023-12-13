% trying a U version of the code for project 2

%% set some parameters
dt = 5e-2; % change in time
steps = 200; % how many steps to do
filename = 'kak-soliton.gif'; % the animation filename

SPIKE = 0; % make a spike (really, gaussian soliton)
SOLI1 = 1; % try to make a soliton (kink-antikink)
SOLI2 = 0; % try to make a sine
SOLI3 = 0; % breather?
FIX = 0; % fix sources

% dont edit below here
%% prework

% delete or itll append the old one
delete(filename);

% read and simplify the mesh
[V,T] = icosphere(4);

% we need an initial condition array the length of V
% lets just do random, for now
%unow = rand(size(V,1),1); % buncha random noise
unow = zeros(size(V,1),1); % just the spike below

if SPIKE
    % Create a Spike
    spike = 100; % value at the spike
    nearspike = 70; % value around the spike
    % apply the spike, just put it at 1
    unow(1) = spike;
    % any(T==1,2) gives us a boolean of which triangles contain vertex 1 (row numbers)
    % so, we index T by this boolean array to get the connected verteces.
    conn = T(any(T == 1, 2), :);
    % drop 1 (it was already set to spike above)
    % and turn our list into just an array of things to set to nearspike
    conn(conn == 1) = [];
    % now, set all these to nearspike
    unow(conn) = nearspike;
end

if SOLI1
    % Kink-antikink initial condition
    kink_position = -2; % Position of the kink
    antikink_position = 2; % Position of the antikink
    unow = 4 * atan(exp(V(:,1) - kink_position)) - 4 * atan(exp(-V(:,1) + antikink_position));
end

if SOLI2
    % Sinusoidal initial condition
    frequency = 2 * pi; % Frequency of the sine wave
    unow = 2* sin(frequency * V(:,1));
end


% Create the Stiffness and mass matrices
[S,M] = FEMMS(T,V);
S = -S; % someday ill move this to femms :)

% Initialize a figure for plotting
figure;

% Set up the plot with fixed color axis
h = trisurf(T, V(:, 1), V(:, 2), V(:, 3), unow, 'EdgeColor', 'none');
%colormap(hot);
colormap(parula);
%colorbar; % Show a color bar
clim([-1, 1]); % Fix the color axis to [0, 1] as the initial condition is normalized

axis equal; 
axis off; % Turn off the axis with numbers
camlight headlight; 
lighting gouraud; 
title('"Spike" Type Soliton');
grid off; % Ensure grid is turned off

%% Actually run

% we need a second step, lets make it here
uold = unow;

for step = 1:steps

    % implement method here
    unext = (M - dt^2 * S) \ (2*M*unow - M*uold - dt^2*M*sin(unow));


    % Update the plot data
    set(h, 'CData', unext);
    drawnow; % Update the plot
    frame = getframe(gcf); % Capture the figure's current state
    im = frame2im(frame); % Convert the frame to an image
    [imind, cm] = rgb2ind(im, 256); % Convert to indexed image

    % Write each frame to the GIF
    if step == 1
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
    else
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    end

    uold = unow;
    unow = unext;

end

