% -------------------------------------------------------------------------
% 因子暴露计算：盈利因子
% -------------------------------------------------------------------------
% [输入]
% paramSet：      全局参数集合
% daily_info：    本地日频数据
% quarterly_info：本地季频信息
% useQuarterLoc： 每天能看到的最新财报索引（stockNum * dayNum) 
% [输出]
% expo：          盈利因子暴露（stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = EarningYieldFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc)

fprintf('盈利因子(EarningYield)暴露度计算');tic;

% 计算市值
switch paramSet.EarningYield.mrkCapType
    case 'total'
        MC = daily_info.close .* daily_info.total_shares;            
    case 'float'
        MC = daily_info.close .* daily_info.float_a_shares;          
end

% 获取季报索引
quarterLoc = getfield(useQuarterLoc,paramSet.EarningYield.rptFreq);

% -------------------------------------------------------------------------
% 细类因子1：过去12个月的市盈率(ETOP)
% -------------------------------------------------------------------------
% 获取归母净利润TTM值
NPP = transformTTM(quarterly_info.np_belongto_parcomsh); 

% 按照财报发布日期，将季频数据扩充至日频
E = nan(size(MC));
for iStock = 1:size(MC,1)
    % 每天能看到的财报索引
	qLoc = quarterLoc(iStock,:);
    % 填充日频信息
    E(iStock,~isnan(qLoc)) = NPP(iStock,qLoc(~isnan(qLoc)));              
end

% 计算ETOP
ETOP = E./MC;

% -------------------------------------------------------------------------
% 细类因子2：过去12个月的经营性净现金流与市值的比值(CETOP)
% -------------------------------------------------------------------------
% 获取经营性净现金流TTM值
NCF = transformTTM(quarterly_info.net_cash_flows_oper_act); 

% 按照财报发布日期，将季频数据扩充至日频
CE = nan(size(MC));
for iStock = 1:size(MC,1)
    % 每天能看到的财报索引
	qLoc = quarterLoc(iStock,:);
    % 填充日频信息
    CE(iStock,~isnan(qLoc)) = NCF(iStock,qLoc(~isnan(qLoc)));              
end

% 计算CETOP
CETOP = CE./MC;

% 加权合成因子暴露（注意Barra原版中还需要计算EPFWD因子，这里省去了）
weightCETOP = paramSet.EarningYield.CETOP.weight;
weightETOP = paramSet.EarningYield.ETOP.weight;
expo = (weightCETOP*CETOP+weightETOP*ETOP) / (weightCETOP+weightETOP);

fprintf('  耗时：%.4f秒\n',toc);

end

% -------------------------------------------------------------------------
% 工具函数：将原始财报公布数据（口径为累计值）转换为TTM值
% 转换公式：本期ttm = 本期报告 + 最近一次（不算本期）年报 - 上一年同期报告
% -------------------------------------------------------------------------
function ttmData = transformTTM(data)

% 去年同期报告
quarterYearBeforeData = [nan(size(data,1),4) data(:,1:end-4)];

% 去年年报（注意本地数据库第一个季报是1997年年报）
lastYearData = data;
lastYearData(:,2:4:end) = data(:,1:4:end-1);
lastYearData(:,3:4:end) = data(:,1:4:end-2);
lastYearData(:,4:4:end) = data(:,1:4:end-3);
lastYearData(:,5:4:end) = data(:,1:4:end-4);

% 计算TTM值
ttmData = data + lastYearData - quarterYearBeforeData;

% 缺失值填充为前一刻值
ttmData = fillmissing(ttmData,'prev',2);                               

end













