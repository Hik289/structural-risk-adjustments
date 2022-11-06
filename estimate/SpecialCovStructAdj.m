% -------------------------------------------------------------------------
% 残差协方差：结构化调整
% -------------------------------------------------------------------------
% [输入]
% paramSet：      全局参数集合
% daily_info：    日频数据集合
% specialCovNW：  NW调整后的残差协方差（stockNum * dayNum）
% factorExpo：    因子暴露集合（stockNum * factorNum * dayNum）
% [输出]
% specialCovStructAdj：  残差协方差估计（stockNum * dayNum)
% -------------------------------------------------------------------------
function specialCovStructAdj = SpecialCovStructAdj(paramSet,daily_info,specialCovNW,factorExpo)

fprintf('残差协方差矩阵结构化调整');tic;

% 参数准备
timeWin = paramSet.SpecialCov.StructAdj.timeWindow;
E0 = paramSet.SpecialCov.StructAdj.E0;       
regressMode = paramSet.SpecialCov.StructAdj.regressMode;    
factorNum = paramSet.SpecialCov.StructAdj.factorNum;
[stockNum,dayNum] = size(specialCovNW);

% 初始化结果
specialCovStructAdj = nan(stockNum,dayNum);
specialCovStructGama = nan(stockNum,dayNum);

% 计算回归权重
if isequal(regressMode,'WLS')                              
    weightCap = daily_info.close .* daily_info.float_a_shares;
    threshold = prctile(weightCap,paramSet.global.mktBlockRatio);
    weightCap = min(weightCap,repmat(threshold,size(weightCap,1),1));  
    weightCap(isnan(weightCap)) = 0;  
else
    weightCap = ones(size(daily_info.close));
end

% 遍历每个截面
for iDay = max(timeWin,paramSet.updateTBegin):dayNum
    
    % ---------------------------------------------------------------------
    % 计算每支股票的协调参数
    % ---------------------------------------------------------------------
    % 截取参与计算的时窗样本
    tempData = specialCovNW(:,iDay-timeWin+1:iDay);                     
    % 稳健标准差 SigmaU
    Q3 = prctile(tempData,75,2);                                          
    Q1 = prctile(tempData,25,2);                                         
    SigmaU = (1/1.35)*(Q3-Q1);                                              
    % 计算特异收益的样本标准差
    SigmaUEQ = std(tempData,0,2,'omitnan');                                  
    % 计算Zu 用于判断尾肥程度
    Zu = abs(SigmaUEQ./SigmaU-1);    
    % 计算gamma
    timeWinValid = sum(~isnan(tempData),2);                               
    gammaNum1 = min(1,max(0,timeWinValid/120-0.5));                       
    gammaNum2 = min(1,exp(1-Zu));                                  
    specialCovStructGama(:,iDay) = gammaNum1 .* gammaNum2;    
    
    % ---------------------------------------------------------------------
    % 对于所有协调参数为1的优质股票，将股票特异性收益的波动率对数对所有因子
    % 暴露做线性回归，得到每个因子对特异波动的贡献值
    % ---------------------------------------------------------------------
    % 提取处理后的因子暴露                  
    panelFactorExpo = factorExpo(:,1:factorNum,iDay);  
    % 提取取gammaAll=1且数值非空的个股索引
    lnSigma = log(specialCovNW(:,iDay));                              
    lineNoNan = ~isnan(sum([lnSigma,panelFactorExpo],2));                      
    gamma1data = specialCovStructGama(:,iDay)==1;                                  
    goodDataNum = gamma1data & lineNoNan;                                 
    if sum(goodDataNum)<12
        continue;
    end
    % 获取回归自变量、因变量、权重
    Y = lnSigma(goodDataNum);
    X = panelFactorExpo(goodDataNum,:);
    w = weightCap(goodDataNum,iDay);
    % 获取回归解析解
    beta = zeros(size(X,2),1);
    validCol = sum(X~=0)>0;
    validX = X(:,validCol);
    beta(validCol) = (validX'*diag(w)*validX) \ (validX'*diag(w)*Y);
    
    % ---------------------------------------------------------------------
    % 获取每支股票的结构化波动率预测值，和已有结果线性加权
    % 暴露做线性回归，得到每个因子对特异波动的贡献值
    % ---------------------------------------------------------------------
    % 获取每支股票的结构化波动率预测值
    sigmaSTR = E0 * exp(panelFactorExpo*beta);                               
    % 生成结果
    specialCovStructAdj(:,iDay) = ...
        specialCovNW(:,iDay) .* specialCovStructGama(:,iDay) +...
        sigmaSTR .* (1-specialCovStructGama(:,iDay));
    
end

% 修正缺失值
specialCovStructAdj(specialCovStructAdj==0) = nan;

% 如果是增量运行模式，则需要和历史结果拼接
if paramSet.updateTBegin ~= 1
    % 获取历史数据
    histResult = importdata([paramSet.global.save_path 'specialCovStructAdj.mat']);
    [n_stocks_before,~,~] = size(histResult);
    % 股票维度更新
    [n_stocks_after,~,n_days_new] = size(specialCovStructAdj);
    if n_stocks_before < n_stocks_after
        histResult(n_stocks_before+1:n_stocks_after,:) = nan;
    end
    % 时间维度更新    
    id_last_nan = find(sum(~isnan(specialCovStructAdj))==0,1,'last');
    histResult(:,id_last_nan+1:n_days_new) = specialCovStructAdj(:,id_last_nan+1:n_days_new);
    % 返回结果
    specialCovStructAdj = histResult;
end

fprintf('  耗时：%.4f秒\n',toc);

end