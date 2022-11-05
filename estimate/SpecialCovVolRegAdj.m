% -------------------------------------------------------------------------
% 残差协方差：波动率偏误调整（全局运行）
% -------------------------------------------------------------------------
% [输入]
% paramSet：           全局参数集合
% daily_info：         日频数据集合
% specialCovBiasAdj：  贝叶斯压缩调整后的残差协方差（stockNum * dayNum）
% specialReturn：      残差收益率序列（stockNum * dayNum）
% [输出]
% specialCovVolRegAdj：残差协方差估计（stockNum * dayNum)
% lambdaSall：         特异波动率调整系数（1 * dayNum）
% CSVSt：              截面特异性波动率（1 * dayNum）
% -------------------------------------------------------------------------
function [specialCovVolRegAdj,lambdaSall,CSVSt] = SpecialCovVolRegAdj(...
        paramSet,daily_info,specialCovBiasAdj,specialReturn)

fprintf('残差协方差矩阵贝叶斯压缩调整');tic;

% 参数准备
timeWin = paramSet.SpecialCov.VolRegAdj.timeWindow;             
halfLife = paramSet.SpecialCov.VolRegAdj.halfLife;             
[stockNum,dayNum] = size(specialCovBiasAdj);

% 半衰期权重
weight = power(0.5,(timeWin:-1:1)/halfLife);  

% 市值处理
weightCap = daily_info.close .* daily_info.float_a_shares;
threshold = prctile(weightCap,paramSet.global.mktBlockRatio);
weightCap = min(weightCap,repmat(threshold,size(weightCap,1),1));  
switch paramSet.global.capSqrtFlag
    case 0
        weightCap = weightCap.^1;
    case 1
        weightCap = weightCap.^0.5;
end

% 对特质收益率序列去极值
returnDay = specialReturn;                          
maxNum = 3;
tempMatrix = maxNum * repmat((nanstd((returnDay')))',[1,dayNum]);
returnDay(returnDay>tempMatrix) = tempMatrix(returnDay>tempMatrix);
tempMatrix = -maxNum*repmat((nanstd((returnDay')))',[1,dayNum]);
returnDay(returnDay<tempMatrix) = tempMatrix(returnDay<tempMatrix);
logReturnDay = log(returnDay+1);

% 计算月度收益
logReturnMonth = nan(stockNum,dayNum);
for iDay = 1:dayNum-21+1
    logReturnMonth(:,iDay) = sum(logReturnDay(:,iDay:(iDay+21-1)),2);
end
returnMonth = exp(logReturnMonth) - 1;

% 初始化结果
specialCovVolRegAdj = nan(stockNum,dayNum);
lambdaSall = nan(1,dayNum);

% 波动率偏误调整                      
returnToSSigma = returnMonth.^2 ./ specialCovBiasAdj.^2;                
returnToSSigma(returnToSSigma==inf) = nan;                                     
tempMarketValue = weightCap;
tempMarketValue(isnan(returnToSSigma)) = 0;
sumMarketValue = sum(tempMarketValue,1,'omitnan');                        
marketValueWeight = tempMarketValue ./ repmat(sumMarketValue,[stockNum,1]);  
% marketValueWeight = weightCap ./ repmat(sumMarketValue,[stockNum,1]); 
marketValueWeight(marketValueWeight==inf) = nan;
returnToSpcSig = sum(marketValueWeight.*returnToSSigma,'omitnan');
for iDay = timeWin:dayNum
    % 特质波动率调整系数
    data = returnToSpcSig(iDay-timeWin+1:iDay);
    lambdaSall(iDay) = nansum(data.*weight,2) ./ sum(weight(~isnan(data)));
    % 特质波动率调整
    specialCovVolRegAdj(:,iDay) = lambdaSall(iDay)^0.5 * specialCovBiasAdj(:,iDay); 
end
specialCovVolRegAdj(specialCovVolRegAdj==0) = nan;

% 截面特质波动率
goodDataReturn = isnan(returnDay+weightCap);
returnDay(goodDataReturn) = nan;
weightCap(goodDataReturn) = nan;
weightCap = weightCap./repmat(nansum(weightCap),[stockNum,1]);
CSVSt = sqrt(nansum(returnDay.^2 .* weightCap));

fprintf('  耗时：%.4f秒\n',toc);

end