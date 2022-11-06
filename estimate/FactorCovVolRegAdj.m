% -------------------------------------------------------------------------
% 因子协方差：波动率偏误调整（全局运行）
% -------------------------------------------------------------------------
% [输入]
% paramSet：      全局参数集合
% factorEigenAdj：特征值调整因子协方差矩阵（factorNum * factorNum * dayNum）
% factorReturn：  因子收益率序列（factorNum * dayNum）
% [输出]
% factorCovVolRegAdj：特波动率偏误调整估计量（styleNum * styleNum * dayNum)
% -------------------------------------------------------------------------
function factorCovVolRegAdj = FactorCovVolRegAdj(paramSet,factorEigenAdj,factorReturn)

fprintf('因子协方差矩阵波动率偏误调整');tic;

% 参数准备
timeWin = paramSet.FactorCov.VolRegAdj.timeWin;    
halfLife = paramSet.FactorCov.VolRegAdj.halfLife;  
[factorNum,~,dayNum] = (size(factorEigenAdj));

% 生成因子未来一个月的对数收益率
logReturnMonth = nan(factorNum,dayNum);
logReturnDay = log(factorReturn+1);
for iDay = 1:dayNum-21+1
    logReturnMonth(:,iDay) = sum(logReturnDay(:,iDay:(iDay+21-1)),2);
end
returnMonth = exp(logReturnMonth) - 1;

% 初始化结果
factorCovVolRegAdj = nan(size(factorEigenAdj));
lambdaFall = nan(1,dayNum);

% 获取单个因子特征值调整后的波动率
singleFactorEigAdj = nan(factorNum,dayNum);
for iDay = 1:dayNum
    singleFactorEigAdj(:,iDay) = diag(factorEigenAdj(:,:,iDay));
end

% 计算所有因子的总偏误统计量
FktToSIGMAkt = returnMonth.^2 ./ singleFactorEigAdj;                     
BFt = nanmean(FktToSIGMAkt);                                              
weight = power(0.5,(timeWin:-1:1)/halfLife);                              
for iDay = timeWin:dayNum
    % 计算波动率调整系数
    data = BFt(iDay-timeWin+1:iDay);
    lambdaF = nansum(data.*weight,2) ./ sum(weight(~isnan(data)));
    lambdaFall(1,iDay) = lambdaF;
    % 进行波动率调整
    factorCovVolRegAdj(:,:,iDay) = lambdaF * factorEigenAdj(:,:,iDay);      
end

% 计算截面因子波动率，用于检验波动率偏误调整结果
% CSVFt = nanstd(returnMonth,1,1);

fprintf('  耗时：%.4f秒\n',toc);

end