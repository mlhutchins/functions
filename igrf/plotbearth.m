% PLOTBEARTH Plot the Earth's magnetic field lines using the IGRF.
% 
% Plots a globe and a number of magnetic field lines starting at each point
% specified by the vectors in lat_start and lon_start. Both distance and
% nsteps should be the same length as lat_start. The plot will spin if spin
% is true and will continue to spin until the user hits CTRL+C.
% 
% If the user does not have the Mapping Toolbox, a primitive globe
% consisting just of latitude and longitude lines is drawn with the equator
% and prime meridian thicker lines.

clear;
close all;

font = 'Times New Roman';
axis_font = 12;
title_font = 12;

time = datenum([2007 7 17 6 30 0]);
lat_start = 30:15:60; % Geodetic latitudes in degrees.
lon_start = 0:30:330; % Geodetic longitudes in degrees.
alt_start = 0; % Altitude in km.
distance = -sign(lat_start).*[30e3 70e3 150e3]; % km.
nsteps = abs(distance)/10;
spin = false;

% Get the magnetic field line points.
lat = zeros(max(nsteps(:))+1, numel(lat_start)*numel(lon_start));
lon = zeros(max(nsteps(:))+1, numel(lat_start)*numel(lon_start));
alt = zeros(max(nsteps(:))+1, numel(lat_start)*numel(lon_start));
for index1 = 1:numel(lat_start)
    for index2 = 1:numel(lon_start)
        [lat(1:nsteps(index1)+1, ...
            index1*(numel(lon_start)-1)+index2) lon(1:nsteps(index1)+1, ...
            index1*(numel(lon_start)-1)+index2) alt(1:nsteps(index1)+1, ...
            index1*(numel(lon_start)-1)+index2)] = ...
            igrfline(time, lat_start(index1), lon_start(index2), ...
            alt_start, 'geod', distance(index1), nsteps(index1));
    end
end

% Plot the magnetic field lines.
figure;
hold on;

% If the mapping toolbox is not available, just plot an ellipsoid with
% latitude and longitude lines.
if ~license('test', 'MAP_Toolbox')
    
    % WGS84 parameters.
    a = 6378.137; f = 1/298.257223563;
    b = a*(1 - f); e2 = 1 - (b/a)^2; ep2 = (a/b)^2 - 1;
    
    % Latitude lines of the ellipsoid to plot.
    latitudelines = -90:30:90;
    phi = (0:1:360)*pi/180;
    [LATLINES, PHI] = meshgrid(latitudelines*pi/180, phi);
    RLATLINES = sqrt(2)*a*b./sqrt((b^2 - a^2)*cos(2*LATLINES) + a^2 + b^2);
    [xlat, ylat, zlat] = sph2cart(PHI, LATLINES, RLATLINES);
    requator = sqrt(2)*a*b./sqrt((b^2 - a^2)*ones(size(phi)) + a^2 + b^2);
    [xeq, yeq, zeq] = sph2cart(phi, 0, requator);
    
    % Longitude lines of the ellipsoid to plot.
    longitudelines = 0:30:360;
    theta = (-90:1:90)*pi/180;
    [LONLINES, THETA] = meshgrid(longitudelines*pi/180, theta);
    RLONLINES = sqrt(2)*a*b./sqrt((b^2 - a^2)*cos(2*THETA) + a^2 + b^2);
    [xlon, ylon, zlon] = sph2cart(LONLINES, THETA, RLONLINES);
    rprime = sqrt(2)*a*b./sqrt((b^2 - a^2)*cos(2*theta) + a^2 + b^2);
    [xpm, ypm, zpm] = sph2cart(0, theta, rprime);

    % % If you had a vector of coast lines like coast in the Mapping
    % % toolbox, you could plot that too.
    % c = load('coast');
    % tcoast = c.lat*pi/180;
    % phicoast = c.long*pi/180;
    % rcoast = sqrt(2)*a*b./sqrt((b^2 - a^2)*cos(2*tcoast) + a^2 + b^2);
    % [xcoast, ycoast, zcoast] = sph2cart(phicoast, tcoast, rcoast);
    % plot3(xcoast, ycoast, zcoast, 'Color', [0 0.5 0]);
    
    % Convert lla to xyz.
    Nphi = a ./ sqrt(1 - e2*sin(lat*pi/180).^2);
    x = (Nphi + alt).*cos(lat*pi/180).*cos(lon*pi/180);
    y = (Nphi + alt).*cos(lat*pi/180).*sin(lon*pi/180);
    z = (Nphi.*(1 - e2) + alt).*sin(lat*pi/180);
    
    % Make the plots.
    plot3(x, y, z, 'r');
    plot3(xlat, ylat, zlat, 'b');
    plot3(xeq, yeq, zeq, 'b', 'LineWidth', 5);
    plot3(xlon, ylon, zlon, 'b');
    plot3(xpm, ypm, zpm, 'b', 'LineWidth', 5);
    
else
    
    % Just plot a globe.
    load topo;
    axesm('globe', 'Geoid', 6371.2)
    meshm(topo, topolegend); demcmap(topo);
    plot3m(lat, lon, alt, 'r');
    
end

% Set the plot background to black.
set(gcf, 'color', 'k');
axis off;
title(['Magnetic Field Lines at ' datestr(time)], 'FontName', font, ...
    'FontSize', title_font, 'Color', 'w');

% Spin the plot indefinitely.
if spin
    index = 0;
    while true
        view(mod(index, 360), 23.5); % Earth's axis tilts by 23.5 degrees
        drawnow;
        pause(0.1);
        index = index - 5;
    end
end