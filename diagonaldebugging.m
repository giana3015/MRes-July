
% Define base folder
baseFolder = '/home/barrylab/Documents/Giana/Data';

% Get list of mouse folders starting with 'm'
mouseFolders = dir(fullfile(baseFolder, 'm*'));
mouseFolders = mouseFolders([mouseFolders.isdir]);

for i = 1:length(mouseFolders)
    mouseID = mouseFolders(i).name;
    mousePath = fullfile(baseFolder, mouseID);

    % Get list of day folders starting with '2' (dates)
    dayFolders = dir(fullfile(mousePath, '2*'));
    dayFolders = dayFolders([dayFolders.isdir]);

    for j = 1:length(dayFolders)
        dayName = dayFolders(j).name;
        dayPath = fullfile(mousePath, dayName, 'ratemap_correlation_matrix_PC');

        if ~exist(dayPath, 'dir')
            continue
        end

        % Get list of .mat files in ratemap_correlation_matrix_PC
        matFiles = dir(fullfile(dayPath, 'corrMatrix_cell*.mat'));

        for k = 1:length(matFiles)
            matName = matFiles(k).name;
            matPath = fullfile(dayPath, matName);

            % Load matrix
            data = load(matPath);
            if isfield(data, 'corrMatrix')
                diagVals = diag(data.corrMatrix);

                % Print results
                fprintf('Mouse: %s | Day: %s | File: %s\n', mouseID, dayName, matName);
                fprintf('Diagonal values:\n');
                disp(diagVals');

                % Check if all diagonals are exactly 1
                if all(diagVals == 1)
                    fprintf('All diagonal values are exactly 1.\n\n');
                else
                    fprintf('Not all diagonal values are exactly 1.\n\n');
                end
            end
        end
    end
end
