function [perm_p_pos, perm_p_neg, perm_p_combined] = ...
    CPM_permutation_test(all_behav, all_mats, all_covars, k, thresh_type, thresh, ...
    adjust_stage, true_r_pos, true_r_neg, true_r_combined, n_iterations, cat_covars)
% Permutation testing of CPM to create an empirical null distribution of 
% test statistic (i.e. correlation between target variable and predicted 
% values). The target variable is randomly shuffled and then CPM is 
% performed. This is repeated x times, where x is specified by 
% 'n_iterations'. The correlation between the randomly shuffled target
% variables and the predictions are used to create an empirical null
% distribution. Permuted p-values are calculated for each network strength
% model as the proportion of of permuted correlations that are greater
% than or equal to the true prediction correlation for that network
% strength model.

% INPUT:
% all_behav =               as described in run_flexible_CPM.   
% all_mats =                as described in run_flexible_CPM. 
% all_covars =              as described in run_flexible_CPM.
% k =                       as described in run_flexible_CPM.
% thresh =                  as described in run_flexible_CPM.
% adjust_stage =            as described in run_flexible_CPM.
% n_iterations =            (double) number specifying iterations of random
%                           permutation.
% true_r_pos =              (float) Pearson's r value for true correlation
%                           between target variable and positive network
%                           strength predictions.
% true_r_neg =              same as above for negative network strength
%                           predictions.
% true_r_combined =         same as above for combined network strength
%                           predictions.
%
% OUTPUT:
% perm_p_pos =              (float) permuted p-value for positive network
%                           strength predictions.
% perm_p_neg =              same as above for negative network strength
%                           predictions.
% perm_p_combined =         same as above for combined network strength
%                           predictions.
%
% Author: Rory Boyle
% Contact: rorytboyle@gmail.com
% Date: 28/04/2021
% 
% NOTE: This code is a modification of code written by Xilin Shen and 
% and Emily Finn, as presented in Figure 5 of Shen et al. (2017) Nature 
% Protocols. https://doi.org/10.1038/nprot.2016.178
% Copyright 2017 Xilin Shen and Emily Finn 
% This code is released under the terms of the GNU GPL v2. This code
% is not FDA approved for clinical use; it is provided
% freely for research purposes. If using this in a publication
% please reference this properly as: 
%
% Shen X, Finn ES, Scheinost D, Rosenberg MD, Chun MM, Papademetris X &
% Constable RT. (2017). Using connectome-based predictive modeling to 
% predict individual behavior from brain connectivity. Nature Protocols 12,
% 506-518.
%% 1) Prepare variables
% get number of ppts 
no_sub = size(all_mats,3);

% init variables to store permuted correlations
random_pos_r = zeros(n_iterations,1);
random_neg_r = zeros(n_iterations,1);
random_combined_r = zeros(n_iterations,1);

%% 2) Run random permutation of CPM and store correlations
% Permute CPM
    parfor i = 1:n_iterations
        % display progress message
        fprintf('\n Iteration %d out of %d',...
            i, n_iterations)
        
        % Randomly shuffle target variable
        random_behav = all_behav(randperm(no_sub));
        
        % Run CPM with randomly shuffled target variable
        [behav_pred_pos, behav_pred_neg, behav_pred_combined,...
            ~, ~, ~, ~, ~, ~, ~] = run_flexible_CPM(...
            random_behav, all_mats, all_covars, k, thresh_type, thresh, adjust_stage, cat_covars);
        
        % Correlate predictions with randomly shuffled target variables and
        % store correlations        
        random_pos_r(i) = corr(behav_pred_pos, random_behav, 'type', 'Pearson');
        random_neg_r(i) = corr(behav_pred_neg, random_behav, 'type', 'Pearson');
        random_combined_r(i) = corr(behav_pred_combined, random_behav, 'type', 'Pearson');
        
        % display progress message   
        fprintf('\n%.2f%% complete\n', (i/n_iterations)*100)
    end
    
%% 3) Calculate permuted p-values
% Permuted p-value = proportion of permuted correlations that are greater
% than or equal to the true prediction correlation.
    disp("sum(random>=true)")    
    sum(random_pos_r>=true_r_pos)
    sum(random_neg_r>=random_neg_r)
    sum(random_combined_r>=true_r_combined)
    
    % Calculate permuted p-value for positive network strength model
    perm_p_pos = (sum(random_pos_r>=true_r_pos))/n_iterations;
    
    % Calculate permuted p-value for negative network strength model 
    perm_p_neg = (sum(random_neg_r>=true_r_neg))/n_iterations;
    
    % Calculate permuted p-value for combined network strength model 
    % Use abs() to get absolute values in case of negative correlations
    sum(random_combined_r>=true_r_combined);
    perm_p_combined = (sum(random_combined_r>=true_r_combined))/n_iterations;
    
end

