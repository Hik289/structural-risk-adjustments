% -------------------------------------------------------------------------
% 风险预测实例：预测宽基指数的波动率，并与真实值比较
% -------------------------------------------------------------------------
clear; clc; close all;
addpath('utils');     % 存放公共函数
dbstop if error       % 程序运行出错时停留在出错位置

% -------------------------------------------------------------------------
% 设置参数
% -------------------------------------------------------------------------
% 设置起始月份
beginMonth = 100;

% 是否使用波动率调整后的协方差估计（1=是，0=否）
useVolAdj = 0;                                           

% 股指选择：沪深300(HS300)、中证500(ZZ500)、中证800(ZZ800)、中证全指(ZZQZ)
targetIndex = 'ZZ500';

% -------------------------------------------------------------------------
% 计算预测波动率与真实波动率
% -------------------------------------------------------------------------
% 获取股票基本信息、日频信息、月频信息
load('data/stock_data','basic_info','daily_info','monthly_info');

% 获取目标指数信息
load('data/index_data.mat')
indexInfo = getfield(index_data,targetIndex);
indexClose = indexInfo.close;                    
stockList = indexInfo.stock_list;                           
stockWeight = indexInfo.stock_weight;                 
[indexStockNum,monthNum] = size(stockList);

% 获取协方差估计结果
load('result/factorExpo.mat');
if useVolAdj
    factorCov = importdata('result/factorCovVolRegAdj.mat');
    specialCov = importdata('result/specialCovVolRegAdj.mat');
else
    factorCov = importdata('result/factorCovEigenAdj.mat');
    specialCov = importdata('result/specialCovBiasAdj.mat');
end

% 计算股票日收益率（stockNum * dayNum）
stockReturn = tick2ret(daily_info.close_adj')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];

% 获取日频数据后清除daily_info
dates = daily_info.dates;
clear daily_info

% 计算各股票在指数中的权重，并映射到全股票矩阵中
fullStockCode = basic_info.stock_code; 
fullStockWeight = zeros(length(fullStockCode),monthNum);                   
for iMonth = 1:monthNum
    if sum(stockWeight(:,iMonth))==0
        continue;
    end
    goodLine = (stockWeight(:,iMonth)~=0);
    validStock = nan(indexStockNum,1);  
    [~,validStock(goodLine)] = ismember(stockList(goodLine,iMonth),fullStockCode);
    validStock(validStock==0) = nan; % 异常数据，有某些股票属于某一股指，但是不在3000+的股票池中
    fullStockWeight(validStock(~isnan(validStock)),iMonth)=...
            stockWeight(~isnan(validStock),iMonth)/sum(stockWeight(:,iMonth));   
end

% 获取所有月频日期在日频日期序列中的位置索引
[~,month2day] = ismember(monthly_info.dates,dates);

% 初始化预测波动率与真实波动率
forecastVolatility = nan(1,monthNum);
realVolatility = nan(1,monthNum);
returnser = nan(1,monthNum);

% 每期预期风险、实际波动计算
for iMonth = beginMonth:(monthNum-1)
    
    fprintf('当前处理月份：%d\n',iMonth);
    
    % 获取当前月末日期索引
    thisMonthEnd = month2day(1,iMonth);
    
    % 获取下个月月初及月末日期索引
    nextMonthBigen = thisMonthEnd + 1;
    nextMonthEnd = month2day(1,iMonth+1);
    
    % 风险暴露矩阵
    X = factorExpo(:,:,thisMonthEnd);
    
    % 残差协方差和因子协方差估计
    F = factorCov(:,:,thisMonthEnd);
    Delta = specialCov(:,thisMonthEnd).^2;   
    Delta = diag(Delta);
    
    % 剔除新增行业的影响（大部分时间为空值）
    F(40,:) = []; F(:,40) = []; X(:,40)=[];
    
    % 提取有效值
    tempReturn = stockReturn(:,nextMonthBigen:nextMonthEnd);
    goodStock = ((~isnan(sum(X,2)))&(~isnan(sum(Delta,2)))&(~isnan(sum(tempReturn,2))));
    badStock = ~goodStock;
    X(isnan(X)) = 0;
    Delta(isnan(Delta)) = 0;
    tempReturn(isnan(tempReturn)) = 0;
    W = fullStockWeight(:,iMonth);
    filterW = diag(goodStock)*W;
    
    % 预测波动率
    V = X*F*X' + Delta;
    Risk = filterW' * V * filterW;                                    
    forecastVolatility(iMonth) = sqrt(Risk);
    
    % 真实波动率
    tempStockWeight = (goodStock.*fullStockWeight(:,iMonth))';
    returnDay = tempStockWeight*tempReturn/sum(tempStockWeight,2);
    returnDay(isnan(returnDay)) = 0;
    realVolatility(iMonth) = std(returnDay)*sqrt(21);

    returnser(iMonth) = mean(returnDay);
    
end

% 作图
figure;
hold on
h1 = plot(forecastVolatility(beginMonth:end),'r');
h2 = plot(realVolatility(beginMonth:end),'g');
h3 = plot(cumsum(returnser(beginMonth:end)),'b');
dateStr = cellstr(datestr(monthly_info.dates(1,beginMonth+1:end),'yyyy-mm'));
set(gca,'xtick',1:12:monthNum-beginMonth,'xTickLabel',dateStr(1:12:end),'xTickLabelRotation',50);
set(gcf,'color','w'); 
legend([h1,h2,h3],{'forecastVolatility','realVolatility','returnDay'});
ylabel('Risk');
title(targetIndex);
