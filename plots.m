macro_ntwrks = ["Medial frontal"	"Frontoparietal"	"Default mode"	"Subcortical-cerebellum"	"Motor"	"Visual I"	"Visual II"	"Visual association"];

figure
subplot(1,3,1)
bar(mean_parameters.slope_pos_ntwrk)
hold on
errorbar([1,2,3,4,5,6,7,8], mean_parameters.slope_pos_ntwrk, ci_parameters.slope_pos_ntwrk(1,:), ci_parameters.slope_pos_ntwrk(2,:))
xticklabels(macro_ntwrks)
xtickangle(90)

subplot(1,3,2)
bar(mean_parameters.slope_neg_ntwrk)
hold on
errorbar([1,2,3,4,5,6,7,8], mean_parameters.slope_neg_ntwrk, ci_parameters.slope_neg_ntwrk(1,:), ci_parameters.slope_neg_ntwrk(2,:))
xticklabels(macro_ntwrks)
xtickangle(90)


subplot(1,3,3)
bar(mean_parameters.slope_combined_ntwrk)
hold on
errorbar([1,2,3,4,5,6,7,8], mean_parameters.slope_combined_ntwrk, ci_parameters.slope_combined_ntwrk(1,:), ci_parameters.slope_combined_ntwrk(2,:))
xticklabels(macro_ntwrks)
xtickangle(90)