% === Configuration ===
folder = '/home/barrylab/Documents/Giana/Data/m4005/20200924/PC_ratemaps';
file1 = fullfile(folder, 'ratemap_cell02_trial5.mat');
file2 = fullfile(folder, 'ratemap_cell02_trial10.mat');
nShuffles = 1000;

% === Load ratemaps ===
S1 = load(file1); vars1 = fieldnames(S1); ratemap1 = S1.(vars1{1});
S2 = load(file2); vars2 = fieldnames(S2); ratemap2 = S2.(vars2{1});

% === Flatten and clean maps ===
map1 = ratemap1(:);
map2 = ratemap2(:);
validIdx = ~isnan(map1) & ~isnan(map2);

fprintf('Checking data quality:\n');
fprintf('map1: %d NaNs, min %.2f, max %.2f\n', sum(isnan(map1)), min(map1,[],'omitnan'), max(map1,[],'omitnan'));
fprintf('map2: %d NaNs, min %.2f, max %.2f\n', sum(isnan(map2)), min(map2,[],'omitnan'), max(map2,[],'omitnan'));

if sum(validIdx) < 3
    warning(' Too few valid points for correlation.');
    real_corr = NaN;
    pval = NaN;
    is_remapping = NaN;
else
    map1 = map1(validIdx);
    map2 = map2(validIdx);

    % === Real correlation ===
    real_corr = corr(map1, map2, 'type', 'Pearson');

    % === Shuffle-based null ===
    shuffled_corrs = zeros(1, nShuffles);
    for s = 1:nShuffles
        shift = randi(length(map2));
        shuffled_map2 = circshift(map2, shift);
        shuffled_corrs(s) = corr(map1, shuffled_map2, 'type', 'Pearson');
    end

    % === P-value ===
    pval = mean(abs(shuffled_corrs) >= abs(real_corr));
    is_remapping = pval > 0.05;

    % === Display result ===
    fprintf('\n Real correlation: %.4f\n', real_corr);
    fprintf(' p-value: %.4f → %s\n', pval, ternary(is_remapping, 'Remapping', 'Stable'));

    % === Histogram plot ===
    edges = linspace(-1, 1, 30);
    histogram(shuffled_corrs, edges, 'FaceColor', [0.7 0.7 0.7]);
    hold on;
    yLimits = ylim;
    plot([real_corr real_corr], yLimits, 'r--', 'LineWidth', 2);
    xlabel('Correlation');
    ylabel('Count');
    title('Shuffle Null Distribution');
    legend('Shuffled Correlations', 'Real Correlation');
    box on;
end

% Helper ternary function
function out = ternary(cond, a, b)
    if cond
        out = a;
    else
        out = b;
    end
end