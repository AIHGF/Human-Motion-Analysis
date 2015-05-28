# Human-Motion-Analysis

This repository contains software (MATLAB scripts) and firmware (Arduino C-based) for an Activity Analysis system.

Firmware:
Features Timer-interrupt Generation, data retrieval on interrupt and formatted data transfer.

Software:

Data Acquisition - Raw sensor data, evenly sampled at 25 Hz, is retrieved using a microcontroller (Arduino, for example) and accessed over a virtual COM port using MATLAB. The data retrieved has six components - AX, AY, AZ, GZ, GY and GZ - corresponding to accelerometer and gyroscope data of each axis, using the Invensense MPU-6050 or the ADXL-335. In the case of deploying wireless sensor nodes (RFduino, for example), a seventh component - RSSI - Received Signal Strength Indicator can be added, which is, however, not exceptionally helpful in recognizing human motion per se.

Noise Removal - A simple three-element median filter is used for cleaning raw data. A potential update would use Runge-Kutta method instead.

Feature Extraction - 
A moving window of 10 samples for each of the six data components is synthesized with a 90% overlap (10% replacement) policy. Features are extracted from this window.

Features (Time):

1. Arithmetic Mean

2. Range

3. Variance

4. Root Mean Square Value

5. Inter-axis correlation

6. Zero Crossing Rate

7. Inter-quartile Range

8. Mean Absolute Deviation

9. Kurtosis

Features (Frequency):

1. Spectral Centroid

2. Spectral Flux

3. Spectral Roll Off

Features (Quefrency):

1. Mel Frequency Cepstral Coefficients

Feature Classification -

1. Artificial Neural Network with 2 hidden layers of 7 and 8 neurons, respectively, trained using the Levenberg-Marquardt Algorithm.

2. Support Vector Machine with a Radial Basis Function kernel trained using a one-against-all approach offered by libSVM.

Resources:

1. Human Activity Recognition: Using Wearable Sensors and Smartphones - Miguel A. Labrador, Oscar D. Lara Yejas - http://www.crcpress.com/product/isbn/9781466588271 ; PDF eBook - International Standard Book Number-13: 978-1-4665-8828-8

2. Human Activity Recognition (Fitness) - Gymneus Sports Technology Design, Wien, Österreich - TIC Projects, January - May 2014 - http://www.scribd.com/doc/221775440/

3. Spectral Centroid - MATLAB Central File Exchange - http://in.mathworks.com/matlabcentral/fileexchange/28826-silence-removal-in-speech-signals/content/SpectralCentroid.m

4. Mel Frequency Cepstral Coefficients -

	a. Laboratory for the Recognition and Organization of Speech and Audio, Columbia University in the City of New York - http://labrosa.ee.columbia.edu/matlab/rastamat/melfcc.m
	
	b. Safety Alert System - https://github.com/shefali92/Safety-Alert-System/blob/master/src/com/example/uitesting/computations/MFCC.java

5. libSVM - https://github.com/cjlin1/libsvm

Deployment:
(Potential for integration with existing facilities)

1. Repetition Counting : "Maxxyt: An Autonomous Wearable Device for Real-time Tracking of a Wide Range of Exercises" - Gymneus Sports Technology Design, Vienna, Austria (http://uksim.info/uksim2015/data/8713a137.pdf)

2. Indoor Localization : "RSSI-based Indoor Tracking using the Extended Kalman Filter and Circularly Polarized Antennas" - Quattriuum, Montréal, Canada (http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=6843305)
