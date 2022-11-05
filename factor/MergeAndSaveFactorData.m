% -------------------------------------------------------------------------
% 将增量部分计算结果和本地历史结果拼接
% -------------------------------------------------------------------------
% [输入]
% paramSet：        全局参数集合
% factorExpoAdd：   因子暴露数据（stockNum * factorNum * dayNum）
% factorReturnAdd： 因子收益率（factorNum * dayNum）
% specialReturnAdd：特质收益率（stockNum * dayNum）
% [输出]
% factorExpo：      因子暴露数据（stockNum * factorNum * dayNum）
% factorReturn：    因子收益率（factorNum * dayNum）
% specialReturn：   特质收益率（stockNum * dayNum）
% -------------------------------------------------------------------------
function [factorExpo,factorReturn,specialReturn] = ...
    MergeAndSaveFactorData(paramSet,factorExpoAdd,factorReturnAdd,specialReturnAdd)

fprintf('拼接计算结果');tic;

if paramSet.updateTBegin == 1 
    
    % 初始化模式
    factorExpo = single(factorExpoAdd);
    factorReturn = factorReturnAdd;
    specialReturn = specialReturnAdd;
    
else
    
    % 拼接因子暴露数据
    factorExpo = importdata([paramSet.global.save_path 'factorExpo.mat']);
    [n_stocks_before,~,~] = size(factorExpo);
    [n_stocks_after,~,n_days_add] = size(factorExpoAdd);
    n_days_after = paramSet.updateTBegin - 1 + n_days_add;
    factorExpo(1:n_stocks_after,:,paramSet.updateTBegin:n_days_after) = factorExpoAdd(:,:,1:end);
    if n_stocks_before < n_stocks_after
        factorExpo(n_stocks_before+1:n_stocks_after,:,1:paramSet.updateTBegin-1) = nan;
    end
    
    % 拼接因子收益率数据
    factorReturn = importdata([paramSet.global.save_path 'factorReturn.mat']);
    firstValidCol = find(sum(~isnan(factorReturnAdd)),1,'first');
    factorReturn(:,paramSet.updateTBegin-1+firstValidCol:n_days_after) = factorReturnAdd(:,firstValidCol:end);
    
    % 拼接残差收益率
    specialReturn = importdata([paramSet.global.save_path 'specialReturn.mat']);
    firstValidCol = find(sum(~isnan(specialReturnAdd)),1,'first');
    specialReturn(1:n_stocks_after,paramSet.updateTBegin-1+firstValidCol:n_days_after) = specialReturnAdd(:,firstValidCol:end);
    if n_stocks_before < n_stocks_after
        specialReturn(n_stocks_before+1:n_stocks_after,1:paramSet.updateTBegin) = nan;
    end
    
end

% 将拼接结果存放到目标路径
save([paramSet.global.save_path 'factorExpo'], 'factorExpo','-v7.3');
save([paramSet.global.save_path 'factorReturn'], 'factorReturn');
save([paramSet.global.save_path 'specialReturn'], 'specialReturn');
    
fprintf('  耗时：%.4f秒\n',toc);

end
