% -------------------------------------------------------------------------
% 风格因子暴露正交化、标准化
% -------------------------------------------------------------------------
% [输入]
% paramSet：        全局参数集合
% daily_info：      本地日频数据
% styleExpo:        风格因子暴露集合
% indusExpo：       行业因子暴露矩阵（stockNum * dayNum）
% validStockMatrix：个股有效状态标记（stockNum * dayNum）
% [输出]
% processedExpo：   正交化、标准化后的因子暴露结构体
% -------------------------------------------------------------------------
function processedExpo = FactorProcess(paramSet,daily_info,styleExpo,indusExpo,validStockMatrix)

fprintf('因子暴露正交化、标准化');tic;

% 更新起始位置索引
startLoc = paramSet.updateTBegin;

% 计算流通市值
floatCap = daily_info.close(:,startLoc:end) .* daily_info.float_a_shares(:,startLoc:end);

% 过大的市值进行修正
threshold = prctile(floatCap, paramSet.global.mktBlockRatio);
floatCap = min(floatCap,repmat(threshold,size(floatCap,1),1));  

% 将输入数据按照更新起始点截断
styleExpo = structfun(@(x) x(:,startLoc:end),styleExpo,'UniformOutput',false);
indusExpo = indusExpo(:,startLoc:end);
validStockMatrix = validStockMatrix(:,startLoc:end);

% 因子标准化处理
styleExpo.size = Standardize(paramSet,styleExpo.size,floatCap,indusExpo,validStockMatrix);
styleExpo.beta = Standardize(paramSet,styleExpo.beta,floatCap,indusExpo,validStockMatrix);
styleExpo.momentum = Standardize(paramSet,styleExpo.momentum,floatCap,indusExpo,validStockMatrix);
styleExpo.nonLinear = Standardize(paramSet,styleExpo.nonLinear,floatCap,indusExpo,validStockMatrix);
styleExpo.booktoPrice = Standardize(paramSet,styleExpo.booktoPrice,floatCap,indusExpo,validStockMatrix);
styleExpo.earningYield = Standardize(paramSet,styleExpo.earningYield,floatCap,indusExpo,validStockMatrix);
styleExpo.growth = Standardize(paramSet,styleExpo.growth,floatCap,indusExpo,validStockMatrix);
styleExpo.leverage = Standardize(paramSet,styleExpo.leverage,floatCap,indusExpo,validStockMatrix);

% 波动率因子对规模和Beta因子正交化，然后进行标准化
baseFactor(:,:,1) = styleExpo.size;
baseFactor(:,:,2) = styleExpo.beta;
styleExpo.residVola = Orthogonalize(styleExpo.residVola,baseFactor,floatCap,validStockMatrix);
styleExpo.residVola = Standardize(paramSet,styleExpo.residVola,floatCap,indusExpo,validStockMatrix);

% 流动性因子对规模因子正交化，然后标准化
baseFactor = styleExpo.size;
styleExpo.liquidity = Orthogonalize(styleExpo.liquidity,baseFactor,floatCap,validStockMatrix);
styleExpo.liquidity = Standardize(paramSet,styleExpo.liquidity,floatCap,indusExpo,validStockMatrix);

% 返回最终结果
processedExpo = styleExpo;

fprintf('  耗时：%.4f秒\n',toc);


end