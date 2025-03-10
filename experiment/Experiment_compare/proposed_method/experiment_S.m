%% This experiment estimate VAR with formulation D by ADMM
clear
clc
inpath = './data_compare/';
% outpath = '../formulation_S_result/';
outpath = 'G:/My Drive/0FROM_SHARED_DRIVE/THESIS/formulation_S_result/';
mkdir(outpath)
type = 3; %S type
cd = 3; %common density set to percent(cd); percent=[1%, 5%, 10%, 20%]

p_true = 1;
K = 5;
n = 20; % time-series channels
load([inpath,'model_K',int2str(K),'_p',int2str(p_true)]) % struct E
T = 100;
p_est = 1;
[P,~] = offdiagJSS(n,p_est,K);
Dtmp = diffmat(n,p_est,K);
D = sparse(Dtmp*P);
[~,~,dd,m] = size(E);
realz = m;
GridSize = 30;
mname = {'1','5'};
for jj=1:m
    for ii=1:dd
        % generate data from given seed
        model = E{type,cd,ii,jj};
        y = sim_VAR(model.A,T,1,model.seed,0);
%         M = noncvx_FGN(y,p_est,GridSize);
%         save([outpath,'result_adaptive_formulationS_',mname{ii},'percent','_lag',int2str(p_est),'_K',int2str(K),'_',int2str(jj)],'M')
        M = cvx_FGN(y,p_est,GridSize);
%         save([outpath,'result_adaptive_cvx_formulationS_',mname{ii},'percent','_lag',int2str(p_est),'_K',int2str(K),'_',int2str(jj)],'M')
    end
end
