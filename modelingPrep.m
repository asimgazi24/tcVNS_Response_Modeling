% This code requires that the signal processing  and system identification 
% toolboxes be installed

% This script prepares the example biomarker time series data for 
% subsequent state-space modeling


% Load example dataset
load('Example_Day1_Day2_Day3_combined.mat')


%% Parse unfiltered data (in case unfiltered output is desired)
% This will also take care of a few later steps for us, such as finding the
% missing amounts of data before/after, as well as extracting a new time
% vector

% Based on our dataset, we kept 60 s prior to stimulation and 120 s after
% stimulation for modeling
preVNSBuffer = 60;
postVNSBuffer = 120;
VNSlength = 120;

% Using the parseVector function, we parse the data into specific
% administrations, while tracking the missing intial and end datapoints
% using a recursive function approach (we need to store these variables in
% case we need to alter the pulse input accordingly)
% HR
% Day 1
[tHR_D1_1, HR_D1_1, missingInitial_HR_D1_1, missingEnd_HR_D1_1] = ...
    parseVector(tHR_day1, HR_day1, VNSstart_D1_1, preVNSBuffer, ...
    VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);
[tHR_D1_2, HR_D1_2, missingInitial_HR_D1_2, missingEnd_HR_D1_2] = ...
    parseVector(tHR_day1, HR_day1, VNSstart_D1_2, preVNSBuffer, ...
    VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);
% Day 2
[tHR_D2, HR_D2, missingInitial_HR_D2, missingEnd_HR_D2] = ...
    parseVector(tHR_day2, HR_day2, VNSstart_D2, preVNSBuffer, ...
    VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);
% Day 3
[tHR_D3, HR_D3, missingInitial_HR_D3, missingEnd_HR_D3] = ...
    parseVector(tHR_day3, HR_day3, VNSstart_D3, preVNSBuffer, ...
    VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);

% PPG amplitude
% Day 1
[tPPGamp_D1_1, PPGamp_D1_1, missingInitial_PPGamp_D1_1, missingEnd_PPGamp_D1_1] = ...
    parseVector(tPPGamp_day1, PPGamp_day1, VNSstart_D1_1, preVNSBuffer,...
    VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);
[tPPGamp_D1_2, PPGamp_D1_2, missingInitial_PPGamp_D1_2, missingEnd_PPGamp_D1_2] = ...
    parseVector(tPPGamp_day1, PPGamp_day1, VNSstart_D1_2, preVNSBuffer,...
    VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);
% Day 2
[tPPGamp_D2, PPGamp_D2, missingInitial_PPGamp_D2, missingEnd_PPGamp_D2] = ...
    parseVector(tPPGamp_day2, PPGamp_day2, VNSstart_D2, preVNSBuffer,...
    VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);
% Day 3
[tPPGamp_D3, PPGamp_D3, missingInitial_PPGamp_D3, missingEnd_PPGamp_D3] = ...
    parseVector(tPPGamp_day3, PPGamp_day3, VNSstart_D3, preVNSBuffer,...
    VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);


%% Shift time vectors to start at t = 0 s
% This can be done by just left shifting by the first time point stored in
% each vector

% HR
% Day 1
tHR_D1_1_shifted = tHR_D1_1 - tHR_D1_1(1);
tHR_D1_2_shifted = tHR_D1_2 - tHR_D1_2(1);
% Day 2
tHR_D2_shifted = tHR_D2 - tHR_D2(1);
% Day 3
tHR_D3_shifted = tHR_D3 - tHR_D3(1);

% PPG Amplitude
% Day 1
tPPGamp_D1_1_shifted = tPPGamp_D1_1 - tPPGamp_D1_1(1);
tPPGamp_D1_2_shifted = tPPGamp_D1_2 - tPPGamp_D1_2(1);
% Day 2
tPPGamp_D2_shifted = tPPGamp_D2 - tPPGamp_D2(1);
% Day 3
tPPGamp_D3_shifted = tPPGamp_D3 - tPPGamp_D3(1);

%%
% Now, we deal with filtering before continuing with rest of prep.

%% Filter biomarker time series
% Create simple boxcar moving average filter 
windowSize = 5;          % data available at a rate of approx. 1/s
b = (1/windowSize)*ones(1,windowSize);
a = 1;

% Use built-in filter function
% HR
% Day 1
HR_day1_filtered = filter(b, a, HR_day1);
% Day 2
HR_day2_filtered = filter(b, a, HR_day2);
% Day 3
HR_day3_filtered = filter(b, a, HR_day3);

% PPGamp
% Day 1
PPGamp_day1_filtered = filter(b, a, PPGamp_day1);
% Day 2
PPGamp_day2_filtered = filter(b, a, PPGamp_day2);
% Day 3
PPGamp_day3_filtered = filter(b, a, PPGamp_day3);



%% Parse filtered data
% Recall that we already stored much of the other output information
% needed. So the only thing we really need from this is to extract the
% filtered data

% HR
% Day 1
[~, HR_D1_1_filtered, ~, ~] = parseVector(tHR_day1, HR_day1_filtered, ...
    VNSstart_D1_1, preVNSBuffer, VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);
[~, HR_D1_2_filtered, ~, ~] = parseVector(tHR_day1, HR_day1_filtered, ...
    VNSstart_D1_2, preVNSBuffer, VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);
% Day 2
[~, HR_D2_filtered, ~, ~] = parseVector(tHR_day2, HR_day2_filtered, ...
    VNSstart_D2, preVNSBuffer, 120 + preVNSBuffer + postVNSBuffer, 0, 0);
% Day 3
[~, HR_D3_filtered, ~, ~] = parseVector(tHR_day3, HR_day3_filtered, ...
    VNSstart_D3, preVNSBuffer, 120 + preVNSBuffer + postVNSBuffer, 0, 0);

% PPGamp
% Day 1
[~, PPGamp_D1_1_filtered, ~, ~] = parseVector(tPPGamp_day1, PPGamp_day1_filtered, ...
    VNSstart_D1_1, preVNSBuffer, VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);
[~, PPGamp_D1_2_filtered, ~, ~] = parseVector(tPPGamp_day1, PPGamp_day1_filtered, ...
    VNSstart_D1_2, preVNSBuffer, VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);
% Day 2
[~, PPGamp_D2_filtered, ~, ~] = parseVector(tPPGamp_day2, PPGamp_day2_filtered, ...
    VNSstart_D2, preVNSBuffer, 120 + preVNSBuffer + postVNSBuffer, 0, 0);
% Day 3
[~, PPGamp_D3_filtered, ~, ~] = parseVector(tPPGamp_day3, PPGamp_day3_filtered, ...
    VNSstart_D3, preVNSBuffer, 120 + preVNSBuffer + postVNSBuffer, 0, 0);


%% Resample data to desired sampling rate
% Sample time and frequency
dt = 1;
fs = 1/dt;

% Resample using built-in function
% From the documentation, resample assumes the endpoints are 0
% This is clearly an incorrect assumption. Thus, to correct this,
% we follow the 'Removing Endpoint Effects' section in the documentation:
% https://www.mathworks.com/help/signal/examples/resampling-nonuniformly-sampled-signals.html
% HR
% Day 1
% Unfiltered
[HR_D1_1_resampled, tHR_D1_1_resampled] = clean_resample(HR_D1_1, tHR_D1_1_shifted, fs, 'spline');
[HR_D1_2_resampled, tHR_D1_2_resampled] = clean_resample(HR_D1_2, tHR_D1_2_shifted, fs, 'spline');
% Filtered
[HR_D1_1_filtered_resampled, tHR_D1_1_filtered_resampled] = clean_resample(HR_D1_1_filtered, tHR_D1_1_shifted, fs, 'spline');
[HR_D1_2_filtered_resampled, tHR_D1_2_filtered_resampled] = clean_resample(HR_D1_2_filtered, tHR_D1_2_shifted, fs, 'spline');
% Day 2
% Unfiltered
[HR_D2_resampled, tHR_D2_resampled] = clean_resample(HR_D2, tHR_D2_shifted, fs, 'spline');
% Filtered
[HR_D2_filtered_resampled, tHR_D2_filtered_resampled] = clean_resample(HR_D2_filtered, tHR_D2_shifted, fs, 'spline');
% Day 3
% Unfiltered
[HR_D3_resampled, tHR_D3_resampled] = clean_resample(HR_D3, tHR_D3_shifted, fs, 'spline');
% Filtered
[HR_D3_filtered_resampled, tHR_D3_filtered_resampled] = clean_resample(HR_D3_filtered, tHR_D3_shifted, fs, 'spline');

% PPGamp
% Day 1
% Unfiltered
[PPGamp_D1_1_resampled, tPPGamp_D1_1_resampled] = clean_resample(PPGamp_D1_1, tPPGamp_D1_1_shifted, fs, 'spline');
[PPGamp_D1_2_resampled, tPPGamp_D1_2_resampled] = clean_resample(PPGamp_D1_2, tPPGamp_D1_2_shifted, fs, 'spline');
% Filtered
[PPGamp_D1_1_filtered_resampled, tPPGamp_D1_1_filtered_resampled] = clean_resample(PPGamp_D1_1_filtered, tPPGamp_D1_1_shifted, fs, 'spline');
[PPGamp_D1_2_filtered_resampled, tPPGamp_D1_2_filtered_resampled] = clean_resample(PPGamp_D1_2_filtered, tPPGamp_D1_2_shifted, fs, 'spline');
% Day 2
% Unfiltered
[PPGamp_D2_resampled, tPPGamp_D2_resampled] = clean_resample(PPGamp_D2, tPPGamp_D2_shifted, fs, 'spline');
% Filtered
[PPGamp_D2_filtered_resampled, tPPGamp_D2_filtered_resampled] = clean_resample(PPGamp_D2_filtered, tPPGamp_D2_shifted, fs, 'spline');
% Day 3
% Unfiltered
[PPGamp_D3_resampled, tPPGamp_D3_resampled] = clean_resample(PPGamp_D3, tPPGamp_D3_shifted, fs, 'spline');
% Filtered
[PPGamp_D3_filtered_resampled, tPPGamp_D3_filtered_resampled] = clean_resample(PPGamp_D3_filtered, tPPGamp_D3_shifted, fs, 'spline');

% Make sure all vectors are of appropriate length
% If not, use interp1 to force it to be so

% Store available times
availableTime_HR_D1_1 = (VNSlength + preVNSBuffer + postVNSBuffer) - ...
    (missingEnd_HR_D1_1 + missingInitial_HR_D1_1);
availableTime_HR_D1_2 = (VNSlength + preVNSBuffer + postVNSBuffer) - ...
    (missingEnd_HR_D1_2 + missingInitial_HR_D1_2);
availableTime_HR_D2 = (VNSlength + preVNSBuffer + postVNSBuffer) - ...
    (missingEnd_HR_D2 + missingInitial_HR_D2);
availableTime_HR_D3 = (VNSlength + preVNSBuffer + postVNSBuffer) - ...
    (missingEnd_HR_D3 + missingInitial_HR_D3);

availableTime_PPGamp_D1_1 = (VNSlength + preVNSBuffer + postVNSBuffer) - ...
    (missingEnd_PPGamp_D1_1 + missingInitial_PPGamp_D1_1);
availableTime_PPGamp_D1_2 = (VNSlength + preVNSBuffer + postVNSBuffer) - ...
    (missingEnd_PPGamp_D1_2 + missingInitial_PPGamp_D1_2);
availableTime_PPGamp_D2 = (VNSlength + preVNSBuffer + postVNSBuffer) - ...
    (missingEnd_PPGamp_D2 + missingInitial_PPGamp_D2);
availableTime_PPGamp_D3 = (VNSlength + preVNSBuffer + postVNSBuffer) - ...
    (missingEnd_PPGamp_D3 + missingInitial_PPGamp_D3);

% Create appropriate sampling time vectors
% Create appropriate sampling time vectors
sampleTime_HR_D1_1 = dt:dt:availableTime_HR_D1_1;
sampleTime_HR_D1_2 = dt:dt:availableTime_HR_D1_2;
sampleTime_HR_D2 = dt:dt:availableTime_HR_D2;
sampleTime_HR_D3 = dt:dt:availableTime_HR_D3;

sampleTime_PPGamp_D1_1 = dt:dt:availableTime_PPGamp_D1_1;
sampleTime_PPGamp_D1_2 = dt:dt:availableTime_PPGamp_D1_2;
sampleTime_PPGamp_D2 = dt:dt:availableTime_PPGamp_D2;
sampleTime_PPGamp_D3 = dt:dt:availableTime_PPGamp_D3;

% Check before doing this extra operation
% With this interpolation to a specified sampleTime vector, we're
% guaranteeing that the vector will be of appropriate length

% Notice that if the unfiltered version was resampled in an undesirable way,
% the filtered version will be equivalently resampled
% HR
if length(HR_D1_1_resampled) ~= availableTime_HR_D1_1
    HR_D1_1_resampled = interp1(tHR_D1_1_resampled, HR_D1_1_resampled, ...
        sampleTime_HR_D1_1, 'spline');
    HR_D1_1_filtered_resampled = interp1(tHR_D1_1_filtered_resampled, ...
        HR_D1_1_filtered_resampled, sampleTime_HR_D1_1, 'spline');
end
if length(HR_D1_2_resampled) ~= availableTime_HR_D1_2
    HR_D1_2_resampled = interp1(tHR_D1_2_resampled, HR_D1_2_resampled, ...
        sampleTime_HR_D1_2, 'spline');
    HR_D1_2_filtered_resampled = interp1(tHR_D1_2_filtered_resampled, ...
        HR_D1_2_filtered_resampled, sampleTime_HR_D1_2, 'spline');
end
if length(HR_D2_resampled) ~= availableTime_HR_D2
    HR_D2_resampled = interp1(tHR_D2_resampled, HR_D2_resampled, ...
        sampleTime_HR_D2, 'spline');
    HR_D2_filtered_resampled = interp1(tHR_D2_filtered_resampled, ...
        HR_D2_filtered_resampled, sampleTime_HR_D2, 'spline');
end
if length(HR_D3_resampled) ~= availableTime_HR_D3
    HR_D3_resampled = interp1(tHR_D3_resampled, HR_D3_resampled, ...
        sampleTime_HR_D3, 'spline');
    HR_D3_filtered_resampled = interp1(tHR_D3_filtered_resampled, ...
        HR_D3_filtered_resampled, sampleTime_HR_D3, 'spline');
end

% PPGamp
if length(PPGamp_D1_1_resampled) ~= availableTime_PPGamp_D1_1
    PPGamp_D1_1_resampled = interp1(tPPGamp_D1_1_resampled, PPGamp_D1_1_resampled, ...
        sampleTime_PPGamp_D1_1, 'spline');
    PPGamp_D1_1_filtered_resampled = interp1(tPPGamp_D1_1_filtered_resampled, ...
        PPGamp_D1_1_filtered_resampled, sampleTime_PPGamp_D1_1, 'spline');
end
if length(PPGamp_D1_2_resampled) ~= availableTime_PPGamp_D1_2
    PPGamp_D1_2_resampled = interp1(tPPGamp_D1_2_resampled, PPGamp_D1_2_resampled, ...
        sampleTime_PPGamp_D1_2, 'spline');
    PPGamp_D1_2_filtered_resampled = interp1(tPPGamp_D1_2_filtered_resampled, ...
        PPGamp_D1_2_filtered_resampled, sampleTime_PPGamp_D1_2, 'spline');
end
if length(PPGamp_D2_resampled) ~= availableTime_PPGamp_D2
    PPGamp_D2_resampled = interp1(tPPGamp_D2_resampled, PPGamp_D2_resampled, ...
        sampleTime_PPGamp_D2, 'spline');
    PPGamp_D2_filtered_resampled = interp1(tPPGamp_D2_filtered_resampled, ...
        PPGamp_D2_filtered_resampled, sampleTime_PPGamp_D2, 'spline');
end
if length(PPGamp_D3_resampled) ~= availableTime_PPGamp_D3
    PPGamp_D3_resampled = interp1(tPPGamp_D3_resampled, PPGamp_D3_resampled, ...
        sampleTime_PPGamp_D3, 'spline');
    PPGamp_D3_filtered_resampled = interp1(tPPGamp_D3_filtered_resampled, ...
        PPGamp_D3_filtered_resampled, sampleTime_PPGamp_D3, 'spline');
end

%% Normalize output vectors by appropriate resting values
% Normalize by subtracting by and dividing by rest
% HR
% Day 1
% Unfiltered
HR_D1_1_resampled_normal = (1/HR_rest_D1)*(HR_D1_1_resampled - HR_rest_D1);
HR_D1_2_resampled_normal = (1/HR_rest_D1)*(HR_D1_2_resampled - HR_rest_D1);
% Filtered
HR_D1_1_filtered_resampled_normal = (1/HR_rest_D1)*(HR_D1_1_filtered_resampled - HR_rest_D1);
HR_D1_2_filtered_resampled_normal = (1/HR_rest_D1)*(HR_D1_2_filtered_resampled - HR_rest_D1);
% Day 2
% Unfiltered
HR_D2_resampled_normal = (1/HR_rest_D2)*(HR_D2_resampled - HR_rest_D2);
% Filtered
HR_D2_filtered_resampled_normal = (1/HR_rest_D2)*(HR_D2_filtered_resampled - HR_rest_D2);
% Day 3
% Unfiltered
HR_D3_resampled_normal = (1/HR_rest_D3)*(HR_D3_resampled - HR_rest_D3);
% Filtered
HR_D3_filtered_resampled_normal = (1/HR_rest_D3)*(HR_D3_filtered_resampled - HR_rest_D3);

% PPGamp
% Day 1
% Unfiltered
PPGamp_D1_1_resampled_normal = (1/PPGamp_rest_D1)*(PPGamp_D1_1_resampled - PPGamp_rest_D1);
PPGamp_D1_2_resampled_normal = (1/PPGamp_rest_D1)*(PPGamp_D1_2_resampled - PPGamp_rest_D1);
% Filtered
PPGamp_D1_1_filtered_resampled_normal = (1/PPGamp_rest_D1)*(PPGamp_D1_1_filtered_resampled - PPGamp_rest_D1);
PPGamp_D1_2_filtered_resampled_normal = (1/PPGamp_rest_D1)*(PPGamp_D1_2_filtered_resampled - PPGamp_rest_D1);
% Day 2
% Unfiltered
PPGamp_D2_resampled_normal = (1/PPGamp_rest_D2)*(PPGamp_D2_resampled - PPGamp_rest_D2);
% Filtered
PPGamp_D2_filtered_resampled_normal = (1/PPGamp_rest_D2)*(PPGamp_D2_filtered_resampled - PPGamp_rest_D2);
% Day 3
% Unfiltered
PPGamp_D3_resampled_normal = (1/PPGamp_rest_D3)*(PPGamp_D3_resampled - PPGamp_rest_D3);
% Filtered
PPGamp_D3_filtered_resampled_normal = (1/PPGamp_rest_D3)*(PPGamp_D3_filtered_resampled - PPGamp_rest_D3);


%% Create gammaCore-replicating tcVNS Input Pulses
% Because each biomarker-administration dataset could potentially have
% different missing dataset, each of these pulses are constructed
% (potentially) differently

% HR
% Day 1
pulse_HR_D1_1 = [zeros(1, round((preVNSBuffer - missingInitial_HR_D1_1)/dt))...
    ones(1, round(VNSlength/dt)) zeros(1, round((postVNSBuffer - missingEnd_HR_D1_1)/dt))];
pulse_HR_D1_2 = [zeros(1, round((preVNSBuffer - missingInitial_HR_D1_2)/dt))...
    ones(1, round(VNSlength/dt)) zeros(1, round((postVNSBuffer - missingEnd_HR_D1_2)/dt))];
% Day 2
pulse_HR_D2 = [zeros(1, round((preVNSBuffer - missingInitial_HR_D2)/dt))...
    ones(1, round(VNSlength/dt)) zeros(1, round((postVNSBuffer - missingEnd_HR_D2)/dt))];
% Day 3
pulse_HR_D3 = [zeros(1, round((preVNSBuffer - missingInitial_HR_D3)/dt))...
    ones(1, round(VNSlength/dt)) zeros(1, round((postVNSBuffer - missingEnd_HR_D3)/dt))];

% PPGamp
% Day 1
pulse_PPGamp_D1_1 = [zeros(1, round((preVNSBuffer - missingInitial_PPGamp_D1_1)/dt))...
    ones(1, round(VNSlength/dt)) zeros(1, round((postVNSBuffer - missingEnd_PPGamp_D1_1)/dt))];
pulse_PPGamp_D1_2 = [zeros(1, round((preVNSBuffer - missingInitial_PPGamp_D1_2)/dt))...
    ones(1, round(VNSlength/dt)) zeros(1, round((postVNSBuffer - missingEnd_PPGamp_D1_2)/dt))];
% Day 2
pulse_PPGamp_D2 = [zeros(1, round((preVNSBuffer - missingInitial_PPGamp_D2)/dt))...
    ones(1, round(VNSlength/dt)) zeros(1, round((postVNSBuffer - missingEnd_PPGamp_D2)/dt))];
% Day 3
pulse_PPGamp_D3 = [zeros(1, round((preVNSBuffer - missingInitial_PPGamp_D3)/dt))...
    ones(1, round(VNSlength/dt)) zeros(1, round((postVNSBuffer - missingEnd_PPGamp_D3)/dt))];

% Pass through boxcar filter to achieve ramp up and down effect
pulse_HR_D1_1 = filter(b, a, pulse_HR_D1_1);
pulse_HR_D1_2 = filter(b, a, pulse_HR_D1_2);
pulse_HR_D2 = filter(b, a, pulse_HR_D2);
pulse_HR_D3 = filter(b, a, pulse_HR_D3);

pulse_PPGamp_D1_1 = filter(b, a, pulse_PPGamp_D1_1);
pulse_PPGamp_D1_2 = filter(b, a, pulse_PPGamp_D1_2);
pulse_PPGamp_D2 = filter(b, a, pulse_PPGamp_D2);
pulse_PPGamp_D3 = filter(b, a, pulse_PPGamp_D3);

%% Transpose all row vectors for possible use into column vectors
% Built-in model identification functions expect column vectors for data
% So, just transpose

% Pulse inputs
pulse_HR_D1_1 = pulse_HR_D1_1';
pulse_HR_D1_2 = pulse_HR_D1_2';
pulse_HR_D2 = pulse_HR_D2';
pulse_HR_D3 = pulse_HR_D3';
pulse_PPGamp_D1_1 = pulse_PPGamp_D1_1';
pulse_PPGamp_D1_2 = pulse_PPGamp_D1_2';
pulse_PPGamp_D2 = pulse_PPGamp_D2';
pulse_PPGamp_D3 = pulse_PPGamp_D3';

% Unfiltered Output
HR_D1_1_resampled_normal = HR_D1_1_resampled_normal';
HR_D1_2_resampled_normal = HR_D1_2_resampled_normal';
HR_D2_resampled_normal = HR_D2_resampled_normal';
HR_D3_resampled_normal = HR_D3_resampled_normal';
PPGamp_D1_1_resampled_normal = PPGamp_D1_1_resampled_normal';
PPGamp_D1_2_resampled_normal = PPGamp_D1_2_resampled_normal';
PPGamp_D2_resampled_normal = PPGamp_D2_resampled_normal';
PPGamp_D3_resampled_normal = PPGamp_D3_resampled_normal';

% Filtered Output
HR_D1_1_filtered_resampled_normal = HR_D1_1_filtered_resampled_normal';
HR_D1_2_filtered_resampled_normal = HR_D1_2_filtered_resampled_normal';
HR_D2_filtered_resampled_normal = HR_D2_filtered_resampled_normal';
HR_D3_filtered_resampled_normal = HR_D3_filtered_resampled_normal';
PPGamp_D1_1_filtered_resampled_normal = PPGamp_D1_1_filtered_resampled_normal';
PPGamp_D1_2_filtered_resampled_normal = PPGamp_D1_2_filtered_resampled_normal';
PPGamp_D2_filtered_resampled_normal = PPGamp_D2_filtered_resampled_normal';
PPGamp_D3_filtered_resampled_normal = PPGamp_D3_filtered_resampled_normal';

%%
% Now, we need to use the desired data to create iddata objects for model
% identification
%% Create single experiment iddata objects
% Syntax: % data = iddata(y, u, Ts), where y is the output, u is the input,
% and Ts is the sample time

% From here on out, we will replicate the paper's approach in using
% filtered biomarker data only
% HR
D1_1_HR = iddata(HR_D1_1_filtered_resampled_normal, pulse_HR_D1_1, dt);
D1_2_HR = iddata(HR_D1_2_filtered_resampled_normal, pulse_HR_D1_2, dt);
D2_HR = iddata(HR_D2_filtered_resampled_normal, pulse_HR_D2, dt);
D3_HR = iddata(HR_D3_filtered_resampled_normal, pulse_HR_D3, dt);

% PPGamp
D1_1_PPGamp = iddata(PPGamp_D1_1_filtered_resampled_normal, pulse_PPGamp_D1_1, dt);
D1_2_PPGamp = iddata(PPGamp_D1_2_filtered_resampled_normal, pulse_PPGamp_D1_2, dt);
D2_PPGamp = iddata(PPGamp_D2_filtered_resampled_normal, pulse_PPGamp_D2, dt);
D3_PPGamp = iddata(PPGamp_D3_filtered_resampled_normal, pulse_PPGamp_D3, dt);

%% Merge single experiment data objects into multi-experiment iddata objects
% These multi-experiment iddata objects will be created to foster
% leave-one-out cross-validation
% 'Test' in the variable name will now refer to the administration left out
% for testing
% Syntax: multiExp = merge(singleExp1, singleExp2, singleExp3);

% Test resultant model on D1_1
Test_D1_1_HR = merge(D1_2_HR, D2_HR, D3_HR);
Test_D1_1_PPGamp = merge(D1_2_PPGamp, D2_PPGamp, D3_PPGamp);

% Test resultant model on D1_2
Test_D1_2_HR = merge(D1_1_HR, D2_HR, D3_HR);
Test_D1_2_PPGamp = merge(D1_1_PPGamp, D2_PPGamp, D3_PPGamp);

% Test resultant model on D2
Test_D2_HR = merge(D1_1_HR, D1_2_HR, D3_HR);
Test_D2_PPGamp = merge(D1_1_PPGamp, D1_2_PPGamp, D3_PPGamp);

% Test resultant model on D3
Test_D3_HR = merge(D1_1_HR, D1_2_HR, D2_HR);
Test_D3_PPGamp = merge(D1_1_PPGamp, D1_2_PPGamp, D2_PPGamp);
