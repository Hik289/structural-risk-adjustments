% -------------------------------------------------------------------------
% 因子暴露计算：非线性规模因子
% -------------------------------------------------------------------------
% [输入]
% paramSet：        全局参数集合
% daily_info：      本地日频数据
% sizeFactorExpo:   规模因子暴露矩阵（stockNum * dayNum）
% indusFactorExpo： 行业因子暴露矩阵（stockNum * dayNum）
% validStockMatrix：个股有效状态标记（stockNum * dayNum）
% [输出]
% expo：       非线性规模因子暴露（stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = NonLinearFactorExpo(paramSet,daily_info,sizeFactorExpo,indusFactorExpo,validStockMatrix)

fprintf('非线性规模因子(NonLinear)暴露度计算');tic;

% 计算流通市值
floatCap = daily_info.close .* daily_info.float_a_shares;

% 过大的市值进行修正
threshold = prctile(floatCap,paramSet.global.mktBlockRatio);
floatCap = min(floatCap,repmat(threshold,size(floatCap,1),1));  

% 计算标准化的市值因子暴露
standSizeFactorExpo = Standardize(paramSet,sizeFactorExpo,floatCap,indusFactorExpo,validStockMatrix);

% 将规模因子的三次方对规模因子正交，取残差作为非线性规模因子
targetFactor = power(standSizeFactorExpo,3);
baseFactor = standSizeFactorExpo;
NLSIZE = Orthogonalize(targetFactor,baseFactor,floatCap,validStockMatrix);
    
% 加权合成因子暴露
expo = paramSet.NonLinear.NLSIZE.weight * NLSIZE;

fprintf('  耗时：%.4f秒\n',toc);

end