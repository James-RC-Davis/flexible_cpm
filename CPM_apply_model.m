function [pred_pos, pred_neg, pred_combined] = ...
    CPM_apply_model(test_mats, test_covars, no_covars, ...
        pos_mask, neg_mask, fit_pos, fit_neg, fit_combined)
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


macro_network_nodes_1 = [10	12	16	52	53	54	56	57	64	65	137	140	145	148	149	150	151	153	156	162	165	183	185	186	187	190	192	194	219];
macro_network_nodes_2 = [1	4	7	8	9	14	17	19	21	22	30	31	47	48	55	70	111	112	116	139	142	143	147	154	157	164	182	184	193	196	199	242	246	247];
macro_network_nodes_3 = [3	5	6	13	49	50	85	86	90	96	115	134	138	141	203	222	223	225	227	239];
macro_network_nodes_4 = [2	11	15	18	20	28	29	32	36	44	83	88	91	93	94	95	99	101	103	104	105	106	107	108	110	113	114	117	118	119	120	121	122	123	124	125	126	127	128	129	130	131	132	133	135	136	144	146	152	155	169	178	217	220	221	224	226	229	230	231	232	233	234	236	237	238	243	244	245	248	249	250	251	252	253	254	255	256	257	258	259	260	261	262	263	264	265	266	267	268];
macro_network_nodes_5 = [23	24	25	26	27	33	34	35	37	38	39	40	45	46	51	58	60	61	62	63	84	89	92	97	109	158	159	160	161	163	166	167	168	170	171	172	173	174	179	180	181	188	189	191	195	197	202	218	228	235];
macro_network_nodes_6 = [42	68	72	75	77	79	80	82	87	98	176	198	205	207	208	211	215	216];
macro_network_nodes_7 = [76	78	81	100	102	212	213	214	241];
macro_network_nodes_8 = [41	43	59	66	67	69	71	73	74	175	177	200	201	204	206	209	210	240];

macro_network_nodes = {macro_network_nodes_1; macro_network_nodes_2; macro_network_nodes_3; macro_network_nodes_4; macro_network_nodes_5; macro_network_nodes_6; macro_network_nodes_7; macro_network_nodes_8};

% Create arrays to store macro network strength values
test_sumpos_macronets = zeros(length(ix_test),8);
test_sumneg_macronets = zeros(length(ix_test),8);
test_sumcombined_macronets = zeros(length(ix_test),8);

for net = 1:size(train_sumpos, 2)
    nodes = macro_network_nodes{net};
    for ss = 1:size(train_sumpos, 1)
        test_sumpos_macronets(ss, net) = sum(sum(test_mats(nodes,:,ss).*pos_mask));
        test_sumneg_macronets(ss, net) = sum(sum(test_mats(nodes,:,ss).*neg_mask));
        test_sumcombined_macronets(ss, net) = test_sumpos_macronets(ss, net) - test_sumneg_macronets(ss, net);
    end
end

% Calculate network strengths for participants in the training set
test_sumpos = sum(sum(test_mats.*pos_mask))/2;
test_sumneg = sum(sum(test_mats.*neg_mask))/2;
test_sumcombined = test_sumpos - test_sumneg;

% Multiply regression weights for network strengths by network strength and
% add intercept
pred_pos = fit_pos(1);
pred_neg = fit_neg(1);
pred_combined = fit_combined(1);
for i=1:8
    pred_pos = pred_pos + fit_pos(i+1)*test_sumpos_macronets(:, i);
    pred_neg = pred_neg + fit_neg(i+1)*test_sumneg_macronets(:, i);
    pred_combined = pred_combined + fit_combined(i+1)*test_sumcombined_macronets(:, i);
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