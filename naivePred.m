function naivePrediction = naivePred(trueData)

% Initialize naivePrediction vector
naivePrediction = zeros(length(trueData),1);

% Store initial condition of naive prediction
naivePrediction(1) = trueData(1);

% The naive predictor simply predicts the next time point will be the
% present time point, i.e., naivePrediction(2) = trueData(1),
% naivePrediction(3) = trueData(2), ..., naivePrediction(N) = trueData(N-1)
for i = 2:length(trueData)
    naivePrediction(i) = trueData(i-1);
end