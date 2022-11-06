% -------------------------------------------------------------------------
% 因子暴露计算：流动性因子
% -------------------------------------------------------------------------
% [输入]
% paramSet：      全局参数集合
% daily_info：    本地日频数据 
% [输出]
% expo：          流动性因子暴露（stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = LiquidityFactorExpo(paramSet,daily_info)

fprintf('流动性因子(Liquidity)暴露度计算');tic;

% 获取换手率数据
turn = daily_info.turn;

% 股票维度和日期维度
[stockNum,dayNum] = size(turn);       

% -------------------------------------------------------------------------
% 细类因子1：过去一个月的流动性(STOM)
% -------------------------------------------------------------------------
% 一个月包含的天数
timeWin = paramSet.Liquidity.dayNumOfMonth;

% 是否忽略缺失值
nanOpt = paramSet.Liquidity.nanOpt;

% 初始化
STOM = nan(stockNum,dayNum);    

% 计算STOM
for iDay = max(timeWin,paramSet.updateTBegin):dayNum
    % 计算区间内换手率累计值
    kernal = mean(turn(:,(iDay+1-timeWin):iDay),2,nanOpt)*timeWin;  
    % 取对数
    STOM(:,iDay) = log(kernal);                                          
end

% 修正换手率为零的场景
STOM(STOM==-inf) = nan;

% -------------------------------------------------------------------------
% 细类因子2：过去一个季度的流动性(STOQ)
% -------------------------------------------------------------------------
% 一个季度包含的月份数
monthNumSTOQ = paramSet.Liquidity.STOQ.T;    

% 对应的日频窗长
timeWinSTOQ = paramSet.Liquidity.dayNumOfMonth * monthNumSTOQ;

% 初始化
STOQ = nan(stockNum,dayNum);                         

% 计算STOQ
for iDay = max(timeWinSTOQ,paramSet.updateTBegin):dayNum
    % 计算区间内换手率累计值
    kernal = mean(turn(:,(iDay+1-timeWinSTOQ):iDay),2,nanOpt)*timeWinSTOQ; 
    % 取对数
    STOQ(:,iDay) = log(kernal/monthNumSTOQ);                                  
end

% 修正换手率为零的场景
STOQ(STOQ==-inf) = nan;

% -------------------------------------------------------------------------
% 细类因子3：过去一年的流动性(STOA)
% -------------------------------------------------------------------------
% 一年包含的月份数
monthNumSTOA = paramSet.Liquidity.STOA.T; 

% 对应的日频窗长
timeWinSTOA = paramSet.Liquidity.dayNumOfMonth * monthNumSTOA;

% 初始化
STOA = nan(stockNum,dayNum);                         

% 计算STOA
for iDay = max(timeWinSTOA,paramSet.updateTBegin):dayNum
    % 计算区间内换手率累计值
    kernal = mean(turn(:,(iDay+1-timeWinSTOA):iDay),2,nanOpt)*timeWinSTOA; 
    % 取对数
    STOA(:,iDay) = log(kernal/monthNumSTOA);                                  
end

% 修正换手率为零的场景
STOA(STOA==-inf) = nan;

% 加权合成因子暴露
expo = paramSet.Liquidity.STOM.weight*STOM + ...
       paramSet.Liquidity.STOQ.weight*STOQ +...
       paramSet.Liquidity.STOA.weight*STOA;

fprintf('  耗时：%.4f秒\n',toc);

end