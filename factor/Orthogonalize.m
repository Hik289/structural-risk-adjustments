% -------------------------------------------------------------------------
% 函数功能：将目标因子对基准因子（1个或多个）按流通市值加权正交化
% 算法基本假设：
% targetFactor[] = resultFactor[]+beta*baseFactor[]+error
% 其中resultFactor就是正交后的因子暴露，与baseFactor完全正交，互不相关
% -------------------------------------------------------------------------
% [输入]
% targetFactor ：   待正交因子的因子暴露（stockNum * dayNum)
% baseFactor：      正交基因子的因子暴露集合（stockNum * dayNum * factorNum)
% weight：          加权最小二乘权重（stockNum * dayNum)
% validStockMatrix：可交易股票的标记矩阵 （stockNum * dayNum）
% [输出]
% resultFactor：    正交余量，作为新的因子暴露值（stockNum * dayNum)
% -------------------------------------------------------------------------
function resultFactor = Orthogonalize(targetFactor,baseFactor,weight,validStockMatrix)
    
% 获取有效因子暴露
targetFactor = targetFactor .* validStockMatrix;

% 获取股票维度与日期维度
[stockNum,dayNum] = size(targetFactor);

% 初始化结果
resultFactor = nan(size(targetFactor));

% 遍历每个截面
for iDay = 1:1:dayNum
    % 自变量、因变量、权重
    Y = targetFactor(:,iDay);
    X = squeeze(baseFactor(:,iDay,:));
    w = weight(:,iDay);
    % 保留三个值均有效的索引
    validStock = ~isnan(sum([Y,X,w],2));
    validY = Y(validStock,:);
    validX = X(validStock,:);
    validW = w(validStock,:);
    % 直接基于解析解得到回归系数估计
    tmpX = [validX,ones(size(validX,1),1)];
    tmpW = diag(validW);
    ret = (tmpX'*tmpW*tmpX)\(tmpX'*tmpW*validY);
    beta = ret(1:end-1);  alpha = ret(end);
    resultFactor(:,iDay) = Y-X*beta-ones(stockNum,1)*alpha;
end

end