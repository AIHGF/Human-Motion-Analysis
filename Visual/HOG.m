% Flush Workspace
clear;

% Flush Command Window
clc;

% Flush Figure
clf;

% Read image from memory
i = imread('tetrarch.jpg');

% Transform, if needed, RGB to grayscale
if size(i, 3) > 1, ig = rgb2gray(i) ; else ig = i ; end

% Extract points of interest
cornerPoints = detectFASTFeatures(ig);

% Extract Histogram of Oriented Gradients (HOG) and its visualization
[hog, ~, featureVisualization] = extractHOGFeatures(i, cornerPoints);

% Display image, points of interest and HOG visualization
imshow(i);
hold on;
plot(cornerPoints);
plot(featureVisualization);

% Save figure to memory
print('tetrarch_HOG.png', '-dpng');