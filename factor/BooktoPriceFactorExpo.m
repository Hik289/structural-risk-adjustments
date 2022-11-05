% -------------------------------------------------------------------------
% 因子暴露计算：账面市值比因子
% -------------------------------------------------------------------------
% [输入]
% paramSet：      全局参数集合
% daily_info：    本地日频数据
% quarterly_info：本地季频信息
% useQuarterLoc： 每天能看到的最新财报索引（stockNum * dayNum) 
% [输出]
% expo：          账面市值比因子暴露（stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = BooktoPriceFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc)

fprintf('账面市值比因子(BooktoPrice)暴露度计算');tic;

% 计算市值
switch paramSet.BktoPrc.mrkCapType
    case 'total'
        MC = daily_info.close .* daily_info.total_shares;     
    case 'float'
        MC = daily_info.close .* daily_info.float_a_shares;  
end

% 获取季报索引
quarterLoc = getfield(useQuarterLoc,paramSet.BktoPrc.rptFreq);

% 获取每天账面价值
CE = nan(size(MC));                                             
for iStock = 1:size(CE,1)
    % 每天能看到的财报索引
	qLoc = quarterLoc(iStock,:);
    % 填充日频信息
    CE(iStock,~isnan(qLoc)) = quarterly_info.tot_equity(iStock,qLoc(~isnan(qLoc)));
end

% 计算账面市值比BTOP
BTOP = CE./MC;                                                   

% 加权合成因子暴露
expo = paramSet.BktoPrc.BTOP.weight * BTOP;

fprintf('  耗时：%.4f秒\n',toc);

end
