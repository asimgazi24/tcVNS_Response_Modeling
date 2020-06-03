% This code requires that the signal processing  and system identification
% toolboxes be installed

% This script performs all the state-space modeling steps:
% 1. Iterate over model order and input delay simultaneously
% 2. Select best model order and input delay combo using min(AICc)
% 3. Take that structure and implement ridge regression by iterating
%    logarithmically over lambda
% 4. Select best lambda using min(AICc)
% 5. Compute test fit percentages using compare()
% 6. Store best model order, best input delay, and fit percentages
% 7. Output values above to excel doc
% 8. Save workspace

% Recall that the "Test" in the variable names corresponds to the
% administration that needs to be tested on

maxModelOrder = 10;     % Maximum model order
maxInputDelay = 35;     % Maximum input delay
sampleTime = 1;         % Sample time of iddata

% Create regularization lambda vector in a log plot varying fashion
minDecade = -15;        % Chosen as minimum because eps = 2e-16 (approx.)
maxDecade = 4;
Lambda = zeros(1, (maxDecade - minDecade)*9 + 1);
Lambda(1) = 10^minDecade;

for i = 2:length(Lambda)
    Lambda(i) = Lambda(i-1) + 10^floor(((i-2)/9) + minDecade);
end

% Enforces stability for later ssest estimation
% Stability ensures that states return to equilibrium once all inputs
% subside
stateSpaceOptions = ssestOptions('EnforceStability', true);

%% Create structs to store all (unregularized) models estimated
% Naming format: ssest_Test_[administration](modelOrder, inputDelay).[biomarker]

% Here, I create a structure that has 2 accessible properties and then I
% repeat that as a 2-D matrix maxModelOrder x maxInputDelay times
ssest_Test = {};
for i = 1:4
    ssest_Test{i} = repmat(struct('HR',struct(idss),...
        'PPGamp',struct(idss)), maxModelOrder, maxInputDelay+1);
end

%% Create arrays for AICc values so I can later select the best model
% I need to save one AICc value for each model structure configuration
AICc_ssest_Test_HR = {};
AICc_ssest_Test_PPGamp = {};
for dayCounter = 1:4
    AICc_ssest_Test_HR{dayCounter} = zeros(maxModelOrder, maxInputDelay+1);
    AICc_ssest_Test_PPGamp{dayCounter} = zeros(maxModelOrder, maxInputDelay+1);
end

%% Estimate all possible models for each biomarker of each administration and store AICc values
% Nested for loop to iterate over all model orders and all input delays
for i = 1:maxModelOrder
    for j = 0:maxInputDelay
        for dayCounter = 1:4
            % Estimate models using ssest() function for
            % N4SID estimation followed by prediction error minimization (PEM)
            
            ssest_Test{dayCounter}(i, j+1).HR = ssest(test_HR{dayCounter}, i, stateSpaceOptions, ...
                'InputDelay', j, 'Form', 'modal', 'Ts', sampleTime);
            ssest_Test{dayCounter}(i, j+1).PPGamp = ssest(test_PPGamp{dayCounter}, i, stateSpaceOptions, ...
                'InputDelay', j, 'Form', 'modal', 'Ts', sampleTime);
            
            AICc_ssest_Test_HR{dayCounter}(i,j+1) =  ssest_Test{dayCounter}(i,j+1).HR.Report.Fit.AICc;
            AICc_ssest_Test_PPGamp{dayCounter}(i,j+1) =  ssest_Test{dayCounter}(i,j+1).PPGamp.Report.Fit.AICc;
            
            
        end
        % Display model estimation status for user
        timeNow = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z');
        disp(['Done with model order ', num2str(i), ' and input delay ',...
            num2str(j), ' at ', datestr(timeNow)])
    end
end


%% Determine best model order and input delay by minimizing AICc
% min() of a matrix returns the minimum of each column and the associated
% row indices. Taking the minimum of those column mins would return the
% minimum over the entire matrix; the associated index would tell you in
% which column the minimum was in (best input delay). Then taking the row
% index associated with that minimum column index will give you the
% minRowIndex, i.e., the best model order, because the row indices vector
% would have already stored the associated row indices for each columnMin
bestInputDelay_ssest_Test_HR = {};
bestInputDelay_ssest_Test_PPGamp = {};
bestModelOrder_ssest_Test_HR = {};
bestModelOrder_ssest_Test_PPGamp = {};
bestAICc_ssest_Test_HR = {};
bestAICc_ssest_Test_PPGamp = {};

for dayCounter = 1:4
    [columnMin, RowIndices] = min(AICc_ssest_Test_HR{dayCounter});
    [bestAICc_ssest_Test_HR{dayCounter}, minColumnIndex] = min(columnMin);
    bestInputDelay_ssest_Test_HR{dayCounter} = minColumnIndex - 1;
    bestModelOrder_ssest_Test_HR{dayCounter} = RowIndices(minColumnIndex);
    
    [columnMin, RowIndices] = min(AICc_ssest_Test_PPGamp{dayCounter});
    [bestAICc_ssest_Test_PPGamp{dayCounter}, minColumnIndex] = min(columnMin);
    bestInputDelay_ssest_Test_PPGamp{dayCounter} = minColumnIndex - 1;
    bestModelOrder_ssest_Test_PPGamp{dayCounter} = RowIndices(minColumnIndex);
end


%% Create structs to store regularized models
% Naming format: regBest_ssest_Test_[administration](lambdaIndex).[biomarker]
regBest_ssest_Test = {};
for dayCounter = 1:4
    regBest_ssest_Test{dayCounter} = repmat(struct('HR',struct(idss),...
        'PPGamp',struct(idss)), 1, length(Lambda));
end


%% Create new AICc vectors so I can later select the best lambda
% We will store one AICc value per lambda
regBest_AICc_ssest_Test_HR = {};
regBest_AICc_ssest_Test_PPGamp = {};
for dayCounter = 1:4
    regBest_AICc_ssest_Test_HR{dayCounter} = zeros(1, length(Lambda));
    regBest_AICc_ssest_Test_PPGamp{dayCounter} = zeros(1, length(Lambda));
end

%% Estimate all regularized models for the best model order and input delay combo
% For loop to iterate over lambda
for i = 1:length(Lambda)
    % Set lambda
    stateSpaceOptions.Regularization.Lambda = Lambda(i);
    
    % Estimate models
    
    for dayCounter = 1:4
        % Estimate models
        regBest_ssest_Test{dayCounter}(i).HR = ssest(test_HR{dayCounter}, ...
            bestModelOrder_ssest_Test_HR{dayCounter}, stateSpaceOptions, ...
            'InputDelay', bestInputDelay_ssest_Test_HR{dayCounter}, 'Form', 'modal', ...
            'Ts', sampleTime);
        regBest_ssest_Test{dayCounter}(i).PPGamp = ssest(test_PPGamp{dayCounter}, ...
            bestModelOrder_ssest_Test_PPGamp{dayCounter}, stateSpaceOptions, ...
            'InputDelay', bestInputDelay_ssest_Test_PPGamp{dayCounter}, 'Form', 'modal', ...
            'Ts', sampleTime);
        
        % Store AICc values
        regBest_AICc_ssest_Test_HR{dayCounter}(i) =  ...
            regBest_ssest_Test{dayCounter}(i).HR.Report.Fit.AICc;
        regBest_AICc_ssest_Test_PPGamp{dayCounter}(i) =  ...
            regBest_ssest_Test{dayCounter}(i).PPGamp.Report.Fit.AICc;
        
    end
    
    % Display model estimation status for user
    timeNow = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z');
    disp(['Done with lambda ', num2str(Lambda(i)), ' at ', datestr(timeNow)])
end

%% Determine best lambda for each biomarker for each VNS administration
regBest_bestAICc_ssest_Test_HR = {};
regBest_bestAICc_ssest_Test_PPGamp = {};
bestLambdaIndex_ssest_Test_HR = {};
bestLambdaIndex_ssest_Test_PPGamp = {};

for dayCounter = 1:4
    [regBest_bestAICc_ssest_Test_HR{dayCounter}, bestLambdaIndex_ssest_Test_HR{dayCounter}] = ...
        min(regBest_AICc_ssest_Test_HR{dayCounter});
    [regBest_bestAICc_ssest_Test_PPGamp{dayCounter}, bestLambdaIndex_ssest_Test_PPGamp{dayCounter}] = ...
        min(regBest_AICc_ssest_Test_PPGamp{dayCounter});
end



%% Store lambda value for the best regularized models
% Access the lambda vector element of the best lambda index
bestLambda_ssest_Test_HR = {};
bestLambda_ssest_Test_PPGamp = {};
for dayCounter = 1:4
    bestLambda_ssest_Test_HR{dayCounter} = Lambda(bestLambdaIndex_ssest_Test_HR{dayCounter});
    bestLambda_ssest_Test_PPGamp{dayCounter} = Lambda(bestLambdaIndex_ssest_Test_PPGamp{dayCounter});
end


%% For future use, store separately the optimum models
% Access the model stored in the regularized structs associated with the
% best lambda index
bestModel_Test_HR = {};
bestModel_Test_PPGamp = {};

for dayCounter = 1:4
    bestModel_Test_HR{dayCounter} = regBest_ssest_Test{dayCounter}(...
        bestLambdaIndex_ssest_Test_HR{dayCounter}).HR;
    bestModel_Test_PPGamp{dayCounter} = regBest_ssest_Test{dayCounter}(...
        bestLambdaIndex_ssest_Test_PPGamp{dayCounter}).PPGamp;
end


%% Using the compare command, store 1-step ahead fit percentages
% Syntax: [~, fit %, ~] = compare(test data, model, steps);
fit_1step_ssest_Test_HR = {};
fit_1step_ssest_Test_PPGamp = {};

for dayCounter = 1:4
    [~, fit_1step_ssest_Test_HR{dayCounter}, ~] = compare(HR_iddatas{dayCounter}, ...
        bestModel_Test_HR{dayCounter}, 1);
    [~, fit_1step_ssest_Test_PPGamp{dayCounter}, ~] = compare(PPGamp_iddatas{dayCounter}, ...
        bestModel_Test_PPGamp{dayCounter}, 1);
end



%% Store all desired values in a table and export to excel doc
% Create table with all desired values
excelResults = table(...
    bestModelOrder_ssest_Test_HR, ...
    bestInputDelay_ssest_Test_HR, ...
    fit_1step_ssest_Test_HR, ...
    bestModelOrder_ssest_Test_PPGamp, ...
    bestInputDelay_ssest_Test_PPGamp, ...
    fit_1step_ssest_Test_PPGamp);

% Write the results to the specified file
filename = 'Results\ModelingOutput.csv';
writetable(excelResults,filename)

%% Save MATLAB workspace
% The best models will be needed for further analysis
saveDataName = 'Results\Example_models_ssest.mat';
save(saveDataName)
