% === Define base folders for AD and WT ===
base_ad = '/home/barrylab/Documents/Giana/Data/grouped_mean_corrMatrices/ad';
base_wt = '/home/barrylab/Documents/Giana/Data/grouped_mean_corrMatrices/wt';

% === Define output path ===
outputCSV = '/home/barrylab/Documents/Giana/Data/grouped_mean_corrMatrices/AD_WT_individual_mouse_summary.csv';
fid = fopen(outputCSV, 'w');

% === Write header ===
fprintf(fid, 'MouseID,Genotype,Mean_Morning_vs_Morning,Mean_Afternoon_vs_Afternoon,Mean_Morning_vs_Afternoon,Mean_Overall\n');

% === Function to compute metrics ===
function metrics = compute_metrics(matrix)
    morning = 1:5;
    afternoon = 6:10;

    % Morning vs Morning (excluding diagonal)
    mm = matrix(morning, morning);
    mm_vals = mm(~eye(length(morning)));
    mean_morning = mean(mm_vals, 'omitnan');

    % Afternoon vs Afternoon (excluding diagonal)
    aa = matrix(afternoon, afternoon);
    aa_vals = aa(~eye(length(afternoon)));
    mean_afternoon = mean(aa_vals, 'omitnan');

    % Morning vs Afternoon
    ma = matrix(morning, afternoon);
    mean_morning_afternoon = mean(ma(:), 'omitnan');

    % Overall
    mean_overall = mean(matrix(:), 'omitnan');

    % Store
    metrics = [mean_morning, mean_afternoon, mean_morning_afternoon, mean_overall];
end

% === Process AD mice ===
ad_mice = dir(fullfile(base_ad, 'm*'));
for i = 1:length(ad_mice)
    mouseID = ad_mice(i).name;
    matPath = fullfile(base_ad, mouseID, 'groupCorrMatrix.mat');
    if isfile(matPath)
        data = load(matPath, 'groupMatrix');
        matrix = data.groupMatrix;
        metrics = compute_metrics(matrix);

        % Write to CSV
        fprintf(fid, '%s,AD,%.4f,%.4f,%.4f,%.4f\n', mouseID, metrics);
        fprintf('✅ Processed AD mouse %s\n', mouseID);
    else
        fprintf('⚠️ groupCorrMatrix.mat not found for AD mouse %s\n', mouseID);
    end
end

% === Process WT mice ===
wt_mice = dir(fullfile(base_wt, 'm*'));
for i = 1:length(wt_mice)
    mouseID = wt_mice(i).name;
    matPath = fullfile(base_wt, mouseID, 'groupCorrMatrix.mat');
    if isfile(matPath)
        data = load(matPath, 'groupMatrix');
        matrix = data.groupMatrix;
        metrics = compute_metrics(matrix);

        % Write to CSV
        fprintf(fid, '%s,WT,%.4f,%.4f,%.4f,%.4f\n', mouseID, metrics);
        fprintf('✅ Processed WT mouse %s\n', mouseID);
    else
        fprintf('⚠️ groupCorrMatrix.mat not found for WT mouse %s\n', mouseID);
    end
end

% === Close file ===
fclose(fid);

fprintf('🏁 All done. Results saved to %s\n', outputCSV);
