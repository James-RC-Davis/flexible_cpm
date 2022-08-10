function macronet_masks = generate_macronet_masks()
    macro_network_nodes_1 = [10	12	16	52	53	54	56	57	64	65	137	140	145	148	149	150	151	153	156	162	165	183	185	186	187	190	192	194	219];
    macro_network_nodes_2 = [1	4	7	8	9	14	17	19	21	22	30	31	47	48	55	70	111	112	116	139	142	143	147	154	157	164	182	184	193	196	199	242	246	247];
    macro_network_nodes_3 = [3	5	6	13	49	50	85	86	90	96	115	134	138	141	203	222	223	225	227	239];
    macro_network_nodes_4 = [2	11	15	18	20	28	29	32	36	44	83	88	91	93	94	95	99	101	103	104	105	106	107	108	110	113	114	117	118	119	120	121	122	123	124	125	126	127	128	129	130	131	132	133	135	136	144	146	152	155	169	178	217	220	221	224	226	229	230	231	232	233	234	236	237	238	243	244	245	248	249	250	251	252	253	254	255	256	257	258	259	260	261	262	263	264	265	266	267	268];
    macro_network_nodes_5 = [23	24	25	26	27	33	34	35	37	38	39	40	45	46	51	58	60	61	62	63	84	89	92	97	109	158	159	160	161	163	166	167	168	170	171	172	173	174	179	180	181	188	189	191	195	197	202	218	228	235];
    macro_network_nodes_6 = [42	68	72	75	77	79	80	82	87	98	176	198	205	207	208	211	215	216];
    macro_network_nodes_7 = [76	78	81	100	102	212	213	214	241];
    macro_network_nodes_8 = [41	43	59	66	67	69	71	73	74	175	177	200	201	204	206	209	210	240];

    % macro_network_nodes_1 = [1 2 3];
    % macro_network_nodes_2 = [4 5 6];
    % macro_network_nodes_3 = [7 8 9];
    % macro_network_nodes_4 = [10 11 12];

    dimension = 268;
    n_nets = 8;
    macronet_within_masks = zeros(dimension,dimension,n_nets);
    macronet_between_masks = zeros(dimension,dimension,n_nets);
    
    diag_zeros = ones(dimension,dimension);
    for i=1:length(diag_zeros)
        diag_zeros(i,i) = 0;
    end

    heatmap(diag_zeros)
    macro_network_nodes = {macro_network_nodes_1; macro_network_nodes_2; macro_network_nodes_3; macro_network_nodes_4; macro_network_nodes_5; macro_network_nodes_6; macro_network_nodes_7; macro_network_nodes_8};
    %macro_network_nodes = {macro_network_nodes_1; macro_network_nodes_2; macro_network_nodes_3; macro_network_nodes_4;};

    for m =1:length(macro_network_nodes)
        macronet_between_masks(macro_network_nodes{m}, :, m) = 1;
        macronet_between_masks(:, macro_network_nodes{m}, m) = 1;

        for i=1:length(macro_network_nodes{m})
            for j=1:length(macro_network_nodes{m})
                macronet_within_masks(macro_network_nodes{m}(i),macro_network_nodes{m}(j), m)=1;
            end
        end
        macronet_within_masks(:,:,m) = macronet_within_masks(:,:,m).*diag_zeros;
        macronet_between_masks(:,:,m) = macronet_between_masks(:,:,m) - macronet_within_masks(:,:,m);
        macronet_between_masks(:,:,m) = macronet_between_masks(:,:,m).*diag_zeros;
        %figure
        %heatmap(macronet_within_masks(:,:,m))
        %figure
        %heatmap(macronet_between_masks(:,:,m))
    end

    macronet_masks = cat(3, macronet_within_masks,  macronet_between_masks);
