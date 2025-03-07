%% Real data experiment
% The goal of this experiment is to study the effective connectivity
% differences between ADHD and TDC by using proposed formulations.
% Setting
% - use cvx-DGN, cvx-FGN to estimate concatenation of K=18 subjects in each of ADHD and TDC data sets
% - use cvx-CGN to estimate two models from K=18 ADHD and TDC respectively
% the common part of GC matrix in each model will be considered as group
% level GC.

%% Data concatenation
clear
clc
selected_TDC = {'0010023';'0010024';'0010070';'0010088';'0010092';'0010112';'0010122';'0010123';'0010128';'1000804';'1435954';'3163200';'3243657';'3845761';'4079254';'8692452';'8834383';'9750701'};
selected_ADHD_C = {'0010013';'0010017';'0010019';'0010022';'0010025';'0010037';'0010042';'0010048';'0010050';'0010086';'0010109';'1187766';'1283494';'1918630';'1992284';'2054438';'2107638';'2497695'};
y_TDC = concat_real_data(selected_TDC,116,'nyu',0);
y_ADHD_C = concat_real_data(selected_ADHD_C,116,'nyu',0); % load data in format (n,T,K)
y_TDC = y_TDC-mean(y_TDC,2);
y_ADHD_C = y_ADHD_C-mean(y_ADHD_C,2);
K = size(y_TDC,3);
y_total = cat(3,y_TDC,y_ADHD_C);
y_total = y_total-mean(y_total,2); % detrend in time axis
%% cvx-DGN estimation
p = 1; % VAR order
GridSize = 30; % resolution of regularization grid
data_concat = 1; % set to 1 for time-series concatenation without dependency 
weight_def = 'adaptive_L'; % set weight, toggle = 'static' is to set weight to unity
toggle = 'LLH_hetero';
M = cvx_DGN(y_total,p,GridSize,weight_def,toggle,data_concat);% data with dimension (n,T*K,2), K is # subjects in each TDC, ADHD
save('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_D_unfiltered_timecorrected_LLHcorrected','M')
%% cvx-FGN estimation
p = 1;
GridSize = 30;
data_concat = 1;
weight_def = 'adaptive_D';
toggle = 'LLH_hetero';
M = cvx_FGN(y_total,p,GridSize,weight_def,toggle,data_concat);% data with dimension (n,T*K,2), K is # subjects in each TDC, ADHD
save('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_S_unfiltered_timecorrected_LLHcorrected','M')
%% cvx-CGN estimation
clear M
p = 1; % VAR order
GridSize = 30;
data_concat = 0; % This case does not require concatenation.
weight_def = 'adaptive_L';
toggle = 'LLH_hetero';
M.TDC = test_cvxformulation_C(y_TDC,p,GridSize,weight_def,toggle,data_concat); % data with dimension (n,p,K)
M.ADHD_C = test_cvxformulation_C(y_ADHD_C,p,GridSize,weight_def);
save('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_18K_C_unfiltered','M')
%% Perform model selection correction by setting noise correlation structure to be diagonal: DGN
load('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_D_unfiltered_timecorrected','M')
p = 1;
GridSize = 30;
data_concat = 1;
weight_def = 'adaptive_L';
toggle = 'LLH_hetero';
M = correction_S(y_total,M,'LLH_hetero',p,GridSize,weight_def,toggle,data_concat);
save('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_D_unfiltered_timecorrected_LLHcorrected','M')
%% Perform model selection correction by setting noise correlation structure to be diagonal: FGN
load('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_S_unfiltered_timecorrected','M')
p = 1;
GridSize = 30;
data_concat = 1;
weight_def = 'adaptive_D';
toggle = 'LLH_hetero';
M = correction_S(y_total,M,'LLH_hetero',p,GridSize,weight_def,data_concat);
save('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_S_unfiltered_timecorrected_LLHcorrected','M')
%% summarize result
% D2K
load('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_D_unfiltered_timecorrected_LLHcorrected')
tmp = [M.model]; tmp = [tmp.stat]; tmp = [tmp.model_selection_score];
eBIC = [tmp.eBIC];
[~,I] = sort(eBIC);

for ii=1:3
result.TDC_index.D2K{ii} = M.model(I(ii)).ind{1}{1};
result.ADHD_index.D2K{ii} = M.model(I(ii)).ind{1}{2};
end

% S2K
clear M
load('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_S_unfiltered_timecorrected_LLHcorrected')
tmp = [M.model]; tmp = [tmp.stat]; tmp = [tmp.model_selection_score];
eBIC = [tmp.eBIC];
[~,I] = sort(eBIC);

for ii=1:3
result.TDC_index.S2K{ii} = M.model(I(ii)).ind{1}{1};
result.ADHD_index.S2K{ii} = M.model(I(ii)).ind{1}{2};
end

% C18K
clear M
clear I % because it will be struct variable.
load('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_18K_C_unfiltered')
M.TDC = augment_score(M.TDC,size(y_TDC,2),'LLH_hetero');
tmp = [M.TDC.model]; tmp = [tmp.stat]; tmp = [tmp.model_selection_score];
eBIC = [tmp.eBIC];
[~,I.TDC] = sort(eBIC);
M.ADHD_C = augment_score(M.ADHD_C,size(y_ADHD_C,2),'LLH_hetero');
tmp = [M.ADHD_C.model]; tmp = [tmp.stat]; tmp = [tmp.model_selection_score];
eBIC = [tmp.eBIC];
[~,I.ADHD_C] = sort(eBIC);
for ii=1:3
result.TDC_index.C18K{ii} = M.TDC.model(I.TDC(ii)).ind_common{1};
result.ADHD_index.C18K{ii} = M.ADHD_C.model(I.ADHD_C(ii)).ind_common{1};
end
save('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\summary_real_DS2K_C18K_timecorrected_LLHcorrected','result')

%% Convert to weighted Adjacency matrix
outpath = './experiment/result_to_plot/';
% D2K
load('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_D_unfiltered_timecorrected_LLHcorrected')
AdjTDC = M.model(M.index.eBIC).GC(:,:,1)';
AdjADHD = M.model(M.index.eBIC).GC(:,:,2)';
writematrix(AdjTDC,[outpath,'AdjTDC_D2K.txt'],'Delimiter','tab')
writematrix(AdjADHD,[outpath,'AdjADHD_D2K.txt'],'Delimiter','tab')

% F2K
clear M
load('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_2K_S_unfiltered_timecorrected_LLHcorrected')
AdjTDC = M.model(M.index.eBIC).GC(:,:,1)';
AdjADHD = M.model(M.index.eBIC).GC(:,:,2)';
writematrix(AdjTDC,[outpath,'AdjTDC_F2K.txt'],'Delimiter','tab')
writematrix(AdjADHD,[outpath,'AdjADHD_F2K.txt'],'Delimiter','tab')

% C18K
clear M
load('G:\My Drive\0FROM_SHARED_DRIVE\THESIS\Real_data\experiment_real_data_result\estim_18K_C_unfiltered')
M.TDC = augment_score(M.TDC,size(y_TDC,2),'LLH_hetero');
M.ADHD_C = augment_score(M.ADHD_C,size(y_ADHD_C,2),'LLH_hetero');

AdjTDC = mean(M.TDC.model(M.TDC.index.eBIC).GC,3)';
AdjADHD = mean(M.ADHD_C.model(M.ADHD_C.index.eBIC).GC,3)';
writematrix(AdjTDC,[outpath,'AdjTDC_C18K.txt'],'Delimiter','tab')
writematrix(AdjADHD,[outpath,'AdjADHD_C18K.txt'],'Delimiter','tab')