% -------------------------------------------------------------------------
% 因子暴露计算：杠杆因子
% -------------------------------------------------------------------------
% [输入]
% paramSet：      全局参数集合
% daily_info：    本地日频数据
% quarterly_info：本地季频信息
% useQuarterLoc： 每天能看到的最新财报索引（stockNum * dayNum) 
% [输出]
% expo：          杠杆因子暴露（stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = LeverageFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc)

fprintf('杠杆因子(Leverage)暴露度计算');tic;

% 总市值
MC = daily_info.close .* daily_info.total_shares;   

% 获取季报索引
quarterLoc = getfield(useQuarterLoc,paramSet.Leverage.rptFreq);

% 获取日频财务数据
LD = nan(size(MC));           % 长期负债
TD = nan(size(MC));           % 总负债
TA = nan(size(MC));           % 总资产
BE = nan(size(MC));           % 总权益
for iStock=1:size(MC,1)
    % 每天能看到的财报索引
	qLoc = quarterLoc(iStock,:);
    % 数据填充
    LD(iStock,~isnan(qLoc)) = quarterly_info.tot_non_cur_liab(iStock,qLoc(~isnan(qLoc)));
    TD(iStock,~isnan(qLoc)) = quarterly_info.tot_liab(iStock,qLoc(~isnan(qLoc)));
    TA(iStock,~isnan(qLoc)) = quarterly_info.tot_assets(iStock,qLoc(~isnan(qLoc)));
    BE(iStock,~isnan(qLoc)) = quarterly_info.tot_equity(iStock,qLoc(~isnan(qLoc)));   
end

% 计算MLEV
MLEV = 1 + LD./MC;

% 计算DTOA
DTOA = TD./TA;

% 计算BLEV 
BLEV = 1 + LD./BE;

% 加权合成因子暴露
weightMLEV = paramSet.Leverage.MLEV.weight;     
weightDTOA = paramSet.Leverage.DTOA.weight;    
weightBLEV = paramSet.Leverage.BLEV.weight;     
expo = weightMLEV*MLEV + weightDTOA*DTOA + weightBLEV*BLEV;

fprintf('  耗时：%.4f秒\n',toc);

end
