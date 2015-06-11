%% Human Motion Analysis using Inertial Sensors

% (!) Requires custom (beta) hardware and firmware.
% (!) Processes an abridged form of data.

%% Resources

% Electronic Hardware
% Bill of Materials (https://github.com/anirudh-ramesh/Human-Motion-Analysis/blob/master/Bill_of_Materials.xlsx)
% (!) BETA

% Firmware
% (https://github.com/anirudh-ramesh/Human-Motion-Analysis/blob/master/Arduino_MPU6050.ino)
% (!) BETA

%% Data Acquisition (BETA)

% Hardware must be configured to transmit 9600 bits/second, with 8 data
% bits for every stop bit.

% Hardware must transmit raw data in the following format:
%   AX
%   AY
%   AZ
%   GX
%   GY
%   GZ
%
% AX, AY and AZ - 12 bits, 2's complement notation
% Acceleration along X, Y and Z directions
%
% GX, GY and GZ - 12 bits
% Rotation along X, Y and Z directions

% Flush Workspace
clear;

% Flush Command Window
clc;

% Flush Figure
clf;

% Configure virtual COM port object
s = serial('COM5');
set(s,'BaudRate', 9600);
set(s,'DataBits', 8);
set(s,'StopBits', 1);

% Open virtual COM port
fopen(s);

entry = 1;
samples = 120;
windows = 111;
raw = zeros([samples 6]);

% Retrieve raw data
s.ReadAsyncMode = 'continuous';
while(entry <= samples)
    
    raw(entry, 1) = fscanf(s, '%d');
    raw(entry, 2) = fscanf(s, '%d');
    raw(entry, 3) = fscanf(s, '%d');
    raw(entry, 4) = fscanf(s, '%d');
    raw(entry, 5) = fscanf(s, '%d');
    raw(entry, 6) = fscanf(s, '%d');
    disp(['Retrieving sample #',num2str(entry)]);
    entry = entry + 1;

end

% Close virtual COM port
fclose(s);

% Delete virtual COM port object
delete(s);

%% Data Cleaning

% Apply median filter (3 element window)
clean = raw;
disp(['Cleaning sample #1']);
for entry = 2:(samples-1)
   
   ax = [raw(entry-1, 1), raw(entry, 1), raw(entry+1, 1)];
   clean(entry, 1) = median(ax);
   ay = [raw(entry-1, 2), raw(entry, 2), raw(entry+1, 2)];
   clean(entry, 2) = median(ay);
   az = [raw(entry-1, 3), raw(entry, 3), raw(entry+1, 3)];
   clean(entry, 3) = median(az);
   gx = [raw(entry-1, 4), raw(entry, 4), raw(entry+1, 4)];
   clean(entry, 4) = median(gx);
   gy = [raw(entry-1, 5), raw(entry, 5), raw(entry+1, 5)];
   clean(entry, 5) = median(gy);
   gz = [raw(entry-1, 6), raw(entry, 6), raw(entry+1, 6)];
   clean(entry, 6) = median(gz);
   disp(['Cleaning sample #',num2str(entry)]);

end
disp(['Cleaning sample #',num2str(samples)]);

%% Graph Plotting

axis auto;
grid on;
subplot(2, 3, 1); plot(clean(:,1)); title('AX');
subplot(2, 3, 2); plot(clean(:,2)); title('AY');
subplot(2, 3, 3); plot(clean(:,3)); title('AZ');
subplot(2, 3, 4); plot(clean(:,4)); title('GX');
subplot(2, 3, 5); plot(clean(:,5)); title('GY');
subplot(2, 3, 6); plot(clean(:,6)); title('GZ');

%% Window Making & Feature Extraction (ABRIDGED)

% Configure variables
features = zeros([windows 24]);
xlsheet = 1;

for object = 1:windows
    
    % Form data window
    start = object;
    stop = object + 9;
    ax = clean(start:stop,1);
    ay = clean(start:stop,2);
    az = clean(start:stop,3);
    gx = clean(start:stop,4);
    gy = clean(start:stop,5);
    gz = clean(start:stop,6);
    
    % Extract time features
    % Arithmetic Mean
    features(object,1) = mean(ax);
    features(object,2) = mean(ay);
    features(object,3) = mean(az);
    features(object,4) = mean(gx);
    features(object,5) = mean(gy);
    features(object,6) = mean(gz);
    % Range
    features(object,7) = max(ax)-min(ax);
    features(object,8) = max(ay)-min(ay);
    features(object,9) = max(az)-min(az);
    features(object,10) = max(gx)-min(gx);
    features(object,11) = max(gy)-min(gy);
    features(object,12) = max(gz)-min(gz);
    % Variance
    features(object,13) = var(ax);
    features(object,14) = var(ay);
    features(object,15) = var(az);
    features(object,16) = var(gx);
    features(object,17) = var(gy);
    features(object,18) = var(gz);
    % RMS
    features(object,19) = rms(ax);
    features(object,20) = rms(ay);
    features(object,21) = rms(az);
    features(object,22) = rms(gx);
    features(object,23) = rms(gy);
    features(object,24) = rms(gz);
    
    disp(['Extracting features of window #',num2str(object)]);

end

%% Artificial Neural Network Classification

% Load training data
filename = 'training312.xlsx';
object = 60;
cellrange = sprintf('A1:J%d', object);
tftxls = xlsread(filename, xlsheet, cellrange);

% Format training data
tf = tftxls(:,1:9);
t = tftxls(:,10);
tl = transpose(t);

% Define, Configure and Train A.N.N.
net = feedforwardnet([7 8]);
net = configure(net,tf,tl);
net = train(net,tf,tl);

cf = [0;0;0;0;0;0;0;0;0];
ccl = 0;
for object = 20:windows
    
    % Generate evaluation features (simplified)
    %cf = features(object,:);
    cf = [features(object,1);features(object,2);features(object,3);features(object,13);features(object,14);features(object,15);features(object,19);features(object,20);features(object,21)];
    
    % Generate evaluation labels
    cl = net(cf);
    
    % Generate candidate activity
    if(cl(1)>0.5)
        cl(1) = 2;
    else
        cl(1) = 1;
    end
    ccl = ccl + cl(1);
    
    disp(['Exploring matches for activity component #',num2str(object-19)]);
    
end
ccl = ccl / (windows - 19);

% Recognize activity
if(ccl>1.5)
    disp('Matched activity to model #1!');
    %ccl = 2;
else
    disp('Matched activity to model #0!');
    %ccl = 1;
end
