% -------------------------------------------------------------------------
% 检查因子协方差估计的效果 
% [输入]
% dates：                    全日期序列（1 * dayNum
% beginDate：                起始起始日期
% factorReturn：             因子收益率序列（factorNum * dayNum）
% factorCovNW：              NW调整因子协方差估计（factorNum * factorNum * dayNum）
% factorCovEigenAdj：        特征值调整协方差估计（factorNum * factorNum * dayNum）
% factorCovVolRegAdj：       波动率调整协方差估计（factorNum * factorNum * dayNum）
% -------------------------------------------------------------------------
function CheckFactorCov(dates,beginDate,factorReturn,factorCovNW,factorCovEigenAdj,factorCovVolRegAdj)

% 基本参数设置
dayNumOfMonth = 21;   
dayNum = length(dates);

% 初始化图表
figure()
set(gcf,'color','w'); 
set(gcf,'position',[100,100,1000,500])

% -------------------------------------------------------------------------
% 图表1：特征值调整前后的B统计量对比
% -------------------------------------------------------------------------
% 计算起始位置
tStart = find(dates>=datenum(beginDate),1,'first');

% 计算B统计量
[Bbefor,Bafter,thUp,thBottom,~,~] = CalcBStats(...
    factorCovNW,factorCovEigenAdj,factorReturn,tStart,dayNumOfMonth);

% 作图
subplot(2,2,1);
hold on;
h1 = plot(Bbefor,'*r');
h2 = plot(Bafter,'*g');
plot(ones(1,length(Bbefor)),'b');
plot(thUp,'--b');
plot(thBottom,'--b');
legend([h1,h2],{'Before','After'});
ylabel('Bias Statistic');
xlabel('Eigenfactor Number');
title('Optimization Bias Adjustment');

% -------------------------------------------------------------------------
% 图表2 & 图表3：波动率偏误调整前、后的偏误统计量12个月滚动均值对比
% -------------------------------------------------------------------------
% 计算起始位置
monthWin = 12;
tStart = find(dates>=datenum(beginDate),1,'first') - monthWin*dayNumOfMonth;

% 计算B统计量
[Bbefor,Bafter,thUp,thBottom,bTQbefor,bTQafter] = CalcBStats(...
    factorCovEigenAdj,factorCovVolRegAdj,factorReturn,tStart,dayNumOfMonth);

% 作图显示B统计量
subplot(2,2,2);
hold on;
h1 = plot(Bbefor,'*r');
h2 = plot(Bafter,'*g');
plot(ones(1,length(Bbefor)),'b');
plot(thUp,'--b');
plot(thBottom,'--b');
legend([h1,h2],{'Before','After'});
ylabel('Bias Statistic');
xlabel('Eigenfactor Number');
title('Volatility Regime Adjustment');

% 计算12个月滚动平均的小b统计量值
tSeries = tStart:dayNumOfMonth:dayNum-dayNumOfMonth+1;
BbeforSeries = nan(1,length(tSeries)-monthWin+1);
BafterSeries = nan(1,length(tSeries)-monthWin+1);
for t = 1:size(BbeforSeries,2)
    BbeforSeries(t) = mean(nanstd((bTQbefor(:,tSeries(t:t+monthWin-1))')));
    BafterSeries(t) = mean(nanstd((bTQafter(:,tSeries(t:t+monthWin-1))')));
end   

% 作图显示小b统计量滚动12月均值
subplot(2,2,3);
h1=plot(BbeforSeries,'-r');
hold on;
h2=plot(BafterSeries,'-g');
plot(ones(1,size(BbeforSeries,2)),'b');
data1 = ones(1,size(BbeforSeries,2))+sqrt(2/monthWin);
data2 = ones(1,size(BbeforSeries,2))-sqrt(2/monthWin);
plot(data1,'--b');plot(data2,'--b');
legend([h1,h2],{'Before','After'});
xlim([monthWin size(BbeforSeries,2)]);
datesStr = cellstr(datestr(dates(tSeries(monthWin:end)),'yyyy-mm'));
set(gca,'xtick',monthWin:monthWin:size(BbeforSeries,2),'xticklabel',datesStr(1:monthWin:end),'XTickLabelRotation',40);
title('Volatility Regime Adjustment - 12m');
ylabel('Mean Bias Statistic');

end

% -------------------------------------------------------------------------
% 计算协方差修正前后的B统计量
% -------------------------------------------------------------------------
function [Bbefor,Bafter,thUp,thBottom,bTQbefor,bTQafter] = CalcBStats(...
    covmatrixBefore,covmatrixAfter,factorReturn,tStart,dayNumOfMonth)

% 由于新增行业导致缺失值问题，这里仅仅为了复现报告，直接剔除新增行业
invalid = 40;
factorReturn(invalid,:) = [];
[factorNum,dayNum] = size(factorReturn);
     
% 计算因子滚动向前一个月的收益率
returnMonth = nan(factorNum,dayNum);
for iDay=1:dayNum-dayNumOfMonth+1
    returnMonth(:,iDay) = exp(sum(log(factorReturn(:,iDay:(iDay+dayNumOfMonth-1))+1),2,'omitnan'))-1;
end

% 初始化中间变量
Ubefor = nan(factorNum,factorNum,dayNum);     
Uafter = nan(factorNum,factorNum,dayNum);     
sigmaFactorB = nan(factorNum,dayNum);
sigmaFactorA = nan(factorNum,dayNum);
factorReturnMb = nan(factorNum,dayNum);
factorReturnMa = nan(factorNum,dayNum);

% 遍历每个截面
for iDay = dayNum:-1:1
    % 获取修正前后的协方差估计量，并剔除新增行业
    tmpBefore = covmatrixBefore(:,:,iDay); 
    tmpBefore(invalid,:) = []; tmpBefore(:,invalid) = [];
    tmpAfter = covmatrixAfter(:,:,iDay);
    tmpAfter(invalid,:) = []; tmpAfter(:,invalid) = [];
    if (sum(sum(isnan(tmpBefore)))+sum(sum(isnan(tmpAfter)))>0)
        continue;
    end
    % 获取修正前后协方差估计量的特征值分解结果
    [Ubefor(:,:,iDay),tempSigmaFactorB] = EigSorted(tmpBefore);
    [Uafter(:,:,iDay),tempSigmaFactorA] = EigSorted(tmpAfter);
    sigmaFactorB(:,iDay) = diag(tempSigmaFactorB);
    sigmaFactorA(:,iDay) = diag(tempSigmaFactorA);
end

% 计算特征向量（每列表示一个组合的权重向量）组合的月度收益率
for iDay = 1:dayNum-dayNumOfMonth+1
    factorReturnMb(:,iDay) = Ubefor(:,:,iDay)' * returnMonth(:,iDay);         
    factorReturnMa(:,iDay) = Uafter(:,:,iDay)' * returnMonth(:,iDay);       
end

% 计算B统计量
bTQbefor = factorReturnMb ./ sqrt(sigmaFactorB);
bTQafter = factorReturnMa ./ sqrt(sigmaFactorA);
Bbefor = nanstd((bTQbefor(:,tStart:dayNumOfMonth:dayNum-dayNumOfMonth+1)'));
Bafter = nanstd((bTQafter(:,tStart:dayNumOfMonth:dayNum-dayNumOfMonth+1)'));

% 获取置信区间
T = dayNum-dayNumOfMonth-tStart+1;  
thUp = ones(1,factorNum) + sqrt(2/ceil(T/dayNumOfMonth));
thBottom = ones(1,factorNum) - sqrt(2/ceil(T/dayNumOfMonth));

end