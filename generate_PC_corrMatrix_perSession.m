% === Base path to all sessions ===
baseFolder = '/home/barrylab/Documents/Giana/Data/m4610';
days = {'20220521','20220522'};
targetTrials = {'1','2','3','4','5','6','7','8','9','10'};
minValidTrials = 10; % Require all 10 valid trials

for d = 1:length(days)

    session = days{d};
    dataFolder = fullfile(baseFolder, session);
    trialDataPath = fullfile(dataFolder, 'trialData.mat');

    if ~isfile(trialDataPath)
        fprintf('❌ trialData.mat missing in %s — skipping.\n', session);
        continue;
    end

    fprintf('\n=== Processing %s ===\n', session);
    load(trialDataPath);  % loads "trialData"

    placeCellIdx = find(cellfun(@(c) c.placeCell == 1, trialData.cellN));

    % === Output folder ===
    corrFolder = fullfile(dataFolder, 'ratemap_correlation_matrix_PC');
    if ~exist(corrFolder, 'dir'), mkdir(corrFolder); end

    ratemapFolder = fullfile(dataFolder, 'PC_ratemaps');

    for c = 1:length(placeCellIdx)
        cell_id = placeCellIdx(c);
        fprintf('\n→ Cell %d\n', cell_id);

        % === Load existing ratemaps ===
        ratemaps_all = cell(10,1);
        validTrials = false(10,1);
        hasZeroVariance = false;

        for t = 1:10
            matName = fullfile(ratemapFolder, sprintf('ratemap_cell%02d_trial%d.mat', cell_id, t));
            if isfile(matName)
                data = load(matName);
                rm = data.rm;
                ratemaps_all{t} = rm;
                validTrials(t) = true;

                % Check variance
                if isnumeric(rm)
                    rm_flat = rm(:);
                    rm_var = var(rm_flat(~isnan(rm_flat)));
                    fprintf('Trial %d variance: %.4f\n', t, rm_var);
                    if rm_var == 0
                        hasZeroVariance = true;
                        fprintf('⚠️ Cell %d excluded due to zero variance in trial %d.\n', cell_id, t);
                        break;
                    end
                end
            else
                ratemaps_all{t} = NaN;
            end
        end

        % === Skip if not enough valid trials or any zero variance ===
        if sum(validTrials) < minValidTrials || hasZeroVariance
            fprintf('⚠️ Cell %d skipped due to insufficient valid trials (%d) or zero variance.\n', cell_id, sum(validTrials));
            continue;
        end

        % === Compute correlation matrix ===
        corrMatrix = NaN(10);
        for i = 1:10
            for j = 1:10
                rm1 = ratemaps_all{i};
                rm2 = ratemaps_all{j};
                if isnumeric(rm1) && isnumeric(rm2) && all(size(rm1) == size(rm2))
                    validMask = ~isnan(rm1) & ~isnan(rm2);
                    v1 = rm1(validMask);
                    v2 = rm2(validMask);
                    if ~isempty(v1)
                        corrMatrix(i,j) = corr(v1, v2);
                    end
                end
            end
        end

        % === Save only if diagonal is valid ===
        diagVals = diag(corrMatrix);
        if all(~isnan(diagVals))
            save(fullfile(corrFolder, sprintf('corrMatrix_cell%02d.mat', cell_id)), 'corrMatrix');
        else
            fprintf('⚠️ Cell %d excluded due to invalid diagonal values.\n', cell_id);
        end
    end
end
