basePath = '/home/barrylab/Documents/Giana/Data';
mouseID = 'm4610';
dayName = '20220521';

dataFolder = fullfile(basePath, mouseID, dayName, 'PC_ratemaps');

% Number of .mat files in folder = Total ratemaps / 10 trials = Total cells
matFiles = dir(fullfile(dataFolder, '*.mat')); 
cellIDs = zeros(length(matFiles), 1);

% Get the IDs of the cells using the regexp function 
% Doesn't matter if you dont understand but atleast you know roughly
% Takes the number after cell, returns as a 'tokens'
% Checks whether tokens is empty, if not -> add it to CellIDs
for i = 1:length(matFiles)
    filename = matFiles(i).name;
    tokens = regexp(filename, 'cell(\d+)_', 'tokens');
    if ~isempty(tokens)
        cellIDs(i) = str2double(tokens{1}{1});
    end
end

uniqueCellIDs = unique(cellIDs);
numCells = length(uniqueCellIDs);

exampleRatemapFile = load(fullfile(dataFolder, filename));
exampleRateMap = size(exampleRatemapFile.rm);
% Initialise array for all ratemaps of cell (10 trials)
groupedRatemaps = zeros(exampleRateMap(1), exampleRateMap(2), 10);


main_corr_matrix = zeros(10, 10);
main_NaN_counter = zeros(10,10);

for id = 1:numCells
    actualID = uniqueCellIDs(id);
    if actualID < 10
        id_str = sprintf('0%d', actualID);  % Add one leading zero
    else
        id_str = sprintf('%d', actualID);
    end

    for trial = 1:10
        filename = sprintf('ratemap_cell%s_trial%d.mat', id_str, trial);
        ratemap = load(fullfile(dataFolder, filename)).rm;
        groupedRatemaps(:,:, trial) = ratemap;
    end

    corr_matrix = zeros(10, 10);
    for trial = 1:10 
        mainRatemap = groupedRatemaps(:,:,trial);
        for compareTrial = 1:10
            compareRatemap = groupedRatemaps(:,:,compareTrial);
            corr = nancorr(mainRatemap, compareRatemap);
            corr_matrix(trial, compareTrial) = corr;
        end
    end
    
    nanMask = isnan(corr_matrix);
    main_NaN_counter = main_NaN_counter - nanMask;

    % here, need to add values to main, whilst turning nan values to 0
    corr_matrix(isnan(corr_matrix)) = 0;
    main_corr_matrix = main_corr_matrix + corr_matrix;

end

main_NaN_counter = main_NaN_counter + numCells;
main_corr_matrix = main_corr_matrix ./ main_NaN_counter;
imshow(main_corr_matrix, 'InitialMagnification', 'fit')
colormap('jet')



function [corr] = nancorr(mainRatemap, compareRatemap) 
    
    % Valid = 1 if both ratemaps at that location has a value
    valid = ~isnan(mainRatemap) & ~isnan(compareRatemap);
    
    % If entire valid matrix is 0, then that means theres no overlap in
    % trajectory which means you cant compute correlation
    if nnz(valid) == 0
        fprintf('No overlap in trajectories')
        corr = NaN;
        return;
    end

    mainRatemapValid = mainRatemap(valid);
    compareRatemapValid = compareRatemap(valid);

    mainRatemapValid = mainRatemapValid - mean(mainRatemapValid);
    compareRatemapValid = compareRatemapValid - mean(compareRatemapValid);

    denom = sqrt(sum(mainRatemapValid.^2) * sum(compareRatemapValid.^2));
    if denom == 0
        corr = NaN;
    else
        corr = sum(mainRatemapValid .* compareRatemapValid) / denom;
    end

end
% === QC summary from main_NaN_counter ===
N = numCells;                 % total place cells
P = main_NaN_counter / N;     % coverage proportion per trial pair (10x10)

% Include-diagonal stats
mean_incl_pct = 100 * mean(P(:));         % mean cell inclusion (%)
min_incl_pct  = 100 * min(P(:));          % min cell inclusion (%)
pct_pairs_lt90 = 100 * mean(P(:) < 0.90); % % trial pairs with <90% inclusion

fprintf('Mouse %s | Total place cells = %d\n', mouseID, N);
fprintf('Mean inclusion = %.2f%% | Min inclusion = %.2f%% | Pairs <90%% = %.1f%%\n', ...
        mean_incl_pct, min_incl_pct, pct_pairs_lt90);

% (Optional) Off-diagonal-only stats (exclude self-pairs)
offdiag = ~eye(10);
mean_incl_off_pct = 100 * mean(P(offdiag));
min_incl_off_pct  = 100 * min(P(offdiag));
pct_pairs_off_lt90 = 100 * mean(P(offdiag) < 0.90);

fprintf('Off-diagonal only -> Mean = %.2f%% | Min = %.2f%% | Pairs <90%% = %.1f%%\n', ...
        mean_incl_off_pct, min_incl_off_pct, pct_pairs_off_lt90);

% Load the file
data = load('/home/barrylab/Documents/Giana/Data/m4602/20220320/ratemaps.mat');

% Access the cell array
cellArray = data.ratemaps.cellN;

% Extract the 'placeCell' value from each struct
placeFlags = cellfun(@(c) c.placeCell, cellArray);

% Count how many are 1 (place cells)
numPlaceCells = sum(placeFlags == 1);

% Display
fprintf('Total cells: %d\n', numel(cellArray));
fprintf('Number of place cells: %d\n', numPlaceCells);
fprintf('Percentage place cells: %.2f%%\n', (numPlaceCells / numel(cellArray)) * 100);
