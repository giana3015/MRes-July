clc; clear; close all;

% === CONFIGURATION ===
rootFolder = '/home/barrylab/Documents/Giana/Data';
binSize_cm = 2;
threshold_frac = 0.3;

% === FIND ALL FILES ===
files = dir(fullfile(rootFolder, 'm*', 'PC_ratemaps', 'ratemap_cell*.mat'));

% === Prepare a container for all data ===
allRows = {};

for f = 1:length(files)
    filePath = fullfile(files(f).folder, files(f).name);

    % Parse path to get Mouse ID and Date
    parts = strsplit(filePath, filesep);
    mouseID = parts{end-2};
    dateStr = parts{end-1};
    fileName = files(f).name;

    % Extract cell and trial number from filename
    tokens = regexp(fileName, 'cell(\d+)trail(\d+)', 'tokens');
    if isempty(tokens)
        warning('Could not parse cell/trial from: %s — skipping.', fileName);
        continue;
    end
    cellNum = str2double(tokens{1}{1});
    trialNum = str2double(tokens{1}{2});

    % Load ratemap
    S = load(filePath);
    vars = fieldnames(S);
    ratemap = S.(vars{1});

    % Handle empty or invalid maps
    if isempty(ratemap) || all(isnan(ratemap(:)))
        peak = NaN;
        fieldSize = NaN;
    else
        peak = max(ratemap(:), [], 'omitnan');
        thresh = threshold_frac * peak;
        binaryField = ratemap > thresh;
        binaryField = bwareaopen(binaryField, 5);
        nBins = sum(binaryField(:));
        fieldSize = nBins * binSize_cm^2;
    end

    % Append row
    allRows{end+1, 1} = {mouseID, dateStr, cellNum, trialNum, peak, fieldSize, fileName};
end

% === Convert to table and write single CSV ===
T = cell2table(vertcat(allRows{:}), ...
    'VariableNames', {'MouseID', 'Date', 'Cell', 'Trial', 'PeakRate_Hz', 'FieldSize_cm2', 'FileName'});

% Save it
outPath = fullfile(rootFolder, 'place_field_metrics_all_mice.csv');
writetable(T, outPath);

fprintf('\n✅ All data saved to: %s\n', outPath);