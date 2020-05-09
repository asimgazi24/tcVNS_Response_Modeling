% This script runs all the constituent necessary scripts to reproduce
% results using the example dataset included

clear all

% Prep biomarker series for modeling
modelingPrep

% State-space modeling
ssestModeling

% Compute Naive Predictor Fit Percentages
naivePrediction_fitPercentages

% Note that resampled experimental responses can be created by simply
% loading the unfiltered, resampled, and normalized time series
% produced and stored in the output from the ssestModeling script. From
% there, averaging should hopefully be straightforward enough 
% (accordingly, no example code is provided)

% Thus, the final analysis step that readily available code would help in
% elucidating is the simulated model response analysis

% Simulate model responses
simulate_modelResponses


