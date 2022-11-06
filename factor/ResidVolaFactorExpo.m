% -------------------------------------------------------------------------
% 因子暴露计算：波动率因子
% -------------------------------------------------------------------------
% [输入]
% paramSet：   全局参数集合
% daily_info： 本地日频数据
% volResidual: Beta因子计算中得到的个股残差波动率
% [输出]
% expo：       波动率量因子暴露（stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = ResidVolaFactorExpo(paramSet,daily_info,volResidual)

fprintf('波动率因子(ResidVola)暴露度计算');tic;

% 个股收益率序列
stockClose = daily_info.close_adj;
stockReturn = tick2ret(stockClose')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];
[stockNum,dayNum] = size(stockReturn);

% -------------------------------------------------------------------------
% 波动率因子1：DASTD（历史波动率，采用加权计算方式）
% -------------------------------------------------------------------------
% 参数设置
timeWinDASTD = paramSet.ResidVola.DASTD.timeWindow; 
halfLifeDASTD = paramSet.ResidVola.DASTD.halfLife; 
nanOpt = paramSet.ResidVola.nanOpt;

% 计算权重向量
damplingDASTD = power(1/2,(timeWinDASTD:-1:1)/halfLifeDASTD); 
damplingDASTD = damplingDASTD/sum(damplingDASTD,nanOpt);      
                   
% 初始化
DASTD = nan(stockNum,dayNum);                            

% 遍历每个截面
for iDay = max(timeWinDASTD+1,paramSet.updateTBegin):1:dayNum         
    % 个股区间收益率
	returnList = stockReturn(:,(iDay-timeWinDASTD+1):iDay); 
    % 加权波动率
	DASTD(:,iDay) = std(returnList,damplingDASTD,2,nanOpt); 
end

% -------------------------------------------------------------------------
% 波动率因子2：CMAR（历史收益率的波动幅度）
% -------------------------------------------------------------------------
% 参数设置
monthNumCMAR = paramSet.ResidVola.CMRA.timeWindow;                  
dayNumOfMonth = paramSet.ResidVola.CMRA.dayNumOfMonth;                
negaOpt = paramSet.ResidVola.negaOpt;     

% 计算窗长
timeWinCMRA = monthNumCMAR * dayNumOfMonth;                         

% 初始化
CMRA = nan(stockNum,dayNum);                                 

% 计算CMRA
for iDay = max(timeWinCMRA+1,paramSet.updateTBegin):dayNum  
    % 获取窗口期内的月频下标索引
	mIndex = (iDay-timeWinCMRA):dayNumOfMonth:iDay; 
    %  1-T月的对数收益累积
	returnCumMonth = log(stockClose(:,mIndex(2:end))./stockClose(:,mIndex(1)));  
    % 累积月收益率 Z(T)<=-1 的负值调整
	returnCumMonth(returnCumMonth<=-1) = negaOpt;    
    % 计算累计收益率的波动幅度
	CMRA(:,iDay) = log(1+max(returnCumMonth,[],2))-log(1+min(returnCumMonth,[],2)); 
end

% -------------------------------------------------------------------------
% 波动率因子3：HSIGMA（Beta因子计算中线性回归残差项的标准差）
% -------------------------------------------------------------------------
% HSIGMA
HSIGMA = volResidual;

% 加权合成因子暴露
weightDASTD = paramSet.ResidVola.DASTD.weight;                                 
weightCMRA = paramSet.ResidVola.CMRA.weight;                                  
weightHSIGMA = paramSet.ResidVola.HSIGMA.weight;       
expo = weightDASTD*DASTD + weightCMRA*CMRA + weightHSIGMA*HSIGMA;   

fprintf('  耗时：%.4f秒\n',toc);

end

