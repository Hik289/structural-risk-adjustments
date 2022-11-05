% -------------------------------------------------------------------------
% 检查残差协方差估计的效果 
% [输入]
% dates：                    全日期序列（1 * dayNum
% beginDate：                起始起始日期
% specialReturn：            残差收益率序列（stockNum * dayNum）
% specialCovNW：             NW调整协方差估计（stockNum * dayNum）
% specialCovStructAdj：      结构化调整协方差估计（stockNum * dayNum）
% specialCovBiasAdj：        贝叶斯压缩调整协方差（stockNum * dayNum）
% specialCovVolRegAdj：      波动率调整协方差估计（stockNum * dayNum）
% -------------------------------------------------------------------------
function CheckSpecialCov(dates,beginDate,specialReturn,specialCovNW,...
    specialCovStructAdj,specialCovBiasAdj,specialCovVolRegAdj)

% 基本参数设置
monthWin = 12;
dayNumOfMonth = 21;   
groupNum = 10;
[stockNum,dayNum] = size(specialReturn);

% 月度特异收益
returnMonth = nan(stockNum,dayNum);
for iDay = 1:dayNum-dayNumOfMonth+1
    returnMonth(:,iDay)=exp(sum(log(specialReturn(:,iDay:(iDay+dayNumOfMonth-1))+1),2))-1;
end

% 初始化图表
figure()
set(gcf,'color','w'); 
set(gcf,'position',[100,100,1000,500])

% -------------------------------------------------------------------------
% 图表1：不同波动率分组下的B统计量(NW、结构化调整、贝叶斯压缩、波动率调整)
% -------------------------------------------------------------------------
% 计算起始位置
tStart = find(dates>=datenum(beginDate),1,'first');

% 初始化数据
sigmaMatrix1= specialCovNW;
sigmaMatrix2 = specialCovStructAdj;
sigmaMatrix3 = specialCovBiasAdj;
sigmaMatrix4 = specialCovVolRegAdj;
sigmaMatrix1(sigmaMatrix1==0)=nan;
sigmaMatrix2(sigmaMatrix2==0)=nan;
sigmaMatrix3(sigmaMatrix3==0)=nan;
sigmaMatrix4(sigmaMatrix4==0)=nan;

% 计算B统计量（个股层面）
tSeries = tStart:dayNumOfMonth:dayNum-dayNumOfMonth+1;
bSt1 = returnMonth(:,tSeries) ./ sigmaMatrix1(:,tSeries);
bSt2 = returnMonth(:,tSeries) ./ sigmaMatrix2(:,tSeries);
bSt3 = returnMonth(:,tSeries) ./ sigmaMatrix3(:,tSeries);
bSt4 = returnMonth(:,tSeries) ./ sigmaMatrix4(:,tSeries);

% 计算B统计量（分组层面）
B1 = GroupBstats(bSt1,sigmaMatrix1(:,tSeries),groupNum,monthWin);
B2 = GroupBstats(bSt2,sigmaMatrix2(:,tSeries),groupNum,monthWin);
B3 = GroupBstats(bSt3,sigmaMatrix3(:,tSeries),groupNum,monthWin);
B4 = GroupBstats(bSt4,sigmaMatrix4(:,tSeries),groupNum,monthWin);

% 作图
subplot(1,2,1);
plot(ones(1,groupNum),'-b');
hold on;
plot(ones(1,groupNum)+sqrt(2/monthWin),'--b');
plot(ones(1,groupNum)-sqrt(2/monthWin),'--b');
h1 = plot(B1(:,length(tSeries)-monthWin+1),'.-k');
h2 = plot(B2(:,length(tSeries)-monthWin+1),'.-m');
h3 = plot(B3(:,length(tSeries)-monthWin+1),'.-r');
h4 = plot(B4(:,length(tSeries)-monthWin+1),'.-g');
xlim([1 groupNum]);
legend([h1,h2,h3,h4],{'NW','Struct','Shrink','VRA'});
title('Special All Adjustment - 12m');
xlabel('Special Volatility Decile');
ylabel('Mean Bias Statistic');
    
% -------------------------------------------------------------------------
% 图表2：波动率偏误调整前、后的偏误统计量12个月滚动均值对比
% -------------------------------------------------------------------------
% 数据设置
sigmaBefor = specialCovBiasAdj;
sigmaAfter = specialCovVolRegAdj;
sigmaBefor(sigmaBefor==0)=nan;
sigmaAfter(sigmaAfter==0)=nan;

% 基本参数设置
tStart = find(dates>=datenum(beginDate),1,'first') - monthWin*dayNumOfMonth;

% 计算小b统计量
tSeries = tStart:dayNumOfMonth:dayNum-dayNumOfMonth+1;
bTQbefor = returnMonth(:,tSeries)./sigmaBefor(:,tSeries);
bTQafter = returnMonth(:,tSeries)./sigmaAfter(:,tSeries);
    
% 横截面因子总体偏误统计量每12个月的偏误统计量
tNum = length(tSeries);
BbeforSeries = nan(1,tNum-monthWin+1);
BafterSeries = nan(1,tNum-monthWin+1);
for t=1:tNum-monthWin+1
    BbeforSeries(t) = nanmean(nanstd(bTQbefor(:,t:t+monthWin-1),[],2));
    BafterSeries(t) = nanmean(nanstd(bTQafter(:,t:t+monthWin-1),[],2));
end   

% 作图
subplot(1,2,2); hold on;
plot(ones(1,size(BbeforSeries,2)),'b');
plot(ones(1,size(BbeforSeries,2))+sqrt(2/monthWin),'--b');
plot(ones(1,size(BbeforSeries,2))-sqrt(2/monthWin),'--b');
h1 = plot(BbeforSeries,'-r');
h2 = plot(BafterSeries,'-g');
legend([h1,h2],{'Before','After'});
xlim([monthWin size(BbeforSeries,2)]);
datesStr=cellstr(datestr(dates(tSeries(monthWin:end)),'yyyymmdd'));
set(gca,'xtick',monthWin:monthWin:size(BbeforSeries,2),'xticklabel',datesStr(1:monthWin:end),'XTickLabelRotation',40);
% set(gca,'yTick',0.5:0.1:1.5);
title('Special Volatility Regime Adjustment - 12m');
ylabel('Mean Bias Statistic');

end

% -------------------------------------------------------------------------
% 分组统计B统计量
% -------------------------------------------------------------------------
function meanB = GroupBstats(bSt,sigmaMatrix,groupNum,timeWin)

% 获取每个截面上的分组结果
[stockNum,dayNum] = size(sigmaMatrix);
group = nan(stockNum,dayNum);
th = nan(1,groupNum+1); 
 for iDay = 1:dayNum
    th(1) = min(sigmaMatrix(:,iDay))-1;                                                    
    th(groupNum+1) = max(sigmaMatrix(:,iDay))+1;                   
    for groupTh = 2:groupNum
        th(groupTh) = prctile(sigmaMatrix(:,iDay),100*(groupTh-1)/groupNum); 
    end
    for iGroup=1:groupNum
        stockIn = (sigmaMatrix(:,iDay)>th(iGroup)) & (sigmaMatrix(:,iDay)<=th(iGroup+1));                
        group(stockIn,iDay) = iGroup;
    end
 end
    
% 统计各个分组的B统计量
meanB = nan(groupNum,dayNum-timeWin+1);
for iDay = 1:dayNum-timeWin
    bStat=nanstd(bSt(:,iDay+1:iDay+timeWin),[],2);
    for iGroup=1:groupNum
        isGroup=((group(:,iDay)==iGroup)&(~isnan(bStat)));
        meanB(iGroup,iDay)=nanmean(bStat(isGroup));
    end
end
meanB(:,dayNum-timeWin+1)=nanmean(meanB(:,1:dayNum-timeWin),2);

end






