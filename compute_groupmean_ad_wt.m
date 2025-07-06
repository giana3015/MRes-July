%% Compute combined and mean matrices for AD and WT mice
% Define base folder for AD
baseFolderAD = '/home/barrylab/Documents/Giana/Data/grouped_mean_corrMatrices/ad/';
ad_mice = {'m4005','m4020','m4202','m4232','m4602','m4609','m4610'};
exclude_ad = {'m4602','m4609','m4610'}; % Exclude problematic mice
ad_mice = setdiff(ad_mice, exclude_ad);

% Initialize AD combined matrix and counter
combinedMatrix_AD = [];
matrixCount_AD = 0;

% Loop through AD mice
for i = 1:length(ad_mice)
    mouseID = ad_mice{i};
    matPath = fullfile(baseFolderAD, mouseID, 'groupCorrMatrix.mat');
    
    if isfile(matPath)
        data = load(matPath, 'groupMatrix');
        groupMatrix = data.groupMatrix;
        
        if isempty(combinedMatrix_AD)
            combinedMatrix_AD = groupMatrix;
        else
            combinedMatrix_AD = combinedMatrix_AD + groupMatrix;
        end
        
        matrixCount_AD = matrixCount_AD + 1;
        fprintf('Loaded %s\n', matPath);
    else
        fprintf('No groupCorrMatrix.mat for %s\n', mouseID);
    end
end

fprintf('AD group combined from %d matrices.\n', matrixCount_AD);

% Compute mean AD matrix
meanMatrix_AD = combinedMatrix_AD / matrixCount_AD;
disp('Diagonal of AD mean matrix:');
disp(diag(meanMatrix_AD)');

% Save AD matrices
outputFolderAD = baseFolderAD;
save(fullfile(outputFolderAD, 'combined_AD_matrix_excl4602_4609_4610.mat'), 'combinedMatrix_AD');
save(fullfile(outputFolderAD, 'mean_AD_matrix_excl4602_4609_4610.mat'), 'meanMatrix_AD');

% Plot and save AD heatmap
figure;
imagesc(meanMatrix_AD, [-1 1]); axis square; colorbar; colormap jet;
title('Mean AD Matrix (excl 4602, 4609, 4610)');
xticks(1:10); yticks(1:10);
saveas(gcf, fullfile(outputFolderAD, 'mean_AD_matrix_excl4602_4609_4610.png'));
close;

fprintf('Saved AD combined and mean matrices with heatmap.\n');

%% Compute combined and mean matrices for WT mice
% Define base folder for WT
baseFolderWT = '/home/barrylab/Documents/Giana/Data/grouped_mean_corrMatrices/wt/';
wt_mice = {'m4101','m4201','m4230','m4376','m4578','m4602','m4604','m4605','m4098'};
exclude_wt = {'m4604','m4201','m4098'}; % Exclude problematic mice
wt_mice = setdiff(wt_mice, exclude_wt);

% Initialize WT combined matrix and counter
combinedMatrix_WT = [];
matrixCount_WT = 0;

% Loop through WT mice
for i = 1:length(wt_mice)
    mouseID = wt_mice{i};
    matPath = fullfile(baseFolderWT, mouseID, 'groupCorrMatrix.mat');
    
    if isfile(matPath)
        data = load(matPath, 'groupMatrix');
        groupMatrix = data.groupMatrix;
        
        if isempty(combinedMatrix_WT)
            combinedMatrix_WT = groupMatrix;
        else
            combinedMatrix_WT = combinedMatrix_WT + groupMatrix;
        end
        
        matrixCount_WT = matrixCount_WT + 1;
        fprintf('Loaded %s\n', matPath);
    else
        fprintf('No groupCorrMatrix.mat for %s\n', mouseID);
    end
end

fprintf('WT group combined from %d matrices.\n', matrixCount_WT);

% Compute mean WT matrix
meanMatrix_WT = combinedMatrix_WT / matrixCount_WT;
disp('Diagonal of WT mean matrix:');
disp(diag(meanMatrix_WT)');

% Save WT matrices
outputFolderWT = baseFolderWT;
save(fullfile(outputFolderWT, 'combined_WT_matrix_excl4604_4201_4098.mat'), 'combinedMatrix_WT');
save(fullfile(outputFolderWT, 'mean_WT_matrix_excl4604_4201_4098.mat'), 'meanMatrix_WT');

% Plot and save WT heatmap
figure;
imagesc(meanMatrix_WT, [-1 1]); axis square; colorbar; colormap jet;
title('Mean WT Matrix (excl 4604, 4201, 4098)');
xticks(1:10); yticks(1:10);
saveas(gcf, fullfile(outputFolderWT, 'mean_WT_matrix_excl4604_4201_4098.png'));
close;

fprintf('Saved WT combined and mean matrices with heatmap.\n');
