%% This experiment estimate VAR with formulation D by ADMM
clear
clc
clf
close all
inpath = './data_compare/';
outpath = 'G:/My Drive/0FROM_SHARED_DRIVE/THESIS/experiment_compare_cvx/';
mkdir(outpath)

type = 2; %D type

cd = 2;
T = 120;
p_true = 3;
p_est = 3;
K = 5;
n = 20; % time-series channels
load([inpath,'model_K',int2str(K),'_p',int2str(p_true)]) % struct E
[~,~,dd,m] = size(E);
realz = 1;
r_list = [1];
GridSize = 30;
mname = {'1','5'};
type_acc = {'total','common','differential'};
acc_list = {'ACC','F1','MCC'};
name_list = {'bic','aic','aicc','eBIC','GIC_2','GIC_3','GIC_4','GIC_5','GIC_6'};
type_name = {'cvx','ncvx'};
for test_itr=1:length(r_list)
    jj= r_list(test_itr);
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    for ii=1:dd
        % generate data from given seed
        model = E{type,cd,ii,jj};
        y = sim_VAR(model.A,T,1,model.seed,0);
        M_cvx = test_cvxformulation_D(y,p_est,GridSize);
        M_ncvx = formulation_D(y,p_est,GridSize);
        clc
%         M_cvx=M_ncvx;
%         M_ncvx=M_cvx;
        ALL_RESULT.cvx(ii,jj).model_acc = performance_eval(M_cvx,model);
        ALL_RESULT.ncvx(ii,jj).model_acc = performance_eval(M_ncvx,model);
        for kk=1:length(name_list)
            R.cvx.index(ii,jj).(name_list{kk}) = M_cvx.index.(name_list{kk});
            R.ncvx.index(ii,jj).(name_list{kk}) = M_ncvx.index.(name_list{kk});
        end
        %%% CVX
        ARR = zeros(3,length(name_list));
        for nn=1:length(name_list)
            for kk=1:length(acc_list)
                index_selected = R.cvx.index(ii,jj).(name_list{nn});
                summary.total.(acc_list{kk})(ii,jj) =ALL_RESULT.cvx(ii,jj).model_acc(index_selected).total.(acc_list{kk});
                ARR(kk,nn) = mean(summary.total.(acc_list{kk})(ii,1:jj));
            end
        end
        disp(['CVX, density:',mname{ii},'%'])
        t = array2table(ARR,'VariableNames',name_list,'RowNames', acc_list);
        t.Variables =  round(t.Variables*100,2);
        disp(t)
        % NCVX
        ARR = zeros(3,length(name_list));
        for nn=1:length(name_list)
            for kk=1:length(acc_list)
                index_selected = R.ncvx.index(ii,jj).(name_list{nn});
                summary.total.(acc_list{kk})(ii,jj) =ALL_RESULT.ncvx(ii,jj).model_acc(index_selected).total.(acc_list{kk});
                ARR(kk,nn) = mean(summary.total.(acc_list{kk})(ii,1:jj));
            end
        end
        disp(['NCVX, density:',mname{ii},'%'])
        t = array2table(ARR,'VariableNames',name_list,'RowNames', acc_list);
        t.Variables =  round(t.Variables*100,2);
        disp(t)
        
        figure(ii);
        sgtitle(['total, diff density:',mname{ii},'%'])
        subplot_cnt = 0;
        for fm=1:length(type_name)
            for ss=1:length(acc_list)
                subplot_cnt = subplot_cnt+1;
                val = zeros(30,30);
                max_val = 0;
                for sample=1:test_itr
                    tmp = [ALL_RESULT.(type_name{fm})(ii,test_itr(sample)).model_acc.total];tmp = [tmp.(acc_list{ss})];val = val +reshape(tmp,GridSize,GridSize)/length(r_list);
                    max_val = max_val + max(tmp(:))/length(r_list);
                end
                subplot(2,length(acc_list),subplot_cnt)
                imagesc(val)
                title(sprintf('bestcase=%.3f',max_val))
                axis('square')
                colormap((1-gray).^0.4)
                caxis([0,1])
                set(gca,'xticklabel',[],'yticklabel',[])
                ylabel(acc_list{ss})
            end
        end
    end
end
