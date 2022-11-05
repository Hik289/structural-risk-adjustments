%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 函数功能：将因子暴露缺失值填补为行业均值，当行业有效值不足或计算结果为NAN时，直接置0
% --------------------------------
% 输入：
%    - factorExplr：因子暴露数据（stockNum * dayNum)
%    - industryFactorExpr：股票所属行业矩阵，1-29 （stockNum * dayNum）
%    - stockFilter：可交易股票的标记矩阵 （stockNum * dayNum）
%    - paramFile：参数文件名称，即'param.mat'
% 输出：
%    - newFactorExplr：缺失值处理后的因子暴露数据（stockNum * dayNum)
% -------------------------------
% 代码版本：曲平
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newFactorExplr] = functionGetMeanExplr(paramSet,factorExplr,industryFactorExpr,stockFilter)
    % 参数准备
%     load(paramFile);
%     threshold=paraThresholdDataTooFew;                                      % 【来自paraFile】有效数据量的下限。低于该值时，nan直接修正为0
%     indusNum=paraIndustryNum;                                                % 【来自paraFile】行业数目
    [stockNum,dayNum]=size(factorExplr);                                    % 确定：行 - 股票数、列 - 天数
    
    threshold = paramSet.global.thDataTooFew;
    indusNum = 30;

    factorExplr=factorExplr.*stockFilter;                                   % 提出暴露度计算中的无效股票
    
    newFactorExplr=factorExplr;                                             % 初始化 newFactorExplr
    tempFactorExplr=nan(stockNum,dayNum);                                   % 初始化 tempFactorExplr
    
    % 循环计算每个截面、每个行业的暴露度均值
    for iterD=1:dayNum                              % 天数 循环
        for iterIndst=1:indusNum                    % 行业 循环
            stockIterIndst=(industryFactorExpr(:,iterD)==iterIndst);                  % 确定编号iterIndst的行业是哪些行
            stockNumIndst=sum(stockIterIndst);                              % 计算行业中有多少只股票
            tempMean=mean(factorExplr(stockIterIndst,iterD),'omitnan');     % 计算行业均值
            validDataNum=sum(~isnan(factorExplr(stockIterIndst,iterD)));    % 计算用于计算均值的有效数据量(validDataNum)
            MEASURE = ( validDataNum > threshold );                         % 【判断参数】确定是否将数据设置为行业均值
            if  MEASURE                                                     % 确定validDataNum数目是否足够
                tempFactorExplr(stockIterIndst,iterD)=tempMean*ones(stockNumIndst,1);
            else
                tempFactorExplr(stockIterIndst,iterD)=zeros(stockNumIndst,1);
            end
        end
    end
    
    % 对暴露度中的NAN进行赋值
    badFactor=isnan(factorExplr);
    newFactorExplr(badFactor)=tempFactorExplr(badFactor);
    newFactorExplr=newFactorExplr.*stockFilter;
end