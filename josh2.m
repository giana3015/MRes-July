mice_ids = {'4098', '4101', '4201', '4230', '4376', '4578', '4604', '4605'};

for i = 1:length(mice_ids)
    filename = ['m' mice_ids{i} '_WT_corr_matrix.mat'];
    filePath = fullfile(basePath, filename);
    
    individual_corrMt = load(filePath, 'main_corr_matrix');
    
end

numCorrMt = length(individual_corrMt);


main_corr_matrix = zeros(10, 10);
main_NaN_counter = zeros(10,10);



for WTcorrMt = 1:numCorrMt
    %go through each of the loaded individual_corrMt

    M = individual_corrMt(k).main_corr_matrix;

    nanMask = isnan(M);
    main_NaN_counter = main_NaN_counter - nanMask;

    % here, need to add values to main, whilst turning nan values to 0
    M(isnan(M)) = 0;
    main_corr_matrix = main_corr_matrix + M;
  





end

main_NaN_counter = main_NaN_counter + numCells;
main_corr_matrix = main_corr_matrix ./ main_NaN_counter;
imshow(main_corr_matrix, 'InitialMagnification', 'fit')
colormap('jet')