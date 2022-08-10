function [pred_pos, pred_neg, pred_combined] = ...
    macronets_CPM_apply_model(test_mats, test_covars, no_covars, ...
        pos_mask, neg_mask, fit_pos, fit_neg, fit_combined, macronet_masks)
% Date edited: 05/06/2022
% Applies fitted model parameters from the training set to participants in
% the test set.
%
% INPUT:
% test_mats =           as described in CPM_cv_split.
% test_covars =         as described in CPM_cv_split.
% no_covars =           as described in CPM_prep_arrays.
% pos_mask =            as described in CPM_fs_select.
% neg_mask =            as described in CPM_fs_select.
% fit_pos =             as described in CPM_fit_model.
% fit_neg =             as described in CPM_fit_model.
% fit_combined =        as described in CPM_fit_model.
%
% OUTPUT:
% pred_pos =            n * 1 array where n = number of participants in 
%                       test set. Contains predicted values for test set%
%                       based on positive network model.
% pred_neg =            same as above for negative network model.
% pred_combined =       same as above for combined network model.
%
% Author: Rory Boyle
% Contact: rorytboyle@gmail.com
% Date: 24/01/2021
%
% NOTE: This code is a modification of codeshare_behavioralprediction.m
% which was written by Xilin Shen and Emily Finn (as obtained here: 
% https://www.nitrc.org/frs/download.php/8071/nn_code.zip).
% Copyright 2015 Xilin Shen and Emily Finn 
% This code is released under the terms of the GNU GPL v2. This code
% is not FDA approved for clinical use; it is provided
% freely for research purposes. If using this in a publication
% please reference this properly as: 
%
% Finn ES, Shen X, Scheinost D, Rosenberg MD, Huang, Chun MM,
% Papademetris X & Constable RT. (2015). Functional connectome
% fingerprinting: Identifying individuals using patterns of brain
% connectivity. Nature Neuroscience 18, 1664-1671.
%

% Create arrays to store macro network strength values
test_sumpos = zeros(n_test,8);
test_sumneg = zeros(n_test,8);
test_sumcombined = zeros(n_test,8);

for net = 1:size(test_sumpos_macronets, 2)
    for ss = 1:size(test_sumpos_macronets, 1)
        test_sumpos(ss, net) = sum(sum(test_mats(:,:,ss).*(pos_mask.*macronet_masks{net})));
        test_sumneg(ss, net) = sum(sum(test_mats(:,:,ss).*(neg_mask.*macronet_masks{net})));
        test_sumcombined(ss, net) = test_sumpos_macronets(ss, net) - test_sumneg(ss, net);
    end
end

% Multiply regression weights for network strengths by network strength and
% add intercept
pred_pos = fit_pos(1);
pred_neg = fit_neg(1);
pred_combined = fit_combined(1);
for i=1:8
    pred_pos = pred_pos + fit_pos(i+1)*test_sumpos(:, i);
    pred_neg = pred_neg + fit_neg(i+1)*test_sumneg(:, i);
    pred_combined = pred_combined + fit_combined(i+1)*test_sumcombined(:, i);
end

% Reshape prediction arrays - when k-fold (e.g. 5-fold or 10-fold)
% cross-validation used, prediction arrays are saved as 1*1*n arrays where
% n = number of test participants. This will convert them to n * 1 arrays.
test_ppts = size(test_mats, 3);
pred_pos = reshape(pred_pos, test_ppts, 1);
pred_neg = reshape(pred_neg, test_ppts, 1);
pred_combined = reshape(pred_combined, test_ppts, 1);

% apply fitted model parameters to covariates and add covariates to
% predicted values
if no_covars>0
    covar_pred_pos = zeros(test_ppts,1); 
    covar_pred_neg = zeros(test_ppts,1); 
    covar_pred_combined = zeros(test_ppts,1); 

    % multiply regression weights for covars by covars in test set
    for covar = 1:no_covars
        covar_pred_pos = covar_pred_pos + fit_pos(covar+9)*test_covars(:,covar);
        covar_pred_neg = covar_pred_neg + fit_neg(covar+9)*test_covars(:,covar);
        covar_pred_combined = covar_pred_combined + fit_combined(covar+9)*test_covars(:,covar);
    end
  
    % add fitted values for covars to predicted values
    pred_pos = pred_pos + covar_pred_pos;
    pred_neg = pred_neg + covar_pred_neg;
    pred_combined = pred_combined + covar_pred_combined;
    
end
end