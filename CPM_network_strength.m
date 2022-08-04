function [train_sumpos, train_sumneg, train_sumcombined, train_sumpos_macronets, train_sumneg_macronets, train_sumcombined_macronets] = ...
        CPM_network_strength(train_mats, pos_mask, neg_mask, ix_train)
% Calculates network strength values for positive, negative, and combined
% networks. Network strength = summed connectivity of edges that are
% related to target variable. Combined network strength is calculated using
% the method described by Greene et al. 2018 Nature Communications
% https://doi.org/10.1038/s41467-018-04920-3 where combined network strength
% is the difference between positive and negative network strength.
%
% INPUT:
% train_mats =          as described in CPM_cv_split.
% pos_mask =            as described in CPM_fs_select.
% neg_mask =            as described in CPM_fs_select.
% ix_train =            as described in CPM_cv_split.
%
% OUTPUT:
% train_sumpos =        n * 1 array where n = number of participants in
%                       current training set. Contains summed positive
%                       network strength values (i.e. summed connectivity
%                       of edges that are positively related to target
%                       variable).
% train_sumneg =        n * 1 array where n = number of participants in
%                       current training set. Contains summed negative
%                       network strength values (i.e. summed connectivity
%                       of edges that are negatively related to target
%                       variable).
% train_sumcombined =   n * 1 array where n = number of participants in
%                       current training set. Contains difference in
%                       network strength between positive and negative 
%                       networks. Defined according to Greene et al. 2018 
%                       Nature Communications as positive network minus
%                       negative network.
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
% Papademetris X & Constable RT. (2015). functional connectome
% fingerprinting: Identifying individuals using patterns of brain
% connectivity. Nature Neuroscience 18, 1664-1671.
% 
% Create arrays to store network strength values
train_sumpos = zeros(length(ix_train),1);
train_sumneg = zeros(length(ix_train),1);

% Get sum of all positive and negative thresholded edges in training set
% participants. Divide by 2 control for the fact that matrices are
% symmetric.

for ss = 1:size(train_sumpos)
    train_sumpos(ss) = sum(sum(train_mats(:,:,ss).*pos_mask))/2;
    train_sumneg(ss) = sum(sum(train_mats(:,:,ss).*neg_mask))/2;
end

% Calculate combined network strength
train_sumcombined = train_sumpos - train_sumneg;

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
train_sumpos_macronets = zeros(length(ix_train),8);
train_sumneg_macronets = zeros(length(ix_train),8);
train_sumcombined_macronets = zeros(length(ix_train),8);

for net = 1:size(train_sumpos, 2)
    nodes = macro_network_nodes{net};
    for ss = 1:size(train_sumpos, 1)
        train_sumpos_macronets(ss, net) = sum(sum(train_mats(nodes,:,ss).*pos_mask));
        train_sumneg_macronets(ss, net) = sum(sum(train_mats(nodes,:,ss).*neg_mask));
        train_sumcombined_macronets(ss, net) = train_sumpos_macronets(ss, net) - train_sumneg_macronets(ss, net);
    end
end

end
