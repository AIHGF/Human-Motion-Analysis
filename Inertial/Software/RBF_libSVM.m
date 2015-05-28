%% Human Motion Analysis using Inertial Sensors

% (!) Requires custom (beta) hardware and firmware.

%% Resources

% Electronic Hardware
% Bill of Materials (https://github.com/anirudh-ramesh/Human-Motion-Analysis/blob/master/Bill_of_Materials.xlsx)
% (!) BETA

% Firmware
% (https://github.com/anirudh-ramesh/Human-Motion-Analysis/blob/master/Arduino_MPU6050.ino)
% (!) BETA

% Classifier (Support Vector Machine) software framework - libSVM-3.20 or later
% (https://github.com/cjlin1/libsvm)

%% Data Acquisition (BETA)

% Hardware must be configured to transmit 9600 bits/second, with 8 data
% bits for every stop bit.

% Hardware must transmit raw data in the following format:
%   AX
%   RSSI
%   AY
%   RSSI
%   AZ
%   RSSI
%   GX
%   RSSI
%   GY
%   RSSI
%   GZ
%   RSSI
%
% AX, AY and AZ - 12 bits, 2's complement notation
% Acceleration along X, Y and Z directions
%
% GX, GY and GZ - 12 bits
% Rotation along X, Y and Z directions
%
% RSSI - 12 bits, dBm (decibel-metre)
% Received Signal Strength Indicator

% Flush Workspace
clear;

% Flush Command Window
clc;

% Flush Figure
clf;

% Configure virtual COM port object
s = serial('COM7');
set(s,'BaudRate', 9600);
set(s,'DataBits', 8);
set(s,'StopBits', 1);

% Open virtual COM port
fopen(s);

entry = 1;
samples = 100;
windows = samples - 9;
raw = zeros([samples 7]);
serials = 1:1:samples;

% Retrieve raw data
s.ReadAsyncMode = 'continuous';
while(entry <= samples)
    
    % AX
    raw(entry, 1) = fscanf(s, '%d');
    % RSSI
    raw(entry, 2) = fscanf(s, '%d');
    % AY
    raw(entry, 3) = fscanf(s, '%d');
    % RSSI
    raw(entry, 2) = raw(entry, 2) + fscanf(s, '%d');
    % AZ
    raw(entry, 4) = fscanf(s, '%d');
    % RSSI
    raw(entry, 2) = raw(entry, 2) + fscanf(s, '%d');
    % GX
    raw(entry, 5) = fscanf(s, '%d');
    % RSSI
    raw(entry, 2) = raw(entry, 2) + fscanf(s, '%d');
    % GY
    raw(entry, 6) = fscanf(s, '%d');
    % RSSI
    raw(entry, 2) = raw(entry, 2) + fscanf(s, '%d');
    % GZ
    raw(entry, 7) = fscanf(s, '%d');
    % RSSI
    raw(entry, 2) = (raw(entry, 2) + fscanf(s, '%d'))/6;
    disp(['Retrieving sample #',num2str(entry)]);
    entry = entry + 1;

end

% Close virtual COM port
fclose(s);

% Delete virtual COM port object
delete(s);

%% Data Cleaning
% (!) Implement code reuse.

% Apply median filter (3 element window)
clean = raw;
disp('Cleaning sample #1');
for entry = 2:(samples-1)
   
   ax = [raw(entry-1, 1), raw(entry, 1), raw(entry+1, 1)];
   clean(entry, 1) = median(ax);
   rssi = [raw(entry-1, 2), raw(entry, 2), raw(entry+1, 2)];
   clean(entry, 7) = median(rssi);
   ay = [raw(entry-1, 3), raw(entry, 3), raw(entry+1, 3)];
   clean(entry, 2) = median(ay);
   az = [raw(entry-1, 4), raw(entry, 4), raw(entry+1, 4)];
   clean(entry, 3) = median(az);
   gx = [raw(entry-1, 5), raw(entry, 5), raw(entry+1, 5)];
   clean(entry, 4) = median(gx);
   gy = [raw(entry-1, 6), raw(entry, 6), raw(entry+1, 6)];
   clean(entry, 5) = median(gy);
   gz = [raw(entry-1, 7), raw(entry, 7), raw(entry+1, 7)];
   clean(entry, 6) = median(gz);
   disp(['Cleaning sample #',num2str(entry)]);

end
disp(['Cleaning sample #',num2str(samples)]);

%% Graph Plotting
% (!) Implement code reuse.

axis auto;
grid on;
%figure;
subplot(3,2,1);
plot(serials, clean(:,1));
title('AX');
xlabel('Samples');
ylabel('Equivalents');
subplot(3,2,2);
plot(serials, clean(:,2));
title('AY');
xlabel('Samples');
ylabel('Equivalents');
subplot(3,2,3);
plot(serials, clean(:,3));
title('AZ');
xlabel('Samples');
ylabel('Equivalents');
subplot(3,2,4);
plot(serials, clean(:,4));
title('GX');
xlabel('Samples');
ylabel('Equivalents');
subplot(3,2,5);
plot(serials, clean(:,5));
title('GY');
xlabel('Samples');
ylabel('Equivalents');
subplot(3,2,6);
plot(serials, clean(:,6));
title('GZ');
xlabel('Samples');
ylabel('Equivalents');
figure;
plot(serials, clean(:,7));
title('Average RSSI');
xlabel('Samples');
ylabel('dBm');

%% Window Making & Feature Extraction
% (!) Implement code reuse.

% Configure variables
features_time = zeros([windows 54]);
features_frequency = zeros([windows 6]);
features_quefrency = zeros([windows 108]);

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
    features_time(object,1) = mean(ax);
    features_time(object,2) = mean(ay);
    features_time(object,3) = mean(az);
    features_time(object,4) = mean(gx);
    features_time(object,5) = mean(gy);
    features_time(object,6) = mean(gz);
    % Range
    features_time(object,7) = max(ax)-min(ax);
    features_time(object,8) = max(ay)-min(ay);
    features_time(object,9) = max(az)-min(az);
    features_time(object,10) = max(gx)-min(gx);
    features_time(object,11) = max(gy)-min(gy);
    features_time(object,12) = max(gz)-min(gz);
    % Variance
    features_time(object,13) = var(ax);
    features_time(object,14) = var(ay);
    features_time(object,15) = var(az);
    features_time(object,16) = var(gx);
    features_time(object,17) = var(gy);
    features_time(object,18) = var(gz);
    % RMS
    features_time(object,19) = rms(ax);
    features_time(object,20) = rms(ay);
    features_time(object,21) = rms(az);
    features_time(object,22) = rms(gx);
    features_time(object,23) = rms(gy);
    features_time(object,24) = rms(gz);
    % Inter-axis Correlation
    CC = corrcoef(ax,ay);
    features_time(object,25) = CC(1,2);
    CC = corrcoef(ay,az);
    features_time(object,26) = CC(1,2);
    CC = corrcoef(az,ax);
    features_time(object,27) = CC(1,2);
    CC = corrcoef(gx,gy);
    features_time(object,28) = CC(1,2);
    CC = corrcoef(gy,gz);
    features_time(object,29) = CC(1,2);
    CC = corrcoef(gz,gx);
    features_time(object,30) = CC(1,2);
    % Zero Crossing Rate
    for ZC = 1:9
        if(ax(ZC)*ax(ZC+1)<0)
            features_time(object,31) = features_time(object,31) + 1;
        end
        if(ay(ZC)*ay(ZC+1)<0)
            features_time(object,32) = features_time(object,32) + 1;
        end
        if(az(ZC)*az(ZC+1)<0)
            features_time(object,33) = features_time(object,33) + 1;
        end
        if(gx(ZC)*gx(ZC+1)<0)
            features_time(object,34) = features_time(object,34) + 1;
        end
        if(gy(ZC)*gy(ZC+1)<0)
            features_time(object,35) = features_time(object,35) + 1;
        end
        if(gz(ZC)*gz(ZC+1)<0)
            features_time(object,36) = features_time(object,36) + 1;
        end
    end
    % Inter-quartile Range
    features_time(object,37) = iqr(ax);
    features_time(object,38) = iqr(ay);
    features_time(object,39) = iqr(az);
    features_time(object,40) = iqr(gx);
    features_time(object,41) = iqr(gy);
    features_time(object,42) = iqr(gz);
    % Mean Absolute Deviation
    features_time(object,43) = mad(ax);
    features_time(object,44) = mad(ay);
    features_time(object,45) = mad(az);
    features_time(object,46) = mad(gx);
    features_time(object,47) = mad(gy);
    features_time(object,48) = mad(gz);
    % Kurtosis
    features_time(object,49) = kurtosis(ax);
    features_time(object,50) = kurtosis(ay);
    features_time(object,51) = kurtosis(az);
    features_time(object,52) = kurtosis(gx);
    features_time(object,53) = kurtosis(gy);
    features_time(object,54) = kurtosis(gz);
    
    % Extract frequency features
    % Spectral Centroid
    features_frequency(object, 1) = SpectralCentroid(ax, 10, 1, 25);
    features_frequency(object, 2) = SpectralCentroid(ay, 10, 1, 25);
    features_frequency(object, 3) = SpectralCentroid(az, 10, 1, 25);
    features_frequency(object, 4) = SpectralCentroid(gx, 10, 1, 25);
    features_frequency(object, 5) = SpectralCentroid(gy, 10, 1, 25);
    features_frequency(object, 6) = SpectralCentroid(gz, 10, 1, 25);
    % Spectral Flux
    % Spectral RollOff
    
    % Extract quefrency features
    % Mel Frequency Cepstral Coefficients
    [mmax,aspcax] = melfcc(ax*3.3752, sr, 'maxfreq', 8000, 'numcep', 20, 'nbands', 22, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', 0.032, 'hoptime', 0.016, 'preemph', 0, 'dither', 1);
    [mmay,aspcay] = melfcc(ay*3.3752, sr, 'maxfreq', 8000, 'numcep', 20, 'nbands', 22, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', 0.032, 'hoptime', 0.016, 'preemph', 0, 'dither', 1);
    [mmaz,aspcaz] = melfcc(az*3.3752, sr, 'maxfreq', 8000, 'numcep', 20, 'nbands', 22, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', 0.032, 'hoptime', 0.016, 'preemph', 0, 'dither', 1);
    [mmgx,aspcgx] = melfcc(gx*3.3752, sr, 'maxfreq', 8000, 'numcep', 20, 'nbands', 22, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', 0.032, 'hoptime', 0.016, 'preemph', 0, 'dither', 1);
    [mmgy,aspcgy] = melfcc(gy*3.3752, sr, 'maxfreq', 8000, 'numcep', 20, 'nbands', 22, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', 0.032, 'hoptime', 0.016, 'preemph', 0, 'dither', 1);
    [mmgz,aspcgz] = melfcc(gz*3.3752, sr, 'maxfreq', 8000, 'numcep', 20, 'nbands', 22, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', 0.032, 'hoptime', 0.016, 'preemph', 0, 'dither', 1);
    features_quefrency(object, 1:18) = aspcax(1:18);
    features_quefrency(object, 19:36) = aspcay(1:18);
    features_quefrency(object, 37:54) = aspcaz(1:18);
    features_quefrency(object, 55:72) = aspcgx(1:18);
    features_quefrency(object, 73:90) = aspcgy(1:18);
    features_quefrency(object, 91:108) = aspcgz(1:18);
    
    disp(['Extracting features of window #',num2str(object)]);

end

% Store feature data
filename = 'time.xlsx';
xlswrite(filename, features_time);
filename = 'frequency.xlsx';
xlswrite(filename, features_frequency);
filename = 'quefrency.xlsx';
xlswrite(filename, features_quefrency);

%% Data Classification

% Save transcript to log
% Create file handle
diary TrainingTranscript.log

% Reset clock
tic

% Load training data
load TrainingData.mat
numInst = size(data,1);
numLabels = max(labels);

% Create training metadata
numTrain = numInst;
trainData = data;
trainLabel = labels;

% Load test data
features = cat(1, features_time, features_frequency, features_quefrency);

% Create test metadata
numTest = object;
testData = features;
testLabel = ones(numTest, 1);

% Define, Configure and Train S.V.M.
model = cell(numLabels,1);
val = 3;
parfor k=1:numLabels
    bestcv = 0;
    for log2c = -1:3,
        for log2g = -4:1,
            cmd = ['-v ', num2str(val),' -b 1 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
            cv = svmtrain(double(trainLabel==k), trainData, cmd);
            if (cv >= bestcv),
                bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
            end
			fprintf('%g %g %g (Best C = %g, G = %g, Rate = %g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
        end
    end
    cmd1=['-c ',num2str(bestc), ' -g ',num2str(bestg), ' -b 1'];
    model{k} = svmtrain(double(trainLabel==k), trainData, cmd1);
end

% Perform classification
prob = zeros(numTest,numLabels);
for k=1:numLabels
    [~,~,p] = svmpredict(double(testLabel==k), testData, model{k}, '-b 1');
    prob(:,k) = p(:,model{k}.Label==1);
end
[~,pred] = max(prob,[],2);
sum(pred == object)

% Read clock status
TimeElapsed = toc

% Discard file handle
diary off