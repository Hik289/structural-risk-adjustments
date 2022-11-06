% -------------------------------------------------------------------------
% 1、计算因子收益率
% 2、将风格因子、行业因子、国家因子暴露汇总
% -------------------------------------------------------------------------
% [输入]
% paramSet：        全局参数集合
% daily_info：      本地日频数据
% styleExpo:        风格因子暴露集合
% indusExpo：       行业因子暴露矩阵（stockNum * dayNum）
% validStockMatrix：个股有效状态标记（stockNum * dayNum）
% [输出]
% factorReturn：    因子收益率计算结果（factorNum * dayNum）
% factorExpo：      因子暴露汇总结果（stockNum * factorNum * dayNum）
% -------------------------------------------------------------------------
function [factorReturn,factorExpo] = FactorReturn(paramSet,daily_info,styleExpo,indusExpo,validStockMatrix)

fprintf('因子收益率计算');tic;

% 截断数据
validStockMatrix = validStockMatrix(:,paramSet.updateTBegin:end);
indusExpo = double(indusExpo(:,paramSet.updateTBegin:end));
indusExpo = indusExpo .* validStockMatrix;

% 各类因子数目
styleNum = paramSet.global.styleFactorNum;
indusNum = paramSet.global.indusFactorNum;
countryNum = paramSet.global.countryFactorNum;
factorNum = styleNum + indusNum + countryNum;                 

% 个股的收益率序列
stockReturn = tick2ret(daily_info.close_adj')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];
stockReturn = stockReturn(:,paramSet.updateTBegin:end) .* validStockMatrix;
[stockNum,dayNum] = size(stockReturn);

% 权重数据
weightCap = daily_info.close(:,paramSet.updateTBegin:end) .* daily_info.float_a_shares(:,paramSet.updateTBegin:end);
threshold = prctile(weightCap, paramSet.global.mktBlockRatio);
weightCap = min(weightCap,repmat(threshold,size(weightCap,1),1)); 
weightCap(isnan(weightCap)) = 0;                           

% 初始化结果
factorReturn = nan(factorNum,dayNum);                        
factorExpo = nan(stockNum,factorNum,dayNum);

% 遍历每个截面
for iDay = 1:dayNum
    
    % 获取截面上的风格因子暴露
    panelStyleExpo = [styleExpo.size(:,iDay),styleExpo.beta(:,iDay),...
                styleExpo.momentum(:,iDay),styleExpo.residVola(:,iDay),...
                styleExpo.nonLinear(:,iDay),styleExpo.booktoPrice(:,iDay),...
                styleExpo.liquidity(:,iDay),styleExpo.earningYield(:,iDay),...
                styleExpo.growth(:,iDay),styleExpo.leverage(:,iDay)]; 
    
    % 获取行业因子哑变量矩阵  
    panelIndusExpo = indusExpo(:,iDay);
    panelIndusExpo(isnan(panelIndusExpo)) = indusNum+1;
    panelIndusExpo = dummyvar(panelIndusExpo);
    panelIndusExpo = panelIndusExpo(:,1:indusNum);
%     % 临时方案：因为目前本地数据中行业归属都是有效数据，可能是做了人工处理
%     % 所以前期行业个数只有29个时，会导致边界读取错误，这里先做条件判断，未
%     % 来会把行业底层归属数据替换成无加工版本，理论上就不需要这个条件判断了
%     if size(panelIndusExpo,2) < indusNum
%         panelIndusExpo = [panelIndusExpo,zeros(stockNum,1)];
%     else
%         panelIndusExpo = panelIndusExpo(:,1:indusNum);
%     end
    
    % 保存因子暴露结果
    factorExpo(:,:,iDay) = [panelStyleExpo, panelIndusExpo, ones(stockNum,1)];
    
    % 最新一天的因子暴露已经无法计算收益率
    if iDay == dayNum
        continue;
    end
    
    % 获取截面股票收益率（注意是用T日因子对T+1日收益率回归）
    panelReturn = stockReturn(:,iDay+1);
    
    % 获取有完整数据的个股（风格暴露、行业暴露、股票收益率均为有效值）
    lineNoNan = ~isnan(sum([panelReturn,panelStyleExpo,panelIndusExpo],2));
    if sum(lineNoNan)==0
        continue;                                                       
    end
    
    % 获取有效的回归自变量、因变量、权重
    Y = panelReturn(lineNoNan);
    X = [panelStyleExpo,panelIndusExpo]; X = X(lineNoNan,:);
    w = weightCap(lineNoNan,iDay);
    
    % 回归系数估计（注意需要剔除全零列，因为行业个数出现过变更）    
    beta = nan(size(X,2),1);
    validCol = sum(X~=0) > 0;
    X = X(:,validCol);
    beta(validCol) = (X' * diag(w) * X) \ (X' * diag(w) * Y);
       
    % 风格因子收益率直接取回归结果   
    styleReturn = beta(1:styleNum);   
    
    % 国家因子收益率是行业因子收益率的市值加权
    indusWeight = w' * panelIndusExpo(lineNoNan,:);                
    indusReturn = beta((1+styleNum):(indusNum+styleNum));        
    countryReturn = nansum( indusReturn .* indusWeight') / ...
                    nansum((~isnan(indusReturn)) .* indusWeight');     
    
    % 行业因子收益率是在原来基础上减去国家因子收益率
    indusReturn = indusReturn - countryReturn;   
    
    % 结果赋值，注意这里存储的下标是T+1日，也即基于T日因子暴露和T+1日收益率
    % 得到的回归结果是存在T+1日，这样保证没有引入未来信息
    factorReturn(:,iDay+1) = [styleReturn;indusReturn;countryReturn];   
         
end

fprintf('  耗时：%.4f秒\n',toc);

end
