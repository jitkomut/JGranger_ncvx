%% This experiment estimate VAR with formulation D by ADMM
clear
clc
inpath = './data_compare/';
outpath = 'G:\My Drive\0FROM_SHARED_DRIVE\THESIS\formulation_C_magda\';

type = 2; %D type
% cd = 3; %common density set to percent(cd); percent=[1%, 5%, 10%, 20%]
T = 100;
p = 1;
K = 5;
n = 20; % time-series channels
[P,~] = offdiagJSS(n,p,K);
load([inpath,'model_K',int2str(K),'_p1']) % struct E
[~,~,~,m] = size(E);
dd = 2;
GridSize = 30;
mname = {'10','20'};
cnt = 0;
for ii=3:4
    cnt = cnt+1;
    for jj=1:m
        % generate data from given seed
        model = E{type,ii,dd,jj};
        y = sim_VAR(model.A,T,1,model.seed,0);
        % M = formulation_C(y,p,GridSize);
        M = cvx_CGN(y,p,GridSize,'static');
        save([outpath,'result_JSS_formulationC_',mname{cnt},'percent','_',int2str(jj)],'M')
    end
end
