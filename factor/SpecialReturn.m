% -------------------------------------------------------------------------
% 计算残差收益率
% -------------------------------------------------------------------------
% [输入]
% paramSet：        全局参数集合
% daily_info：      本地日频数据
% factorExpo:       因子暴露矩阵（stockNum * factorNum * dayNum）
% factorReturn：    因子收益率矩阵（factorNum * dayNum）
% [输出]
% specialReturn：   残差收益率计算结果（stockrNum * dayNum）
% -------------------------------------------------------------------------
function specialReturn = SpecialReturn(paramSet,daily_info,factorExpo,factorReturn)

fprintf('特质收益率计算');tic;

% 个股的收益率序列
stockReturn = tick2ret(daily_info.close_adj')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];
stockReturn = stockReturn(:,paramSet.updateTBegin:end);
[stockNum,dayNum] = size(stockReturn); 

% 初始化结果
specialReturn = nan(stockNum,dayNum);   

% 特异性收益率计算
for iDay = 2:dayNum
    % 因子暴露(stockNum * factorNum)
    panelExpo = factorExpo(:,:,iDay-1);
    % 因子收益率（factorNum * 1）
    panelFactorReturn = factorReturn(:,iDay);
    panelFactorReturn(isnan(panelFactorReturn)) = 0;
    % 计算残差收益率
    specialReturn(:,iDay) = stockReturn(:,iDay) - panelExpo * panelFactorReturn;
end

fprintf('  耗时：%.4f秒\n',toc);

end