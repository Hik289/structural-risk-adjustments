% -------------------------------------------------------------------------
% 因子暴露计算：成长因子
% -------------------------------------------------------------------------
% [输入]
% paramSet：      全局参数集合
% daily_info：    本地日频数据
% quarterly_info：本地季频信息
% useQuarterLoc： 每天能看到的最新财报索引（stockNum * dayNum) 
% [输出]
% expo：          成长因子暴露（stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = GrowthFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc)

fprintf('成长因子(Growth)暴露度计算');tic;

% 获取季报索引
quarterLoc = getfield(useQuarterLoc,'annual');

% 复合增长率计算的时间窗长（单位为年）
window = paramSet.Growth.yearWindow;

% 复合增长率计算时分母端负值处理
negaOpt = paramSet.Growth.negaOpt;

% -------------------------------------------------------------------------
% 细分因子1：过去5年企业归属母公司净利润的复合增长率(EGRO)
% -------------------------------------------------------------------------
% 获取复合增长率数据
profitGrowth = YearRegressionGrowth(quarterly_info.net_profit_is, window, negaOpt);

% 填充至日频
EGRO = nan(size(daily_info.close));                                             
for iStock = 1:size(EGRO,1)
    % 每天能看到的财报索引
	qLoc = quarterLoc(iStock,:);
    % 填充日频信息
    EGRO(iStock,~isnan(qLoc)) = profitGrowth(iStock,qLoc(~isnan(qLoc)));
end

% -------------------------------------------------------------------------
% 细分因子2：过去5年企业营业总收入的复合增长率(SGRO)
% -------------------------------------------------------------------------
% 获取复合增长率数据
operGrowth = YearRegressionGrowth(quarterly_info.tot_oper_rev, window, negaOpt);

% 填充至日频
SGRO = nan(size(daily_info.close));                                             
for iStock = 1:size(SGRO,1)
    % 每天能看到的财报索引
	qLoc = quarterLoc(iStock,:);
    % 填充日频信息
    SGRO(iStock,~isnan(qLoc)) = operGrowth(iStock,qLoc(~isnan(qLoc)));
end

% 加权合成因子暴露
weightEGRO = paramSet.Growth.EGRO.weight;
weightSGRO = paramSet.Growth.SGRO.weight;
expo = (weightEGRO*EGRO+weightSGRO*SGRO) / (weightEGRO+weightSGRO);

fprintf('  耗时：%.4f秒\n',toc);

end


% -------------------------------------------------------------------------
% 工具函数：采用回归方法计算复合增长率
% data：   财报数据（stockNum * quarterNum）
% window： 回归需要的窗口长度（单位为年）
% negaOpt：分母端负值处理（abs表示取绝对值，nan表示置为空值）
% -------------------------------------------------------------------------
function growth = YearRegressionGrowth(data, window, negaOpt)

% 抽取年频数据（本地数据库从1997年年报开始，也即第一列就是年报数据）
yearlyData = data(:,1:4:end);

% 初始化
yearlyBeta = nan(size(yearlyData));
yearlyMean = nan(size(yearlyData));

% 遍历每个年度，计算复合增长率
for t = window:size(yearlyData,2)
    % 获取窗口内数据
    sample = yearlyData(:,(t-window+1):t);
    % 计算回归系数
    yearlyBeta(:,t) = sample * ((1:window) - (1+window) / 2)' / sqrt((window + 1) * (window - 1) / 12) / window;
    % 计算窗口内均值，并对负值进行处理
    tmpMean = mean(sample,2);
    switch negaOpt
        case 'nan'
            tmpMean(tmpMean<0) = nan;       % 当分母为负时置nan
        case 'abs'
            tmpMean = abs(tmpMean);         % 当分母为负时取绝对值
    end
    yearlyMean(:,t) = tmpMean;
end   

% 计算增长率
yearlyGrowth = yearlyBeta ./ yearlyMean;
yearlyGrowth(isinf(yearlyGrowth)) = nan;

% 将年频数据填充至季频维度
growth = nan(size(data));
growth(:,1:4:end) = yearlyGrowth;

end







