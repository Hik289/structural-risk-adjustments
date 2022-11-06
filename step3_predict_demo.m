% -------------------------------------------------------------------------
% ����Ԥ��ʵ����Ԥ����ָ���Ĳ����ʣ�������ʵֵ�Ƚ�
% -------------------------------------------------------------------------
clear; clc; close all;
addpath('utils');     % ��Ź�������
dbstop if error       % �������г���ʱͣ���ڳ���λ��

% -------------------------------------------------------------------------
% ���ò���
% -------------------------------------------------------------------------
% ������ʼ�·�
beginMonth = 100;

% �Ƿ�ʹ�ò����ʵ������Э������ƣ�1=�ǣ�0=��
useVolAdj = 0;                                           

% ��ָѡ�񣺻���300(HS300)����֤500(ZZ500)����֤800(ZZ800)����֤ȫָ(ZZQZ)
targetIndex = 'ZZ500';

% -------------------------------------------------------------------------
% ����Ԥ�Ⲩ��������ʵ������
% -------------------------------------------------------------------------
% ��ȡ��Ʊ������Ϣ����Ƶ��Ϣ����Ƶ��Ϣ
load('data/stock_data','basic_info','daily_info','monthly_info');

% ��ȡĿ��ָ����Ϣ
load('data/index_data.mat')
indexInfo = getfield(index_data,targetIndex);
indexClose = indexInfo.close;                    
stockList = indexInfo.stock_list;                           
stockWeight = indexInfo.stock_weight;                 
[indexStockNum,monthNum] = size(stockList);

% ��ȡЭ������ƽ��
load('result/factorExpo.mat');
if useVolAdj
    factorCov = importdata('result/factorCovVolRegAdj.mat');
    specialCov = importdata('result/specialCovVolRegAdj.mat');
else
    factorCov = importdata('result/factorCovEigenAdj.mat');
    specialCov = importdata('result/specialCovBiasAdj.mat');
end

% �����Ʊ�������ʣ�stockNum * dayNum��
stockReturn = tick2ret(daily_info.close_adj')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];

% ��ȡ��Ƶ���ݺ����daily_info
dates = daily_info.dates;
clear daily_info

% �������Ʊ��ָ���е�Ȩ�أ���ӳ�䵽ȫ��Ʊ������
fullStockCode = basic_info.stock_code; 
fullStockWeight = zeros(length(fullStockCode),monthNum);                   
for iMonth = 1:monthNum
    if sum(stockWeight(:,iMonth))==0
        continue;
    end
    goodLine = (stockWeight(:,iMonth)~=0);
    validStock = nan(indexStockNum,1);  
    [~,validStock(goodLine)] = ismember(stockList(goodLine,iMonth),fullStockCode);
    validStock(validStock==0) = nan; % �쳣���ݣ���ĳЩ��Ʊ����ĳһ��ָ�����ǲ���3000+�Ĺ�Ʊ����
    fullStockWeight(validStock(~isnan(validStock)),iMonth)=...
            stockWeight(~isnan(validStock),iMonth)/sum(stockWeight(:,iMonth));   
end

% ��ȡ������Ƶ��������Ƶ���������е�λ������
[~,month2day] = ismember(monthly_info.dates,dates);

% ��ʼ��Ԥ�Ⲩ��������ʵ������
forecastVolatility = nan(1,monthNum);
realVolatility = nan(1,monthNum);
returnser = nan(1,monthNum);

% ÿ��Ԥ�ڷ��ա�ʵ�ʲ�������
for iMonth = beginMonth:(monthNum-1)
    
    fprintf('��ǰ�����·ݣ�%d\n',iMonth);
    
    % ��ȡ��ǰ��ĩ��������
    thisMonthEnd = month2day(1,iMonth);
    
    % ��ȡ�¸����³�����ĩ��������
    nextMonthBigen = thisMonthEnd + 1;
    nextMonthEnd = month2day(1,iMonth+1);
    
    % ���ձ�¶����
    X = factorExpo(:,:,thisMonthEnd);
    
    % �в�Э���������Э�������
    F = factorCov(:,:,thisMonthEnd);
    Delta = specialCov(:,thisMonthEnd).^2;   
    Delta = diag(Delta);
    
    % �޳�������ҵ��Ӱ�죨�󲿷�ʱ��Ϊ��ֵ��
    F(40,:) = []; F(:,40) = []; X(:,40)=[];
    
    % ��ȡ��Чֵ
    tempReturn = stockReturn(:,nextMonthBigen:nextMonthEnd);
    goodStock = ((~isnan(sum(X,2)))&(~isnan(sum(Delta,2)))&(~isnan(sum(tempReturn,2))));
    badStock = ~goodStock;
    X(isnan(X)) = 0;
    Delta(isnan(Delta)) = 0;
    tempReturn(isnan(tempReturn)) = 0;
    W = fullStockWeight(:,iMonth);
    filterW = diag(goodStock)*W;
    
    % Ԥ�Ⲩ����
    V = X*F*X' + Delta;
    Risk = filterW' * V * filterW;                                    
    forecastVolatility(iMonth) = sqrt(Risk);
    
    % ��ʵ������
    tempStockWeight = (goodStock.*fullStockWeight(:,iMonth))';
    returnDay = tempStockWeight*tempReturn/sum(tempStockWeight,2);
    returnDay(isnan(returnDay)) = 0;
    realVolatility(iMonth) = std(returnDay)*sqrt(21);

    returnser(iMonth) = mean(returnDay);
    
end

% ��ͼ
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
