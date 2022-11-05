% -------------------------------------------------------------------------
% 因子协方差：Newey-West调整（效率较高，直接全局运行）
% -------------------------------------------------------------------------
% [输入]
% paramSet：      全局参数集合
% factorReturn：  因子收益率序列（factorNum * dayNum）
% [输出]
% factorCov：     因子协方差估计（styleNum * styleNum * dayNum)
% -------------------------------------------------------------------------
function factorCov = FactorCovNeweyWest(paramSet, factorReturn)

fprintf('因子协方差矩阵Newey-West调整');tic;

% 参数准备
tBegin = paramSet.FactorCov.NW.tBegin;
timeWin = paramSet.FactorCov.NW.timeWindow;
halfLife = paramSet.FactorCov.NW.halfLife;
dayNumOfMonth = paramSet.FactorCov.NW.dayNumOfMonth;
D = paramSet.FactorCov.NW.D;

% 获取因子收益率序列
[styleNum,dayNum] = size(factorReturn);

% 半衰期权重序列
weightList = power(0.5,(timeWin:-1:1)/halfLife);      

% 初始化结果
factorCov = nan(styleNum,styleNum,dayNum);

% 遍历每个截面
for iDay = tBegin : dayNum
    
    % 获取窗口期样本
    data = factorReturn(:,iDay-timeWin+1:iDay);
    if sum(sum(~isnan(data)))<5                                        
        data = nan(size(data));
    end
    
    % 计算因子协方差
    weight = weightList / sum(weightList);
    data = data - repmat(sum(data.*weight,2,'omitnan'),[1,timeWin]);    
    FNW = data * diag(weight) * data';
    
    % 考虑自相关项
    for q = 1:D
        k = 1- q/(D+1);
        sumw = sum(weightList(q+1:end));
        weight= weightList(q+1:end) / sumw;
        dataleft = data(:,q+1:end) * diag(weight) * data(:,1:end-q)';
        dataright = data(:,1:end-q) * diag(weight) * data(:,q+1:end)';
        FNW = FNW + k * (dataleft + dataright);
    end
    
    % 保存结果
    factorCov(:,:,iDay) = dayNumOfMonth * FNW;   
    
end

fprintf('  耗时：%.4f秒\n',toc);

end
