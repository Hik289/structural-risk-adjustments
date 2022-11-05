% -------------------------------------------------------------------------
% 函数功能：将因子暴露数据进行中位数去极值、缺失值补行业均值、标准化处理
% -------------------------------------------------------------------------
% [输入]
% paramSet：        全局参数集合
% oldExpo：         预处理前的因子暴露数据（stockNum * dayNum)
% floatCap：        流通市值（stockNum * dayNum）
% indusFactorExpo： 行业因子暴露矩阵（stockNum * dayNum）
% validStockMatrix：个股有效状态标记（stockNum * dayNum）
% [输出]
% newExpo：         标准化后的因子暴露数据（stockNum * dayNum)
% -------------------------------------------------------------------------
function newExpo = Standardize(paramSet,oldExpo,floatCap,indusFactorExpo,validStockMatrix)

% 初始化结果
newExpo = oldExpo .* validStockMatrix;                                  
[stockNum,dayNum] = size(newExpo);                                     

% -------------------------------------------------------------------------
% 中位数去极值
% -------------------------------------------------------------------------
% Z-score去极值中的阈值(中位数的倍数)
thZscore = paramSet.global.thZscore;

% 将超出门限值的极端值设置为门限值
medianData = nanmedian(newExpo,1);
matrixMedianData = repmat(medianData,stockNum,1);
tempData = abs(newExpo-matrixMedianData);
mediaTempData = nanmedian(tempData,1);
matrixMedianTempData = repmat(mediaTempData,stockNum,1);
thresholdHMatrix = matrixMedianData + thZscore*matrixMedianTempData;
thresholdLMatrix = matrixMedianData - thZscore*matrixMedianTempData;
newExpo(newExpo>thresholdHMatrix) = thresholdHMatrix(newExpo>thresholdHMatrix); 
newExpo(newExpo<thresholdLMatrix) = thresholdLMatrix(newExpo<thresholdLMatrix); 

% -------------------------------------------------------------------------
% 填充缺失值（基于行业均值）
% -------------------------------------------------------------------------
% 基于每个截面上行业内包含的有效数据计算行业均值
indusMean = nan(stockNum,dayNum); 
for iDay = 1:dayNum                              
    for iIndus = 1:paramSet.global.indusFactorNum    
        % 获取当前截面上属于目标行业的个股集合
        includeStockIndex = (indusFactorExpo(:,iDay)==iIndus);    
        % 计算目标行业中有多少只股票
        includeStockNum = sum(includeStockIndex);      
        % 计算有效数据的均值
        tempMean = mean(newExpo(includeStockIndex,iDay),'omitnan');    
        % 计算有效数据的个数
        validDataNum = sum(~isnan(newExpo(includeStockIndex,iDay)));    
        % 只有当有效数据足够时才将缺失值填充为行业均值，否则直接填充为0
        if  validDataNum > paramSet.global.thDataTooFew                                                     % 确定validDataNum数目是否足够
            indusMean(includeStockIndex,iDay) = tempMean*ones(includeStockNum,1);
        else
            indusMean(includeStockIndex,iDay) = zeros(includeStockNum,1);
        end
    end
end

% 填充缺失值
nanIndex = isnan(newExpo);
newExpo(nanIndex) = indusMean(nanIndex);

% 再次置为无效数据（可能有些无效的股票也被填充行业均值了）
newExpo = newExpo .* validStockMatrix;

% -------------------------------------------------------------------------
% 中心化、标准化
% -------------------------------------------------------------------------
% 根据参数设置决定是否对市值进行开根号处理
switch paramSet.global.capSqrtFlag
    case 0
        floatCap = floatCap.^1;
    case 1
        floatCap = floatCap.^0.5;
end

% 将无效股票处的市值置为空值
floatCap(isnan(newExpo)) = nan;

% 计算截面因子暴露均值（市值加权）
meanExpo = nansum(newExpo.*floatCap,1) ./ nansum(floatCap,1);       

% 中心化
newExpo = newExpo - repmat(meanExpo,stockNum,1);

% 标准化
newExpo = newExpo ./ repmat(nanstd(newExpo,1),stockNum,1);
    
end