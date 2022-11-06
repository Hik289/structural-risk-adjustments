% -------------------------------------------------------------------------
% 因子暴露计算：动量因子
% -------------------------------------------------------------------------
% [输入]
% paramSet：   全局参数集合
% daily_info： 本地日频数据
% [输出]
% expo：       动量因子暴露（stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = MomentumFactorExpo(paramSet,daily_info)

fprintf('动量因子(Momentum)暴露度计算');tic;

% 时间窗口
timeWindow = paramSet.Mmnt.timeWindow;             

% 动量计算中需要剔除最近一段区间
lag = paramSet.Mmnt.lag;  

% 半衰期长度
halfLifeDays = paramSet.Mmnt.halfLife;   

% 个股对数收益率序列
stockReturn = tick2ret(daily_info.close_adj')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];
stockLogReturn = log(stockReturn+1);
stockLogReturnIsNaN = isnan(stockLogReturn);
stockLogReturn(stockLogReturnIsNaN) = 0;

% 半衰期加权矩阵         
weightMatrix = CalcMovingWeightMatrix(stockLogReturn,timeWindow,halfLifeDays);

% 计算加权动量因子计算结果
RSTR = nan(size(stockLogReturn));
RSTR(:,timeWindow+lag:end) = stockLogReturn * weightMatrix(:,1:end-lag);

% 需要把无效位置置为nan（否则0值可能会被当成有效的因子暴露）
RSTRIsNaN = [true(size(stockReturn,1),timeWindow+lag-1),...
            (stockLogReturnIsNaN*weightMatrix(:,1:end-lag))>0];
RSTR(RSTRIsNaN) = nan;                                    

% 加权合成因子暴露
expo = paramSet.Mmnt.RSTR.weight * RSTR;

fprintf('  耗时：%.4f秒\n',toc);

end


