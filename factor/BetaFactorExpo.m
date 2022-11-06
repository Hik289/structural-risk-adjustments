% -------------------------------------------------------------------------
% 因子暴露计算：Beta因子
% -------------------------------------------------------------------------
% [输入]
% paramSet：   全局参数集合
% daily_info： 本地日频数据
% index_info： 基准指数相关信息
% [输出]
% expo：       Beta因子暴露（stockNum * dayNum)
% volResidual：残差波动率（stockNum * dayNum)，用于计算波动率因子
% -------------------------------------------------------------------------
function [expo,volResidual] = BetaFactorExpo(paramSet,daily_info,index_info)

fprintf('BETA因子(Beta)暴露度计算');tic;

% 时窗长度
timeWindow = paramSet.Beta.timeWindow;                   

% 权重指数衰减的半衰期
halfLifeDays = paramSet.Beta.halfLife;   

% 权重向量
dampling = power(1/2,(timeWindow:-1:1)/halfLifeDays);         

% 个股的收益率序列
stockReturn = tick2ret(daily_info.close_adj')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];
[stockNum,dayNum] = size(stockReturn);

% 目标指数的收益率序列
indexClose = getfield(getfield(index_info,paramSet.Beta.indexName),'close');
indexReturn = [nan,tick2ret(indexClose')'];

% 初始化                         
beta = nan(stockNum,dayNum);                           
alpha = nan(stockNum,dayNum);                                
volResidual = nan(stockNum,dayNum);                   

% 计算因子值
for iDay = max(timeWindow+1,paramSet.updateTBegin):1:dayNum 
    
    % 获取窗口期内的个股收益率、指数收益率、权重向量
    rStockWin = stockReturn(:,iDay-timeWindow+1:1:iDay);
    rIndexWin = indexReturn(iDay-timeWindow+1:1:iDay);
    weight = repmat(dampling, stockNum, 1);
    
    % 将因变量中的空值设为零，并调整权重向量
    nanIndex = isnan(rIndexWin);
    rIndexWin(nanIndex) = 0;
    weight(:,nanIndex) = 0;
    
    % 将因变量中的空值设为零，并调整权重向量
    nanIndex = isnan(rStockWin);
    rStockWin(nanIndex) = 0;
    weight(nanIndex) = 0;

    % 计算WLS回归解析解
    sumWeight = sum(weight,2);                  
    weightVarY = rStockWin .* weight;  
    sumWeightVarY = sum(weightVarY,2);                   
    sumWeightVarX = weight * rIndexWin';
    meanVarX = sumWeightVarX ./ sumWeight;       
    temp1 = weightVarY*rIndexWin' - sumWeightVarY.*meanVarX;
    temp2 = weight*rIndexWin.^2'-sumWeightVarX.^2./sumWeight;   
    beta(:,iDay) = temp1 ./ temp2;
    alpha(:,iDay) = sumWeightVarY./sumWeight - beta(:,iDay).*meanVarX;
    
    % 计算残差波动率，后续波动率因子计算中需要用到
    betaResidual = rStockWin-beta(:,iDay)*rIndexWin-repmat(alpha(:,iDay),[1,timeWindow]);
    volResidual(:,iDay) = std(betaResidual,dampling,2,'omitnan'); 
    
end

% 加权合成因子暴露
expo = paramSet.Beta.BETA.weight * beta;

fprintf('  耗时：%.4f秒\n',toc);

end



