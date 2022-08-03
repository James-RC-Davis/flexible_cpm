function [r_mat, p_mat] = CPM_fs_relate_partial(train_vcts, train_behav, ...
                                        train_covars, no_node, corr_type)
% Relates functional connectivity in each edge in connectivity matrix to 
% target variable, controlling for covariates, for CPM feature selection.
%
% INPUT: 
% train_vcts =          as described in CPM_cv_split.
% train_behav =         as described in CPM_cv_split.
% train_covars =        as described in CPM_cv_split.
% no_node =             as described in CPM_prep_arrays.
%
% OUTPUT:
% r_mat =               no_node * no_node array containing Pearson's r
%                       value for correlation of functional
%                       connectivity in each edge with target variable.
% p_mat =               no_node * no_node array containing p-value for
%                       Pearson's r correlation of functional
%                       connectivity in each edge with target variable.
%
% Author: Rory Boyle
% Contact: rorytboyle@gmail.com
% Date: 10/02/2021
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
% Relate functional connectivity to behaviour controlling for confounds

% Modified by: James Davis
% Contact: davisj5@tcd.ie
% Date: 17/01/‎2022
% -- Changed partial correlation type to Spearman: this allows for
% non-linear relationships between edges and outcome to be detected.  


[r_mat,p_mat] = partialcorr(train_vcts',train_behav,train_covars, 'type', corr_type);

% Reshape from vectors to matrices
r_mat = reshape(r_mat,no_node,no_node);
p_mat = reshape(p_mat,no_node,no_node);
end