% This (recursive) function will parse vectors based on provided info
function [newTimeVector, newSignalVector, missingInitial, missingEnd] = ...
    parseVector_v2(oldTimeVector, oldSignalVector, startTime, ...
    preBufferLength, timeLength, initialDataCount, endDataCount)

% missingInitial: the amount of time not available at the beginning of the
% old data vector

% missingEnd: the amount of time not available at the end of the old data
% vector

% startTime: the start time of either the VNS or trauma script

% preBufferLength: the amount of time before the actual start you want
% to start parsing from

% timeLength: the length of your vector in time, i.e. how many seconds 
% of data do you want

% initialDataCount: Count of how many initial datapoints are missing (used
% for recursive function call)

% endDataCount: Count of how many end datapoints are missing (used for
% recursive function call)


% First time value for the new vectors
initialTime = startTime - preBufferLength;

% End time value for the new vectors
endTime = initialTime + timeLength;

% Check to make sure problem is well posed (and recursive function usage
% near the end of code does not get stuck in infinite loop)
if endTime <= initialTime
    newTimeVector = NaN;
    newSignalVector = NaN;
    disp('WARNING: Parsing not well posed or significant data missing')
    disp('Corresponding time vector and signal vector marked as NaN')
    return
end

initialIndex = -1;
endIndex = -1;

% Search time vector for initial time and end time
for i = 1:length(oldTimeVector)
    if round(oldTimeVector(i)) == initialTime
        initialIndex = i;
    end
    
    if round(oldTimeVector(i)) == endTime
        endIndex = i;
        break
    end
end

% If indexes were not found via rounding, try flooring and ceiling
if initialIndex == -1
    for i = 1:length(oldTimeVector)
        if ceil(oldTimeVector(i)) == initialTime
            initialIndex = i;
            break
        end
        
        if floor(oldTimeVector(i)) == initialTime
            initialIndex = i;
            break
        end
    end
end

if endIndex == -1
    for i = 1:length(oldTimeVector)
        if ceil(oldTimeVector(i)) == endTime
            endIndex = i;
            break
        end
        
        if floor(oldTimeVector(i)) == endTime
            endIndex = i;
            break
        end
    end
end

% If the endIndex and/or the initialIndex was/were still not found, we can
% recursively search for good end and initial indices.

% TO UNDERSTAND THIS PART OF THE CODE, DRAW IT OUT!!
% THE SUBTRACTIONS WILL MAKE SENSE THEN :)
% In case both were not found
if endIndex == -1 && initialIndex == -1
    timeLength = timeLength - 2;
    preBufferLength = preBufferLength - 1;
    [newTimeVector, newSignalVector, missingInitial, missingEnd] = ...
    parseVector_v2(oldTimeVector, oldSignalVector, startTime, ...
    preBufferLength, timeLength, initialDataCount + 1, endDataCount + 1);
    return
% In case only the endIndex wasn't found
elseif endIndex == -1
    timeLength = timeLength - 1;
   [newTimeVector, newSignalVector, missingInitial, missingEnd] = ...
    parseVector_v2(oldTimeVector, oldSignalVector, startTime, ...
    preBufferLength, timeLength, initialDataCount, endDataCount + 1);
    return
% In case only the initialIndex wasn't found
elseif initialIndex == -1
    preBufferLength = preBufferLength - 1;
    timeLength = timeLength - 1;
    [newTimeVector, newSignalVector, missingInitial, missingEnd] = ...
    parseVector_v2(oldTimeVector, oldSignalVector, startTime, ...
    preBufferLength, timeLength, initialDataCount + 1, endDataCount);
    return
end


% If function reaches here, that means that an appropriate initialIndex and
% endIndex were eventually arrived at
missingInitial = initialDataCount;
missingEnd = endDataCount;

% Initializations
j = 1;      % Used in for loop below
newTimeVector = zeros(endIndex - initialIndex + 1, 1);
newSignalVector = zeros(1, endIndex - initialIndex + 1);

% Create new time and signal vectors
for i = initialIndex:endIndex
    newTimeVector(j) = oldTimeVector(i);
    newSignalVector(j) = oldSignalVector(i);
    j = j + 1;
end

return