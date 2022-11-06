% -------------------------------------------------------------------------
% 因子暴露计算：规模因子（Size）
% 由于规模因子计算速度较快，所以每次都是全局重新计算一次
% -------------------------------------------------------------------------
% [输入]
% paramSet：  全局参数集合
% daily_info：本地日频数据
% [输出]
% expo：      Size因子暴露（stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = SizeFactorExpo(paramSet,daily_info)

fprintf('规模因子(Size)暴露度计算');tic;

% 股票原始收盘价（不复权）
closePrice = daily_info.close;        

% 计算股票市值（支持总市值和流通市值两个口径）
switch paramSet.Size.mrkCapType
    case 'total'
        TMC = closePrice .* daily_info.total_shares;  
    case 'float'
        TMC = closePrice .* daily_info.float_a_shares;  
end

% 计算LNCAP因子
TMC(TMC<1)=nan;                     
LNCAP=log(TMC);                       

% 加权合成因子暴露
expo = paramSet.Size.LNCAP.weight * LNCAP;

fprintf('  耗时：%.4f秒\n',toc);

end