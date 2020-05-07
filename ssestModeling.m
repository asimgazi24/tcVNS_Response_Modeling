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
ssest_Test_D1_1 = repmat(struct('HR',struct(idss),...
    'PPGamp',struct(idss)), maxModelOrder, maxInputDelay+1);
ssest_Test_D1_2 = repmat(struct('HR',struct(idss),...
    'PPGamp',struct(idss)), maxModelOrder, maxInputDelay+1);
ssest_Test_D2 = repmat(struct('HR',struct(idss),...
    'PPGamp',struct(idss)), maxModelOrder, maxInputDelay+1);
ssest_Test_D3 = repmat(struct('HR',struct(idss),...
    'PPGamp',struct(idss)), maxModelOrder, maxInputDelay+1);

%% Create arrays for AICc values so I can later select the best model
% I need to save one AICc value for each model structure configuration
AICc_ssest_Test_D1_1_HR = zeros(maxModelOrder, maxInputDelay+1);
AICc_ssest_Test_D1_1_PPGamp = zeros(maxModelOrder, maxInputDelay+1);

AICc_ssest_Test_D1_2_HR = zeros(maxModelOrder, maxInputDelay+1);
AICc_ssest_Test_D1_2_PPGamp = zeros(maxModelOrder, maxInputDelay+1);

AICc_ssest_Test_D2_HR = zeros(maxModelOrder, maxInputDelay+1);
AICc_ssest_Test_D2_PPGamp = zeros(maxModelOrder, maxInputDelay+1);

AICc_ssest_Test_D3_HR = zeros(maxModelOrder, maxInputDelay+1);
AICc_ssest_Test_D3_PPGamp = zeros(maxModelOrder, maxInputDelay+1);


%% Estimate all possible models for each biomarker of each administration and store AICc values
% Nested for loop to iterate over all model orders and all input delays
for i = 1:maxModelOrder
    for j = 0:maxInputDelay
        % Estimate models using ssest() function for 
        % N4SID estimation followed by prediction error minimization (PEM)
        ssest_Test_D1_1(i, j+1).HR = ssest(Test_D1_1_HR, i, stateSpaceOptions, ...
            'InputDelay', j, 'Form', 'modal', 'Ts', sampleTime);
        ssest_Test_D1_1(i, j+1).PPGamp = ssest(Test_D1_1_PPGamp, i, stateSpaceOptions, ...
            'InputDelay', j, 'Form', 'modal', 'Ts', sampleTime);
        
        ssest_Test_D1_2(i, j+1).HR = ssest(Test_D1_2_HR, i, stateSpaceOptions, ...
            'InputDelay', j, 'Form', 'modal', 'Ts', sampleTime);
        ssest_Test_D1_2(i, j+1).PPGamp = ssest(Test_D1_2_PPGamp, i, stateSpaceOptions, ...
            'InputDelay', j, 'Form', 'modal', 'Ts', sampleTime);
        
        ssest_Test_D2(i, j+1).HR = ssest(Test_D2_HR, i, stateSpaceOptions, ...
            'InputDelay', j, 'Form', 'modal', 'Ts', sampleTime);
        ssest_Test_D2(i, j+1).PPGamp = ssest(Test_D2_PPGamp, i, stateSpaceOptions, ...
            'InputDelay', j, 'Form', 'modal', 'Ts', sampleTime);
        
        ssest_Test_D3(i, j+1).HR = ssest(Test_D3_HR, i, stateSpaceOptions, ...
            'InputDelay', j, 'Form', 'modal', 'Ts', sampleTime);
        ssest_Test_D3(i, j+1).PPGamp = ssest(Test_D3_PPGamp, i, stateSpaceOptions, ...
            'InputDelay', j, 'Form', 'modal', 'Ts', sampleTime);
        
        % Store AICc values
        AICc_ssest_Test_D1_1_HR(i,j+1) =  ssest_Test_D1_1(i,j+1).HR.Report.Fit.AICc;
        AICc_ssest_Test_D1_1_PPGamp(i,j+1) =  ssest_Test_D1_1(i,j+1).PPGamp.Report.Fit.AICc;
        
        AICc_ssest_Test_D1_2_HR(i,j+1) =  ssest_Test_D1_2(i,j+1).HR.Report.Fit.AICc;
        AICc_ssest_Test_D1_2_PPGamp(i,j+1) =  ssest_Test_D1_2(i,j+1).PPGamp.Report.Fit.AICc;
        
        AICc_ssest_Test_D2_HR(i,j+1) =  ssest_Test_D2(i,j+1).HR.Report.Fit.AICc;
        AICc_ssest_Test_D2_PPGamp(i,j+1) =  ssest_Test_D2(i,j+1).PPGamp.Report.Fit.AICc;
        
        AICc_ssest_Test_D3_HR(i,j+1) =  ssest_Test_D3(i,j+1).HR.Report.Fit.AICc;
        AICc_ssest_Test_D3_PPGamp(i,j+1) =  ssest_Test_D3(i,j+1).PPGamp.Report.Fit.AICc;
        
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

% D1_1
[columnMin, RowIndices] = min(AICc_ssest_Test_D1_1_HR);
[bestAICc_ssest_Test_D1_1_HR, minColumnIndex] = min(columnMin);
bestInputDelay_ssest_Test_D1_1_HR = minColumnIndex;
bestModelOrder_ssest_Test_D1_1_HR = RowIndices(minColumnIndex);

[columnMin, RowIndices] = min(AICc_ssest_Test_D1_1_PPGamp);
[bestAICc_ssest_Test_D1_1_PPGamp, minColumnIndex] = min(columnMin);
bestInputDelay_ssest_Test_D1_1_PPGamp = minColumnIndex;
bestModelOrder_ssest_Test_D1_1_PPGamp = RowIndices(minColumnIndex);

% D1_2
[columnMin, RowIndices] = min(AICc_ssest_Test_D1_2_HR);
[bestAICc_ssest_Test_D1_2_HR, minColumnIndex] = min(columnMin);
bestInputDelay_ssest_Test_D1_2_HR = minColumnIndex;
bestModelOrder_ssest_Test_D1_2_HR = RowIndices(minColumnIndex);

[columnMin, RowIndices] = min(AICc_ssest_Test_D1_2_PPGamp);
[bestAICc_ssest_Test_D1_2_PPGamp, minColumnIndex] = min(columnMin);
bestInputDelay_ssest_Test_D1_2_PPGamp = minColumnIndex;
bestModelOrder_ssest_Test_D1_2_PPGamp = RowIndices(minColumnIndex);

% D2
[columnMin, RowIndices] = min(AICc_ssest_Test_D2_HR);
[bestAICc_ssest_Test_D2_HR, minColumnIndex] = min(columnMin);
bestInputDelay_ssest_Test_D2_HR = minColumnIndex;
bestModelOrder_ssest_Test_D2_HR = RowIndices(minColumnIndex);

[columnMin, RowIndices] = min(AICc_ssest_Test_D2_PPGamp);
[bestAICc_ssest_Test_D2_PPGamp, minColumnIndex] = min(columnMin);
bestInputDelay_ssest_Test_D2_PPGamp = minColumnIndex;
bestModelOrder_ssest_Test_D2_PPGamp = RowIndices(minColumnIndex);

% D3
[columnMin, RowIndices] = min(AICc_ssest_Test_D3_HR);
[bestAICc_ssest_Test_D3_HR, minColumnIndex] = min(columnMin);
bestInputDelay_ssest_Test_D3_HR = minColumnIndex;
bestModelOrder_ssest_Test_D3_HR = RowIndices(minColumnIndex);

[columnMin, RowIndices] = min(AICc_ssest_Test_D3_PPGamp);
[bestAICc_ssest_Test_D3_PPGamp, minColumnIndex] = min(columnMin);
bestInputDelay_ssest_Test_D3_PPGamp = minColumnIndex;
bestModelOrder_ssest_Test_D3_PPGamp = RowIndices(minColumnIndex);


%% Create structs to store regularized models
% Naming format: regBest_ssest_Test_[administration](lambdaIndex).[biomarker]

regBest_ssest_Test_D1_1 = repmat(struct('HR',struct(idss),...
    'PPGamp',struct(idss)), 1, length(Lambda));
regBest_ssest_Test_D1_2 = repmat(struct('HR',struct(idss),...
    'PPGamp',struct(idss)), 1, length(Lambda));
regBest_ssest_Test_D2 = repmat(struct('HR',struct(idss),...
    'PPGamp',struct(idss)), 1, length(Lambda));
regBest_ssest_Test_D3 = repmat(struct('HR',struct(idss),...
    'PPGamp',struct(idss)), 1, length(Lambda));


%% Create new AICc vectors so I can later select the best lambda
% We will store one AICc value per lambda
regBest_AICc_ssest_Test_D1_1_HR = zeros(1, length(Lambda));
regBest_AICc_ssest_Test_D1_1_PPGamp = zeros(1, length(Lambda));

regBest_AICc_ssest_Test_D1_2_HR = zeros(1, length(Lambda));
regBest_AICc_ssest_Test_D1_2_PPGamp = zeros(1, length(Lambda));

regBest_AICc_ssest_Test_D2_HR = zeros(1, length(Lambda));
regBest_AICc_ssest_Test_D2_PPGamp = zeros(1, length(Lambda));

regBest_AICc_ssest_Test_D3_HR = zeros(1, length(Lambda));
regBest_AICc_ssest_Test_D3_PPGamp = zeros(1, length(Lambda));


%% Estimate all regularized models for the best model order and input delay combo
% For loop to iterate over lambda
for i = 1:length(Lambda)
    % Set lambda
    stateSpaceOptions.Regularization.Lambda = Lambda(i);
    
    % Estimate models
    regBest_ssest_Test_D1_1(i).HR = ssest(Test_D1_1_HR, ...
        bestModelOrder_ssest_Test_D1_1_HR, stateSpaceOptions, ...
        'InputDelay', bestInputDelay_ssest_Test_D1_1_HR, 'Form', 'modal', ...
        'Ts', sampleTime);
    regBest_ssest_Test_D1_1(i).PPGamp = ssest(Test_D1_1_PPGamp, ...
        bestModelOrder_ssest_Test_D1_1_PPGamp, stateSpaceOptions, ...
        'InputDelay', bestInputDelay_ssest_Test_D1_1_PPGamp, 'Form', 'modal', ...
        'Ts', sampleTime);
    
    regBest_ssest_Test_D1_2(i).HR = ssest(Test_D1_2_HR, ...
        bestModelOrder_ssest_Test_D1_2_HR, stateSpaceOptions, ...
        'InputDelay', bestInputDelay_ssest_Test_D1_2_HR, 'Form', 'modal', ...
        'Ts', sampleTime);
    regBest_ssest_Test_D1_2(i).PPGamp = ssest(Test_D1_2_PPGamp, ...
        bestModelOrder_ssest_Test_D1_2_PPGamp, stateSpaceOptions, ...
        'InputDelay', bestInputDelay_ssest_Test_D1_2_PPGamp, 'Form', 'modal', ...
        'Ts', sampleTime);
    
    regBest_ssest_Test_D2(i).HR = ssest(Test_D2_HR, ...
        bestModelOrder_ssest_Test_D2_HR, stateSpaceOptions, ...
        'InputDelay', bestInputDelay_ssest_Test_D2_HR, 'Form', 'modal', ...
        'Ts', sampleTime);
    regBest_ssest_Test_D2(i).PPGamp = ssest(Test_D2_PPGamp, ...
        bestModelOrder_ssest_Test_D2_PPGamp, stateSpaceOptions, ...
        'InputDelay', bestInputDelay_ssest_Test_D2_PPGamp, 'Form', 'modal', ...
        'Ts', sampleTime);
    
    regBest_ssest_Test_D3(i).HR = ssest(Test_D3_HR, ...
        bestModelOrder_ssest_Test_D3_HR, stateSpaceOptions, ...
        'InputDelay', bestInputDelay_ssest_Test_D3_HR, 'Form', 'modal', ...
        'Ts', sampleTime);
    regBest_ssest_Test_D3(i).PPGamp = ssest(Test_D3_PPGamp, ...
        bestModelOrder_ssest_Test_D3_PPGamp, stateSpaceOptions, ...
        'InputDelay', bestInputDelay_ssest_Test_D3_PPGamp, 'Form', 'modal', ...
        'Ts', sampleTime);
    
    % Store AICc values
    regBest_AICc_ssest_Test_D1_1_HR(i) =  ...
        regBest_ssest_Test_D1_1(i).HR.Report.Fit.AICc;
    regBest_AICc_ssest_Test_D1_1_PPGamp(i) =  ...
        regBest_ssest_Test_D1_1(i).PPGamp.Report.Fit.AICc;
    
    regBest_AICc_ssest_Test_D1_2_HR(i) =  ...
        regBest_ssest_Test_D1_2(i).HR.Report.Fit.AICc;
    regBest_AICc_ssest_Test_D1_2_PPGamp(i) =  ...
        regBest_ssest_Test_D1_2(i).PPGamp.Report.Fit.AICc;
    
    regBest_AICc_ssest_Test_D2_HR(i) =  ...
        regBest_ssest_Test_D2(i).HR.Report.Fit.AICc;
    regBest_AICc_ssest_Test_D2_PPGamp(i) =  ...
        regBest_ssest_Test_D2(i).PPGamp.Report.Fit.AICc;
    
    regBest_AICc_ssest_Test_D3_HR(i) =  ...
        regBest_ssest_Test_D3(i).HR.Report.Fit.AICc;
    regBest_AICc_ssest_Test_D3_PPGamp(i) =  ...
        regBest_ssest_Test_D3(i).PPGamp.Report.Fit.AICc;
    
    % Display model estimation status for user
    timeNow = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z');
    disp(['Done with lambda ', num2str(Lambda(i)), ' at ', datestr(timeNow)])
end

%% Determine best lambda for each biomarker for each VNS administration
[regBest_bestAICc_ssest_Test_D1_1_HR, bestLambdaIndex_ssest_Test_D1_1_HR] = ...
    min(regBest_AICc_ssest_Test_D1_1_HR);
[regBest_bestAICc_ssest_Test_D1_1_PPGamp, bestLambdaIndex_ssest_Test_D1_1_PPGamp] = ...
    min(regBest_AICc_ssest_Test_D1_1_PPGamp);

[regBest_bestAICc_ssest_Test_D1_2_HR, bestLambdaIndex_ssest_Test_D1_2_HR] = ...
    min(regBest_AICc_ssest_Test_D1_2_HR);
[regBest_bestAICc_ssest_Test_D1_2_PPGamp, bestLambdaIndex_ssest_Test_D1_2_PPGamp] = ...
    min(regBest_AICc_ssest_Test_D1_2_PPGamp);

[regBest_bestAICc_ssest_Test_D2_HR, bestLambdaIndex_ssest_Test_D2_HR] = ...
    min(regBest_AICc_ssest_Test_D2_HR);
[regBest_bestAICc_ssest_Test_D2_PPGamp, bestLambdaIndex_ssest_Test_D2_PPGamp] = ...
    min(regBest_AICc_ssest_Test_D2_PPGamp);

[regBest_bestAICc_ssest_Test_D3_HR, bestLambdaIndex_ssest_Test_D3_HR] = ...
    min(regBest_AICc_ssest_Test_D3_HR);
[regBest_bestAICc_ssest_Test_D3_PPGamp, bestLambdaIndex_ssest_Test_D3_PPGamp] = ...
    min(regBest_AICc_ssest_Test_D3_PPGamp);


%% Store lambda value for the best regularized models
% Access the lambda vector element of the best lambda index
bestLambda_ssest_Test_D1_1_HR = Lambda(bestLambdaIndex_ssest_Test_D1_1_HR);
bestLambda_ssest_Test_D1_1_PPGamp = Lambda(bestLambdaIndex_ssest_Test_D1_1_PPGamp);

bestLambda_ssest_Test_D1_2_HR = Lambda(bestLambdaIndex_ssest_Test_D1_2_HR);
bestLambda_ssest_Test_D1_2_PPGamp = Lambda(bestLambdaIndex_ssest_Test_D1_2_PPGamp);

bestLambda_ssest_Test_D2_HR = Lambda(bestLambdaIndex_ssest_Test_D2_HR);
bestLambda_ssest_Test_D2_PPGamp = Lambda(bestLambdaIndex_ssest_Test_D2_PPGamp);

bestLambda_ssest_Test_D3_HR = Lambda(bestLambdaIndex_ssest_Test_D3_HR);
bestLambda_ssest_Test_D3_PPGamp = Lambda(bestLambdaIndex_ssest_Test_D3_PPGamp);


%% For future use, store separately the optimum models
% Access the model stored in the regularized structs associated with the
% best lambda index

bestModel_Test_D1_1_HR = regBest_ssest_Test_D1_1(...
    bestLambdaIndex_ssest_Test_D1_1_HR).HR;
bestModel_Test_D1_1_PPGamp = regBest_ssest_Test_D1_1(...
    bestLambdaIndex_ssest_Test_D1_1_PPGamp).PPGamp;

bestModel_Test_D1_2_HR = regBest_ssest_Test_D1_2(...
    bestLambdaIndex_ssest_Test_D1_2_HR).HR;
bestModel_Test_D1_2_PPGamp = regBest_ssest_Test_D1_2(...
    bestLambdaIndex_ssest_Test_D1_2_PPGamp).PPGamp;

bestModel_Test_D2_HR = regBest_ssest_Test_D2(...
    bestLambdaIndex_ssest_Test_D2_HR).HR;
bestModel_Test_D2_PPGamp = regBest_ssest_Test_D2(...
    bestLambdaIndex_ssest_Test_D2_PPGamp).PPGamp;

bestModel_Test_D3_HR = regBest_ssest_Test_D3(...
    bestLambdaIndex_ssest_Test_D3_HR).HR;
bestModel_Test_D3_PPGamp = regBest_ssest_Test_D3(...
    bestLambdaIndex_ssest_Test_D3_PPGamp).PPGamp;


%% Using the compare command, store 1-step ahead fit percentages
% Syntax: [~, fit %, ~] = compare(test data, model, steps);
[~, fit_1step_ssest_Test_D1_1_HR, ~] = compare(D1_1_HR, ...
    bestModel_Test_D1_1_HR, 1);
[~, fit_1step_ssest_Test_D1_1_PPGamp, ~] = compare(D1_1_PPGamp, ...
    bestModel_Test_D1_1_PPGamp, 1);

[~, fit_1step_ssest_Test_D1_2_HR, ~] = compare(D1_2_HR, ...
    bestModel_Test_D1_2_HR, 1);
[~, fit_1step_ssest_Test_D1_2_PPGamp, ~] = compare(D1_2_PPGamp, ...
    bestModel_Test_D1_2_PPGamp, 1);

[~, fit_1step_ssest_Test_D2_HR, ~] = compare(D2_HR, ...
    bestModel_Test_D2_HR, 1);
[~, fit_1step_ssest_Test_D2_PPGamp, ~] = compare(D2_PPGamp, ...
    bestModel_Test_D2_PPGamp, 1);

[~, fit_1step_ssest_Test_D3_HR, ~] = compare(D3_HR, ...
    bestModel_Test_D3_HR, 1);
[~, fit_1step_ssest_Test_D3_PPGamp, ~] = compare(D3_PPGamp, ...
    bestModel_Test_D3_PPGamp, 1);


%% Store all desired values in a table and export to excel doc
% Create table with all desired values
excelResults = table(...
    bestModelOrder_ssest_Test_D1_1_HR, ...
    bestInputDelay_ssest_Test_D1_1_HR, fit_1step_ssest_Test_D1_1_HR, ...
    bestModelOrder_ssest_Test_D1_1_PPGamp, ...
    bestInputDelay_ssest_Test_D1_1_PPGamp, fit_1step_ssest_Test_D1_1_PPGamp, ...
    bestModelOrder_ssest_Test_D1_2_HR, ...
    bestInputDelay_ssest_Test_D1_2_HR, fit_1step_ssest_Test_D1_2_HR, ...
    bestModelOrder_ssest_Test_D1_2_PPGamp, ...
    bestInputDelay_ssest_Test_D1_2_PPGamp, fit_1step_ssest_Test_D1_2_PPGamp, ...
    bestModelOrder_ssest_Test_D2_HR, ...
    bestInputDelay_ssest_Test_D2_HR, fit_1step_ssest_Test_D2_HR, ...
    bestModelOrder_ssest_Test_D2_PPGamp, ...
    bestInputDelay_ssest_Test_D2_PPGamp, fit_1step_ssest_Test_D2_PPGamp, ...
    bestModelOrder_ssest_Test_D3_HR, ...
    bestInputDelay_ssest_Test_D3_HR, fit_1step_ssest_Test_D3_HR, ...
    bestModelOrder_ssest_Test_D3_PPGamp, ...
    bestInputDelay_ssest_Test_D3_PPGamp, fit_1step_ssest_Test_D3_PPGamp);

% Write the results to the specified file
filename = 'Results\ModelingOutput.csv';
writetable(excelResults,filename)

%% Save MATLAB workspace
% The best models will be needed for further analysis
saveDataName = 'Results\Example_models_ssest.mat';
save(saveDataName)
