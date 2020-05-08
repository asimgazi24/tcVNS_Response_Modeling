function [outputData, outputTime] = clean_resample(OG_data, OG_time, fs, method)

% The point of this function is to resample, but to remove the endpoint
% effects

% outputData: resultant "clean" resampled data
% outputTime: corresponding time vector

% OG_data: original data
% OG_time: original time (nonuniform)

% fs: desired sampling frequency

% method: desired interpolation method


% compute slope and offset
a(1) = (OG_data(end) - OG_data(1)) / (OG_time(end) - OG_time(1));
a(2) = OG_data(1);

% detrend the signal
xdetrend = OG_data - polyval(a, OG_time)';

% resample using desired method at desired sampling frequency
[ydetrend, outputTime] = resample(xdetrend, OG_time, fs, method);

% add back the trend and return result
outputData = ydetrend + polyval(a, outputTime)';
