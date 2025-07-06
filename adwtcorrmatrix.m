%% Paths and setup
baseFolder = '/home/barrylab/Documents/Giana/Data/grouped_mean_corrMatrices';
outputFolder = fullfile(baseFolder, 'AD_WT_groupCombined');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% === Define AD and WT mouse IDs ===
AD_mice = {'m4005','m4020','m4202','m4232','m4602','m4609','m4610'};
WT_mice = {'m4098','m4101','m4201','m4230','m4376','m4578','m4604','m4605'};

%% Function to combine groupCorrMatrix.mat across mice
function [groupMean, totalCount] = combine_group_corr(baseFolder, mouseList)
    groupSum = [];
    totalCount = 0;

    for i = 1:length(mouseList)
        mouseID = mouseList{i};
        filePath = fullfile(baseFolder, mouseID, 'groupCorrMatrix.mat');
        if isfile(filePath)
            data = load(filePath);
            if isfield(data, 'groupCorrMatrix')
                M = data.groupCorrMatrix;
                if isempty(groupSum)
                    groupSum = M;
                else
                    groupSum = groupSum + M;
                end
                totalCount = totalCount + 1;
            else
                fprintf('No groupCorrMatrix in %s\n', mouseID);
            end
        else
            fprintf('No groupCorrMatrix.mat for %s\n', mouseID);
        end
    end

    if totalCount > 0
        groupMean = groupSum / totalCount;
    else
        groupMean = [];
    end
end

%% Combine AD mice
[groupMean_AD, count_AD] = combine_group_corr(baseFolder, AD_mice);
fprintf('AD group combined from %d mice.\n', count_AD);
if ~isempty(groupMean_AD)
    save(fullfile(outputFolder, 'AD_groupCorrMatrix.mat'), 'groupMean_AD');
    fprintf('Diagonal of AD group matrix:\n');
    disp(diag(groupMean_AD)');
    
    % Save as PNG
    figure('Visible','off');
    imagesc(groupMean_AD, [-1 1]); axis square; colorbar;
    title('AD Group Mean Correlation Matrix');
    saveas(gcf, fullfile(outputFolder, 'AD_groupCorrMatrix.png'));
    close;
end

%% Combine WT mice
[groupMean_WT, count_WT] = combine_group_corr(baseFolder, WT_mice);
fprintf('WT group combined from %d mice.\n', count_WT);
if ~isempty(groupMean_WT)
    save(fullfile(outputFolder, 'WT_groupCorrMatrix.mat'), 'groupMean_WT');
    fprintf('Diagonal of WT group matrix:\n');
    disp(diag(groupMean_WT)');
    
    % Save as PNG
    figure('Visible','off');
    imagesc(groupMean_WT, [-1 1]); axis square; colorbar;
    title('WT Group Mean Correlation Matrix');
    saveas(gcf, fullfile(outputFolder, 'WT_groupCorrMatrix.png'));
    close;
end

fprintf('Finished generating and saving AD and WT group mean matrices as .mat and .png.\n');
