clc; clear; close all;

% === CONFIGURATION ===
rootFolder = '/home/barrylab/Documents/Giana/Data';
binSize_cm = 2;
threshold_frac = 0.3;
outputCSV = fullfile(rootFolder, 'place_field_metrics_all_mice.csv');

% === FIND ALL PC_ratemaps FOLDERS ===
folders = dir(fullfile(rootFolder, 'm*', '2*', 'PC_ratemaps'));
fprintf('🔍 Found %d PC_ratemaps folders.\n', length(folders));

allRows = {};

for k = 1:length(folders)
    pcFolder = fullfile(folders(k).folder, folders(k).name);

    % ✅ Extract MouseID and Date from folder path
    splitPath = split(pcFolder, filesep);
    mouseID = splitPath{end-2};  % e.g. 'm4005'
    dateStr = splitPath{end-1};  % e.g. '20200924'

    files = dir(fullfile(pcFolder, 'ratemap*.mat'));
    fprintf('📂 %s | %s | %d ratemaps\n', mouseID, dateStr, length(files));

    for f = 1:length(files)
        filePath = fullfile(files(f).folder, files(f).name);
        fileName = files(f).name;

        % === EXTRACT CELL/TRIAL NUMBERS ===
        tokens = regexp(fileName, 'cell(\d+)_trial(\d+)', 'tokens', 'once');
        if isempty(tokens)
            cellNum = f;
            trialNum = NaN;
            warning('⚠️ Could not parse cell/trial from: %s', fileName);
        else
            cellNum = str2double(tokens{1});
            trialNum = str2double(tokens{2});
        end

        % === LOAD RATEMAP ===
        S = load(filePath);
        vars = fieldnames(S);
        ratemap = S.(vars{1});  % assumes 1 variable per file

        % === COMPUTE PEAK + FIELD SIZE ===
        if ~isnumeric(ratemap) || isempty(ratemap) || all(isnan(ratemap(:)))
            warning('⚠️ Skipping invalid or non-numeric file: %s', fileName);
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

        % ✅ APPEND ROW (FLAT, NOT NESTED)
        allRows(end+1, :) = {mouseID, dateStr, cellNum, trialNum, peak, fieldSize, fileName};
    end
end

% === SAVE TO CSV ===
fid = fopen(outputCSV, 'w');
fprintf(fid, 'MouseID,Date,Cell,Trial,PeakRate_Hz,FieldSize_cm2,FileName\n');

for i = 1:size(allRows, 1)
    fprintf(fid, '%s,%s,%g,%g,%.4f,%.4f,%s\n', ...
        allRows{i,1}, allRows{i,2}, allRows{i,3}, allRows{i,4}, ...
        allRows{i,5}, allRows{i,6}, allRows{i,7});
end

fclose(fid);
fprintf('\n✅ Master CSV saved to:\n%s\n', outputCSV);