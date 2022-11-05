% -------------------------------------------------------------------------
% 残差协方差：贝叶斯压缩调整（全局运行）
% -------------------------------------------------------------------------
% [输入]
% paramSet：           全局参数集合
% daily_info：         日频数据集合
% specialCovStructAdj：结构化调整后的残差协方差（stockNum * dayNum）
% [输出]
% specialCovBiasAdj：  残差协方差估计（stockNum * dayNum)
% -------------------------------------------------------------------------
function specialCovBiasAdj = SpecialCovBiasAdj(paramSet,daily_info,specialCovStructAdj)

fprintf('残差协方差矩阵贝叶斯压缩调整');tic;

% 参数准备
q = paramSet.SpecialCov.BiasAdj.q;                                                
groupNum = paramSet.SpecialCov.BiasAdj.groupNum;                                  
blockRatio = paramSet.SpecialCov.BiasAdj.blockRatio;                                       
[~,dayNum] = size(specialCovStructAdj);

% 市值处理
weightCap = daily_info.close .* daily_info.float_a_shares;
threshold = prctile(weightCap,blockRatio);
weightCap = min(weightCap,repmat(threshold,size(weightCap,1),1));  
switch paramSet.global.capSqrtFlag
    case 0
        weightCap = weightCap.^1;
    case 1
        weightCap = weightCap.^0.5;
end

% 初始化结果
specialCovBiasAdj = specialCovStructAdj;  

% 贝叶斯压缩计算
for iDay = 1:dayNum
    
    % 计算每个分组的门限值
    panelW = weightCap(:,iDay);
    thresholdV = nan(1,groupNum+1); 
    thresholdV(1) = min(panelW)-1;                        	
    thresholdV(groupNum+1) = max(panelW)+1;                   
    for groupTh = 2:groupNum
        thresholdV(groupTh) = prctile(panelW,100*(groupTh-1)/groupNum); 
    end
    
    % 对每个分组进行处理
    for iGroup = 1:groupNum
        % 选出某个分组内的有效股票
        stockIn = (panelW>thresholdV(iGroup)) &(panelW<thresholdV(iGroup+1));                
        noNanLines = ~isnan(sum([panelW,specialCovStructAdj(:,iDay)],2));
        goodLines = (stockIn & noNanLines);
        % 计算每个组合的市值加权波动率均值
        sigmaMean = sum(weightCap(goodLines,iDay).*specialCovStructAdj(goodLines,iDay))/sum(weightCap(goodLines,iDay));                         
        if isnan(sigmaMean)
            continue;
        end
        % 股票所处分组的特质波动率的标准差
        DeltaS = (nansum((specialCovStructAdj(goodLines,iDay)-sigmaMean).^2)/sum(goodLines))^0.5;   
        % 股票特质波动率和分组加权均值的偏离度
        offset = q * abs(specialCovStructAdj(stockIn,iDay)-sigmaMean);    
        % 压缩密度
        Vn = offset ./ (DeltaS+offset);                                     
        % 向分组内加权平均值压缩
        specialCovBiasAdj(stockIn,iDay) = Vn*sigmaMean+(1-Vn).*specialCovStructAdj(stockIn,iDay); 
    end
    
end
specialCovBiasAdj(specialCovBiasAdj==0) = nan;
    
fprintf('  耗时：%.4f秒\n',toc);

end