% -------------------------------------------------------------------------
% 残差协方差：Newey-West调整
% -------------------------------------------------------------------------
% [输入]
% paramSet：      全局参数集合
% specialReturn： 残差收益率序列（stockNum * dayNum）
% [输出]
% specialCovNW：  因子协方差估计（stockNum * dayNum)，只保留对角线元素
% -------------------------------------------------------------------------
function specialCovNW = SpecialCovNeweyWest(paramSet,specialReturn)

fprintf('残差协方差矩阵Newey-West调整');tic;

% 参数准备
tBegin = paramSet.SpecialCov.NW.tBegin;
timeWin = paramSet.SpecialCov.NW.timeWindow;
halfLife = paramSet.SpecialCov.NW.halfLife;
dayNumOfMonth = paramSet.SpecialCov.NW.dayNumOfMonth;
D = paramSet.SpecialCov.NW.D;

% 数据准备
[stockNum,dayNum] = size(specialReturn);

% 半衰期权重序列
weightList = power(0.5,(timeWin:-1:1)/halfLife);

% 初始化结果
specialCovNW = nan(stockNum,dayNum);

% 遍历每个截面
for iDay = tBegin : dayNum
    
    % 获取窗口期样本
    data = specialReturn(:,iDay-timeWin+1:iDay);
    if sum(sum(~isnan(data)))<5                                        
        data = nan(size(data));
    end
    
    % 去均值
    weight = weightList / sum(weightList);
    data = data - repmat(sum(data.*weight,2,'omitnan'),[1,timeWin]);    
    
    % 计算残差协方差
    SNW = sum (data.^2 .* repmat(weight,[stockNum,1]), 2, 'omitnan');
    for q = 1:D
        k = 1- q/(D+1);
        sumw = sum(weightList(q+1:end));
        weight= weightList(q+1:end) / sumw;
        omega = 2 * sum(data(:,q+1:end).* repmat(weight,[stockNum,1]).* data(:,1:end-q), 2, 'omitnan');
        SNW = SNW + k * omega;
    end
    
    % 存储结果
    specialCovNW(:,iDay) = dayNumOfMonth * SNW;
    
end

% 注意这里取了开方，即特异收益矩阵，实际上是标准差矩阵
specialCovNW = sqrt(specialCovNW);        
specialCovNW(specialCovNW==0) = nan;

fprintf('  耗时：%.4f秒\n',toc);

end
