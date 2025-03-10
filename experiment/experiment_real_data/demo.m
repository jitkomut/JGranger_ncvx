clear
clc
selected_TDC = {'0010023';'0010024';'0010070';'0010088';'0010092';'0010112';'0010122';'0010123';'0010128';'1000804';'1435954';'3163200';'3243657';'3845761';'4079254';'8692452';'8834383';'9750701'};
selected_ADHD_C = {'0010013';'0010017';'0010019';'0010022';'0010025';'0010037';'0010042';'0010048';'0010050';'0010086';'0010109';'1187766';'1283494';'1918630';'1992284';'2054438';'2107638';'2497695'};
y_TDC = concat_real_data(selected_TDC,116,'nyu',0);
y_TDC = y_TDC-mean(y_TDC,2);
y_ADHD_C = concat_real_data(selected_ADHD_C,116,'nyu',0);
y_ADHD_C = y_ADHD_C-mean(y_ADHD_C,2);
K = size(y_TDC,3);
y_TDC_concat = reshape(y_TDC,[116,172*18]);
y_ADHD_C_concat = reshape(y_ADHD_C,[116,172*18]);
y_TDC_concat = detrend(y_TDC_concat')';
y_ADHD_C_concat = detrend(y_ADHD_C_concat')';
% y_total(:,:,1) = y_TDC_concat;
% y_total(:,:,2) = y_ADHD_C_concat;
y_total = cat(3,y_TDC,y_ADHD_C);
y_total = y_total-mean(y_total,2);
%% ESTIMATE MODEL USING CONCATENATION K=2
% M = test_cvxformulation_D(y_total,1,30,'adaptive_L',1);
% save('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_D_unfiltered_timecorrected','M')
clear M
M = test_cvxformulation_S(y_total,1,30,'adaptive_D',1);
save('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_S_unfiltered_timecorrected','M')
%% ESTIMATE MODEL USING K = 18
% FORMULATION C
clear M
M.TDC = test_cvxformulation_C(y_TDC,1,30);
M.ADHD_C = test_cvxformulation_C(y_ADHD_C,1,30);
save('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_18K_C_unfiltered','M')
%%
% FORMULATION D
clear M
M.TDC = test_cvxformulation_D(y_TDC,1,30);
M.ADHD_C = test_cvxformulation_D(y_ADHD_C,1,30);
save('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_18K_D','M')
%%
% FORMULATION S
clear M
M.TDC = test_cvxformulation_S(y_TDC,1,30);
M.ADHD_C = test_cvxformulation_S(y_ADHD_C,1,30);
save('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_18K_S','M')
%% LOAD SAVED MODEL
load('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_D_unfiltered')
M = augment_score(M,size(y_total,2),'LLH_hetero');
%% LOAD MODEL K=18
load('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_18K_C_unfiltered')
M.TDC = augment_score(M.TDC,size(y_TDC,2),'LLH_hetero');
M.ADHD_C = augment_score(M.ADHD_C,size(y_TDC,2),'LLH_hetero');
%%


%% FIND PEARSON CORRELATION & PARTIAL CORRELATION
for kk=1:2
M.pearson_corr(:,:,kk) = corr(y_total(:,:,kk)');
M.partial_corr(:,:,kk) = partialcorr(y_total(:,:,kk)');
end
%% ROIs SELECTION & PLOT
AAL_116.name = {'PreCG_L','PreCG_R','SFGdor_L','SFGdor_R','ORBsup_L','ORBsup_R','MFG_L','MFG_R','ORBmid_L','ORBmid_R','IFGoperc_L','IFGoperc_R','IFGtriang_L','IFGtriang_R','ORBinf_L','ORBinf_R','ROL_L','ROL_R','SMA_L','SMA_R','OLF_L','OLF_R','SFGmed_L','SFGmed_R','ORBsupmed_L','ORBsupmed_R','REC_L','REC_R','INS_L','INS_R','ACG_L','ACG_R','MCG_L','MCG_R','PCG_L','PCG_R','HIP_L','HIP_R','PHG_L','PHG_R','AMYG_L','AMYG_R','CAL_L','CAL_R','CUN_L','CUN_R','LING_L','LING_R','SOG_L','SOG_R','MOG_L','MOG_R','IOG_L','IOG_R','FFG_L','FFG_R','PoCG_L','PoCG_R','SPG_L','SPG_R','IPG_L','IPG_R','SMG_L','SMG_R','ANG_L','ANG_R','PCUN_L','PCUN_R','PCL_L','PCL_R','CAU_L','CAU_R','PUT_L','PUT_R','PAL_L','PAL_R','THA_L','THA_R','HES_L','HES_R','STG_L','STG_R','TPOsup_L','TPOsup_R','MTG_L','MTG_R','TPOmid_L','TPOmid_R','ITG_L','ITG_R','Cerebelum_Crus1_L','Cerebelum_Crus1_R','Cerebelum_Crus2_L','Cerebelum_Crus2_R','Cerebelum_3_L','Cerebelum_3_R','Cerebelum_4_5_L','Cerebelum_4_5_R','Cerebelum_6_L','Cerebelum_6_R','Cerebelum_7b_L','Cerebelum_7b_R','Cerebelum_8_L','Cerebelum_8_R','Cerebelum_9_L','Cerebelum_9_R','Cerebelum_10_L','Cerebelum_10_R','Vermis_1_2','Vermis_3','Vermis_4_5','Vermis_6','Vermis_7','Vermis_8','Vermis_9','Vermis_10'};
AAL_116.DMN = [23,24,31,32,35,36,67,68,65,66];
AAL_116.FPN = [65,66,7,8,11,12,13,14,61,62];
AAL_116.CC = [31,32,33,34,35,36];
% atlas_index = [7,8,11,12,13,14,15,16,31,32,35,36,67,68,19,20];
% atlas_index = union(AAL_116.DMN,AAL_116.FPN,'stable');
% atlas_index = [7:10, 12,14,16]; %MFG and IFG_R extra link [NOT FOUND]
% atlas_index = [32,35,36]; % R_dACC and PCC Decrease (32 -> 35,36) [FOUND MISSING LINK PCC -> R_dACC]
atlas_index = [19,20,7:10]; %SMA -> MFG Increase (19,20 -> 7:10) [found extra links from both SMA_L,R to MFG Orbital]
% atlas_index = [11:16,19,20]; %IFG -> SMA Increase (11:16 -> 19,20)

set(groot, 'DefaultAxesTickLabelInterpreter', 'none')
index = M.index.eBIC;
clf
close all
figure(1);
tt= tiledlayout(3,2);
tt.TileSpacing = 'compact';
tt.Padding = 'compact';
name_list = {'TDC','ADHD'};
for kk=1:2
    nexttile;
imagesc(M.model(index).GC(atlas_index,atlas_index,kk).*(1-eye(length(atlas_index))))
grid on
set(gca,'xtick',1:1:length(atlas_index),'ytick',1:1:length(atlas_index), ...
    'xticklabel',AAL_116.name(atlas_index),'yticklabel',AAL_116.name(atlas_index))
axis('square')
title(name_list{kk})
colormap(jet)
xtickangle(30)
% caxis([0 1])
% hold on
% scatter(1:1:length(atlas_index),1:1:length(atlas_index),50,'ok')
% hold off
end
for kk=1:2
% subplot(1,2,kk)
nexttile;
imagesc(abs(M.partial_corr(atlas_index,atlas_index,kk).*(1-eye(length(atlas_index)))))
grid on
set(gca,'xtick',1:1:length(atlas_index),'ytick',1:1:length(atlas_index), ...
    'xticklabel',AAL_116.name(atlas_index),'yticklabel',AAL_116.name(atlas_index))
axis('square')
title(name_list{kk})
colormap(jet)
xtickangle(30)
caxis([0 1])
end
for kk=1:2
% subplot(1,2,kk)
nexttile;
imagesc(abs(M.pearson_corr(atlas_index,atlas_index,kk).*(1-eye(length(atlas_index)))))
grid on
set(gca,'xtick',1:1:length(atlas_index),'ytick',1:1:length(atlas_index), ...
    'xticklabel',AAL_116.name(atlas_index),'yticklabel',AAL_116.name(atlas_index))
axis('square')
title(name_list{kk})
colormap(jet)
xtickangle(30)
caxis([0 1])
end
%%
clf
close all
TDC_GC = (1-eye(116)).*M.model(M.index.eBIC).GC(:,:,1);
ADHD_GC = (1-eye(116)).*M.model(M.index.eBIC).GC(:,:,2);

figure(1)
histogram(TDC_GC(TDC_GC~=0))
hold on
histogram(ADHD_GC(ADHD_GC~=0))
hold off
%%
clf
close all
set(groot, 'DefaultAxesTickLabelInterpreter', 'none')
TDC_GC = (1-eye(116)).*M.model(M.index.eBIC).GC(:,:,1);
ADHD_GC = (1-eye(116)).*M.model(M.index.eBIC).GC(:,:,2);
% atlas_index = AAL_116.DMN;
% atlas_index = 1:116;
atlas_index = [7,8,11,12,13,14,15,16,31,32,35,36,67,68,19,20];
TDC_GC_print = TDC_GC(atlas_index,atlas_index);
ADHD_GC_print = ADHD_GC(atlas_index,atlas_index);
% TDC_GC_print(TDC_GC_print<0.3) = 0;
% ADHD_GC_print(ADHD_GC_print<0.3) = 0;

tmp = AAL_116.name((atlas_index));
figure(1)
circularGraph(TDC_GC_print,'Label',tmp);
figure(2)
circularGraph(ADHD_GC_print,'Label',tmp);