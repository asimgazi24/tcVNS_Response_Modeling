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
load(loadDataName, 'bestModel_Test_HR', 'bestModel_Test_PPGamp')

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
pulseResponse_Test_HR = {};
pulseResponse_Test_PPGamp = {};

for dayCounter = 1:4
    pulseResponse_Test_HR{dayCounter} = sim(bestModel_Test_HR{dayCounter}, inputData);
    pulseResponse_Test_PPGamp{dayCounter} = sim(bestModel_Test_PPGamp{dayCounter}, inputData);
end

%% Output all responses to an excel doc (in case needed)
% Since each response itself is a vector, let's first convert from cell
% arrays back to matrices and then instead use the writematrix() function.
% In this way, the output will be formatted as each pulse response its own
% column vector, so 4 columns per biomarker (corresponding to the 4
% administrations)

% Initialize matrix for output
excelResults = zeros(length(pulseResponse_Test_HR{1}), 8);

% Store the simulated responses day by day
for dayCounter = 1:4
    excelResults(:, dayCounter) = pulseResponse_Test_HR{dayCounter};
    excelResults(:, dayCounter+4) = pulseResponse_Test_PPGamp{dayCounter};
end

% Write the results to the specified file
% Format:
% Column 1 - Model tested on D1_1 HR
% Column 2 - Model tested on D1_2 HR
% Column 3 - Model tested on D2 HR
% Column 4 - Model tested on D3 HR
% Column 5 - Model tested on D1_1 PPGamp
% Column 6 - Model tested on D1_2 PPGamp
% Column 7 - Model tested on D2 PPGamp
% Column 8 - Model tested on D3 PPGamp
writefilename = 'Results\pulseResponses.csv';
writematrix(excelResults,writefilename)

%% Save MATLAB workspace
% Save as mat file
saveDataName = 'Results\Example_pulseResponses.mat';
save(saveDataName)
