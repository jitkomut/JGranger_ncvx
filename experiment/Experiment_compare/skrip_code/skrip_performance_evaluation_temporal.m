%% this script evaluate performance of ....
clear
clc
close all
modelpath = './data_compare/';
inpath = './experiment/Experiment_compare/skrip_code/data_R_formulationS/';
outpath = './experiment/Experiment_compare/skrip_code/data_R_formulationS/';
type = 3; %S type
cd = 3; %common density set to percent(cd); percent=[1%, 5%, 10%, 20%]
T = 100;
p = 1;
K = 5;
n = 20; % time-series channels
[P,~] = offdiagJSS(n,p,K);
load([modelpath,'model_K',int2str(K),'_p1']) % struct E
[~,~,dd,m] = size(E);
% dd=1;
realization = 100;
% m=20;
GridSize = 30;
mname = {'1','5'};

for ii=1:dd
jj=0;
    for tmp_jj=[19:53 55:61 63 64 66 67 69 71 72 74 75 82 83 90 91]
        jj=jj+1;
        fprintf('(%d,%d)\n',ii,tmp_jj)
        % performance eval
        model = E{type,cd,ii,tmp_jj};
        D = readtable([inpath,'K',int2str(K),'_Final_Est_',mname{ii},'percent_',int2str(tmp_jj),'.csv']);
        D = table2array(D);
        D = D(:,2:end); % D = size (n,n*K), p=1
        A = reshape(D,[n,n,K]);
        ind_nz = cell(K,1);
        for kk=1:K
            ind_nz{kk} = setdiff(find(A(:,:,kk)),1:n+1:n^2);
        end
        [ind_common,ind_differential] = split_common_diff(ind_nz,[n,p,K]); % find common and differential off-diagonal nonzero index
        common_confusion = compare_sparsity(model.ind_common,ind_common{1},n,K,'single_common');
        common_score = performance_score(common_confusion);
        differential_confusion = compare_sparsity(model.ind_differential,ind_differential{1},n,K,'single_differential');
        differential_score = performance_score(differential_confusion);
        total_confusion = compare_sparsity(model.ind,ind_nz,n,K,'single_differential');
        total_score = performance_score(total_confusion);
        total_score.bias = sqrt(sum((A-model.A).^2,'all')/sum(model.A.^2,'all'));
        score(ii).total.TPR(jj) = total_score.TPR;
        score(ii).total.FPR(jj) = total_score.FPR;
        score(ii).total.ACC(jj) = total_score.ACC;
        score(ii).total.F1(jj) = total_score.F1;
        score(ii).total.MCC(jj) = total_score.MCC;
        score(ii).bias(jj) =total_score.bias;

        score(ii).common.TPR(jj) = common_score.TPR;
        score(ii).common.FPR(jj) = common_score.FPR;
        score(ii).common.ACC(jj) = common_score.ACC;
        score(ii).common.F1(jj) = common_score.F1;
         score(ii).common.MCC(jj) = common_score.MCC;

        score(ii).differential.TPR(jj) = differential_score.TPR;
        score(ii).differential.FPR(jj) = differential_score.FPR;
        score(ii).differential.ACC(jj) = differential_score.ACC;
        score(ii).differential.F1(jj) = differential_score.F1;
        score(ii).differential.MCC(jj) = differential_score.MCC;
    end
end

save([outpath,'skrip_formulationS_accuracy_K5_55realz'],'score')
