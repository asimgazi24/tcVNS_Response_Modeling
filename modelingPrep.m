% This code requires that the signal processing  and system identification 
% toolboxes be installed

% This script prepares the example biomarker time series data for 
% subsequent state-space modeling

% Load example dataset
load('Example_Day1_Day2_Day3_combined.mat')
% Convert to matrices and cell arrays
% Day 1 is represented twice for easier loop control with day 1 being separated into two parts
raw_HR = {HR_day1, HR_day1, HR_day2, HR_day3};
raw_tHR = {tHR_day1, tHR_day1, tHR_day2, tHR_day3};
HR_rests = [HR_rest_D1, HR_rest_D1, HR_rest_D2, HR_rest_D3];
HR_iddatas = {};

raw_PPGamp = {PPGamp_day1, PPGamp_day1, PPGamp_day2, PPGamp_day3};
raw_tPPGamp = {tPPGamp_day1, tPPGamp_day1, tPPGamp_day2, tPPGamp_day3};
PPGamp_rests = [PPGamp_rest_D1, PPGamp_rest_D1, PPGamp_rest_D2, PPGamp_rest_D3];
PPGamp_iddatas = {};

VNS_starts = [VNSstart_D1_1, VNSstart_D1_2, VNSstart_D2, VNSstart_D3];
VNS_stops = [VNSstop_D1_1, VNSstop_D1_2, VNSstop_D2, VNSstop_D3];

% This is what we use during the actual operations. More or less signals can be added
% by changing these values and then updating the signalCounter
raw_SIGNAL = {raw_HR, raw_PPGamp};
raw_tSIGNAL = {raw_tHR, raw_tPPGamp};
SIGNAL_rests = {HR_rests, PPGamp_rests};
SIGNAL_iddatas = {HR_iddatas, PPGamp_iddatas};


% Based on our dataset, we kept 60 s prior to stimulation and 120 s after
% stimulation for modeling
preVNSBuffer = 60;
postVNSBuffer = 120;
VNSlength = 120;

% First signalCounter iteration is for HR and second is for PPGamp
for signalCounter = 1:2
    for dayCounter = 1:4

        % Using the parseVector function, we parse the data into specific
        % administrations, while tracking the missing intial and end datapoints
        % using a recursive function approach (we need to store these variables in
        % case we need to alter the pulse input accordingly)

        [tSIGNAL_DayN, SIGNAL_DayN, missingInitial_SIGNAL_DayN, missingEnd_SIGNAL_DayN] = ...
            parseVector(raw_tSIGNAL{signalCounter}{dayCounter}, raw_SIGNAL{signalCounter}{dayCounter}, VNS_starts(dayCounter), preVNSBuffer, ...
            VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);  
        
        %% Shift time vectors to start at t = 0 s
        % This can be done by just left shifting by the first time point stored in
        % each vector
        tSIGNAL_DayN_shifted = tSIGNAL_DayN - tSIGNAL_DayN(1);

        %% Filter biomarker time series
        % Create simple boxcar moving average filter 
        windowSize = 5;          % data available at a rate of approx. 1/s
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;

        % Use built-in filter function
        SIGNAL_DayN_raw_filtered = filter(b, a, raw_SIGNAL{signalCounter}{dayCounter});

        %% Parse filtered data
        % Recall that we already stored much of the other output information
        % needed. So the only thing we really need from this is to extract the
        % filtered data
        [~, SIGNAL_DayN_filtered, ~, ~] = parseVector(raw_tSIGNAL{signalCounter}{dayCounter}, SIGNAL_DayN_raw_filtered, ...
        VNS_starts(dayCounter), preVNSBuffer, VNSlength + preVNSBuffer + postVNSBuffer, 0, 0);

        %% Resample data to desired sampling rate
        % Sample time and frequency
        dt = 1;
        fs = 1/dt;

        % Resample using built-in function
        % From the documentation, resample assumes the endpoints are 0
        % This is clearly an incorrect assumption. Thus, to correct this,
        % we follow the 'Removing Endpoint Effects' section in the documentation:
        % https://www.mathworks.com/help/signal/examples/resampling-nonuniformly-sampled-signals.html

        % Unfiltered
        [SIGNAL_DayN_resampled, tSIGNAL_DayN_resampled] = clean_resample(SIGNAL_DayN, tSIGNAL_DayN_shifted, fs, 'spline');
        % Filtered
        [SIGNAL_DayN_filtered_resampled, tSIGNAL_DayN_filtered_resampled] = clean_resample(SIGNAL_DayN_filtered, tSIGNAL_DayN_shifted, fs, 'spline');
        % Make sure vectors are of appropriate length
        % If not, use interp1 to force it to be so
        % Store available times
        availableTime_SIGNAL_DayN = (VNSlength + preVNSBuffer + postVNSBuffer) - ...
            (missingEnd_SIGNAL_DayN + missingInitial_SIGNAL_DayN);

        % Create appropriate sampling time vectors
        sampleTime_SIGNAL_DayN = dt:dt:availableTime_SIGNAL_DayN;

        % Check before doing this extra operation
        % With this interpolation to a specified sampleTime vector, we're
        % guaranteeing that the vector will be of appropriate length

        % Notice that if the unfiltered version was resampled in an undesirable way,
        % the filtered version will be equivalently resampled
        if length(SIGNAL_DayN_resampled) ~= availableTime_SIGNAL_DayN
            SIGNAL_DayN_resampled = interp1(tSIGNAL_DayN_resampled, SIGNAL_DayN_resampled, ...
                sampleTime_SIGNAL_DayN, 'spline');
            SIGNAL_DayN_filtered_resampled = interp1(tSIGNAL_DayN_filtered_resampled, ...
                SIGNAL_DayN_filtered_resampled, sampleTime_SIGNAL_DayN, 'spline');
        end

        %% Normalize output vectors by appropriate resting values
        % Normalize by subtracting by and dividing by rest
        % Unfiltered
        SIGNAL_DayN_resampled_normal = (1/SIGNAL_rests{signalCounter}(dayCounter))*(SIGNAL_DayN_resampled - SIGNAL_rests{signalCounter}(dayCounter));
        % Filtered
        SIGNAL_DayN_filtered_resampled_normal = (1/SIGNAL_rests{signalCounter}(dayCounter))*(SIGNAL_DayN_filtered_resampled - SIGNAL_rests{signalCounter}(dayCounter));


        %% Create gammaCore-replicating tcVNS Input Pulses
        % Because each biomarker-administration dataset could potentially have
        % different missing dataset, each of these pulses are constructed
        % (potentially) differently
        pulse_SIGNAL_DayN = [zeros(1, round((preVNSBuffer - missingEnd_SIGNAL_DayN)/dt))...
            ones(1, round(VNSlength/dt)) zeros(1, round((postVNSBuffer - missingEnd_SIGNAL_DayN)/dt))];

        % Pass through boxcar filter to achieve ramp up and down effect
        pulse_SIGNAL_DayN = filter(b, a, pulse_SIGNAL_DayN);

        %% Transpose all row vectors for possible use into column vectors
        % Built-in model identification functions expect column vectors for data
        % So, just transpose

        % Pulse inputs
        pulse_SIGNAL_DayN = pulse_SIGNAL_DayN';

        % Unfiltered Output
        SIGNAL_DayN_resampled_normal = SIGNAL_DayN_resampled_normal';

        % Filtered Output
        SIGNAL_DayN_filtered_resampled_normal = SIGNAL_DayN_filtered_resampled_normal';

        %%
        % Now, we need to use the desired data to create iddata objects for model
        % identification
        %% Create single experiment iddata objects
        % Syntax: % data = iddata(y, u, Ts), where y is the output, u is the input,
        % and Ts is the sample time

        % From here on out, we will replicate the paper's approach in using
        % filtered biomarker data only
        SIGNAL_iddatas{signalCounter}{dayCounter} = iddata(SIGNAL_DayN_filtered_resampled_normal, pulse_SIGNAL_DayN, dt);
    end
end

% Separate out HR and PPGamp administrations for cross-validation purposes
HR_iddatas = SIGNAL_iddatas{1};
D1_1_HR = HR_iddatas{1};
D1_2_HR = HR_iddatas{2};
D2_HR = HR_iddatas{3};
D3_HR = HR_iddatas{4};

PPGamp_iddatas = SIGNAL_iddatas{2};
D1_1_PPGamp = PPGamp_iddatas{1};
D1_2_PPGamp = PPGamp_iddatas{2};
D2_PPGamp = PPGamp_iddatas{3};
D3_PPGamp = PPGamp_iddatas{4};

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

test_HR = {Test_D1_1_HR, Test_D1_2_HR, Test_D2_HR, Test_D3_HR};
test_PPGamp = {Test_D1_1_PPGamp, Test_D1_2_PPGamp, Test_D2_PPGamp, Test_D3_PPGamp};