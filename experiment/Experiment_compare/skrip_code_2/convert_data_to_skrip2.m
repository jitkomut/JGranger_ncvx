%% This experiment estimate VAR with formulation D by ADMM
clear
clc
inpath = './data_compare/';
outpath = './experiment/Experiment_compare/skrip_code_2/data_R_formulationD/';
mkdir(outpath)


type = 2; %D type
cd = 3; %common density set to percent(cd); percent=[1%, 5%, 10%, 20%]
T = 100;
p = 1;
K = 50;
n = 20; % time-series channels
load([inpath,'model_K',int2str(K),'_p',int2str(p)]) % struct E
[~,~,dd,m] = size(E);
realization = m;
mname = {'1','5'};
for ii=1:dd
    for jj=1:realization
        % generate data from given seed
        model = E{type,cd,ii,jj};
        y = sim_VAR(model.A,T,1,model.seed,0);
        y = reshape(permute(y,[1,3,2]),[n*K,T]);
        writematrix(y,[outpath,'K',int2str(K),'_data_',mname{ii},'percent_',int2str(jj),'.csv']) 
    end
end
