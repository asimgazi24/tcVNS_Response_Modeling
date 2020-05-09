% This script will import the best models and solve the equations forward
% from a standardized initial equilibrium condition, applying a pulse input
% that is nonzero for some specified time window. These simulated responses
% will then be stored (e.g., for subsequent averaging and analysis, as done
% in the paper)

% I will clear the workspace and then only load the needed variables to
% free up RAM
clear all

%% Import best models
% Load the best models from the mat file where the SS models were stored
loadDataName = 'Results\Example_models_ssest.mat';

% Load testing data
load(loadDataName, ...
    'bestModel_Test_D1_1_HR', 'bestModel_Test_D1_1_PPGamp', ...
    'bestModel_Test_D1_2_HR', 'bestModel_Test_D1_2_PPGamp', ...
    'bestModel_Test_D2_HR', 'bestModel_Test_D2_PPGamp', ...
    'bestModel_Test_D3_HR', 'bestModel_Test_D3_PPGamp')

%% Recreate the pulse input used during modeling
% To match the conditions used to produce the data average experimentation
% results, we have 10 seconds before stimulation, 120 seconds of
% stimulation, and 110 seconds after stimulation
timeBefore = 10;
timeAfter = 110;
VNSlength = 120;

% Rect pulse
dummyData = [zeros(timeBefore, 1); ones(VNSlength, 1); zeros(timeAfter, 1)];

% Filter to obtain ramp up and down effect
windowSize = 5;
b = (1/windowSize)*ones(1,windowSize);
a = 1;

inputData = filter(b, a, dummyData);

%% Compute the pulse responses
% There happens to be a function in MATLAB built for this :)
% Regardless, this could be done by writing your own function that simply
% solves the difference equations forward in time using a for loop,
% ensuring that the initial state is set to the 0 vector

pulseResponse_Test_D1_1_HR = sim(bestModel_Test_D1_1_HR, inputData);
pulseResponse_Test_D1_1_PPGamp = sim(bestModel_Test_D1_1_PPGamp, inputData);

pulseResponse_Test_D1_2_HR = sim(bestModel_Test_D1_2_HR, inputData);
pulseResponse_Test_D1_2_PPGamp = sim(bestModel_Test_D1_2_PPGamp, inputData);

pulseResponse_Test_D2_HR = sim(bestModel_Test_D2_HR, inputData);
pulseResponse_Test_D2_PPGamp = sim(bestModel_Test_D2_PPGamp, inputData);

pulseResponse_Test_D3_HR = sim(bestModel_Test_D3_HR, inputData);
pulseResponse_Test_D3_PPGamp = sim(bestModel_Test_D3_PPGamp, inputData);


%% Output all responses to an excel doc (in case needed)
% Create table with all desired values
excelResults = table(pulseResponse_Test_D1_1_HR, ...
    pulseResponse_Test_D1_1_PPGamp, ...
    pulseResponse_Test_D1_2_HR, pulseResponse_Test_D1_2_PPGamp, ...
    pulseResponse_Test_D2_HR, pulseResponse_Test_D2_PPGamp, ...
    pulseResponse_Test_D3_HR, pulseResponse_Test_D3_PPGamp);

% Write the results to the specified file
writefilename = 'Results\pulseResponses.csv';
writetable(excelResults,writefilename)

%% Save MATLAB workspace
% Save as mat file
saveDataName = 'Results\Example_pulseResponses.mat';
save(saveDataName)
