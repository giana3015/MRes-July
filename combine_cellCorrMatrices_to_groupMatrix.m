% === Base path and output folder ===
basePath = '/home/barrylab/Documents/Giana/Data';
outputFolder = fullfile(basePath, 'grouped corr matrix new');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% === Find all mouse folders ===
mouseFolders = dir(basePath);
mouseFolders = mouseFolders([mouseFolders.isdir] & startsWith({mouseFolders.name}, 'm'));

for m = 1:length(mouseFolders)
    mouseID = mouseFolders(m).name;
    mousePath = fullfile(basePath, mouseID);
    
    % === Find all session folders starting with '2' ===
    sessionFolders = dir(mousePath);
    sessionFolders = sessionFolders([sessionFolders.isdir] & startsWith({sessionFolders.name}, '2'));
    
    for s = 1:length(sessionFolders)
        sessionID = sessionFolders(s).name;
        sessionPath = fullfile(mousePath, sessionID, 'ratemap_correlation_matrix_PC');
        
        % === Check if folder exists ===
        if ~exist(sessionPath, 'dir')
            fprintf('❌ %s %s no corr matrix folder.\n', mouseID, sessionID);
            continue;
        end
        
        % === Load all corrMatrix_cell*.mat ===
        corrFiles = dir(fullfile(sessionPath, 'corrMatrix_cell*.mat'));
        if isempty(corrFiles)
            fprintf('⚠️ %s %s has no cell corr matrices.\n', mouseID, sessionID);
            continue;
        end
        
        allCorrs = [];
        for k = 1:length(corrFiles)
            data = load(fullfile(sessionPath, corrFiles(k).name));
            if isfield(data, 'corrMatrix')
                C = data.corrMatrix;
                if isequal(size(C), [10 10])
                    allCorrs(:, :, end+1) = C;
                end
            end
        end
        
        if isempty(allCorrs)
            fprintf('⚠️ %s %s loaded no valid matrices.\n', mouseID, sessionID);
            continue;
        end
        
        % === Calculate validCounts and groupMatrix ===
        validCounts = sum(~isnan(allCorrs), 3);
        sumCorrs = sum(allCorrs, 3, 'omitnan');
        groupMatrix = sumCorrs ./ max(validCounts,1);
        groupMatrix(validCounts==0) = NaN;
        
        % === Diagnostics ===
        fprintf('\n🐭 Mouse %s %s\n', mouseID, sessionID);
        fprintf('Loaded %d correlation matrices.\n', size(allCorrs,3));
        fprintf('Group matrix diagonal: %s\n', num2str(diag(groupMatrix)'));
        fprintf('Diagonal valid counts: %s\n', num2str(diag(validCounts)'));
        
        % === Save .mat ===
        saveNameMat = sprintf('%s_%s_groupMatrix.mat', mouseID, sessionID);
        save(fullfile(outputFolder, saveNameMat), 'groupMatrix');
        
        % === Save .png ===
        fig = figure('Visible','off');
        imagesc(groupMatrix, [-1 1]); axis square; colormap(jet); colorbar;
        xticks(1:10); yticks(1:10);
        title(sprintf('%s %s Group Correlation Matrix', mouseID, sessionID), 'Interpreter','none');
        saveNamePng = sprintf('%s_%s_groupMatrix.png', mouseID, sessionID);
        saveas(fig, fullfile(outputFolder, saveNamePng));
        close(fig);
        
        % === Diagonal final check ===
        diagVals = diag(groupMatrix);
        if all(abs(diagVals - 1) < 1e-3)
            fprintf('✅ Final diagonal check PASSED: All ~1.\n');
        else
            fprintf('⚠️ Final diagonal check WARNING: Not all ~1.\n');
        end
    end
end

fprintf('🏁 Done. Group matrices saved to %s\n', outputFolder);
