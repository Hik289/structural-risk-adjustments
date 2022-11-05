% -------------------------------------------------------------------------
% �������Э������Ƶ�Ч�� 
% [����]
% dates��                    ȫ�������У�1 * dayNum
% beginDate��                ��ʼ��ʼ����
% factorReturn��             �������������У�factorNum * dayNum��
% factorCovNW��              NW��������Э������ƣ�factorNum * factorNum * dayNum��
% factorCovEigenAdj��        ����ֵ����Э������ƣ�factorNum * factorNum * dayNum��
% factorCovVolRegAdj��       �����ʵ���Э������ƣ�factorNum * factorNum * dayNum��
% -------------------------------------------------------------------------
function CheckFactorCov(dates,beginDate,factorReturn,factorCovNW,factorCovEigenAdj,factorCovVolRegAdj)

% ������������
dayNumOfMonth = 21;   
dayNum = length(dates);

% ��ʼ��ͼ��
figure()
set(gcf,'color','w'); 
set(gcf,'position',[100,100,1000,500])

% -------------------------------------------------------------------------
% ͼ��1������ֵ����ǰ���Bͳ�����Ա�
% -------------------------------------------------------------------------
% ������ʼλ��
tStart = find(dates>=datenum(beginDate),1,'first');

% ����Bͳ����
[Bbefor,Bafter,thUp,thBottom,~,~] = CalcBStats(...
    factorCovNW,factorCovEigenAdj,factorReturn,tStart,dayNumOfMonth);

% ��ͼ
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
% ͼ��2 & ͼ��3��������ƫ�����ǰ�����ƫ��ͳ����12���¹�����ֵ�Ա�
% -------------------------------------------------------------------------
% ������ʼλ��
monthWin = 12;
tStart = find(dates>=datenum(beginDate),1,'first') - monthWin*dayNumOfMonth;

% ����Bͳ����
[Bbefor,Bafter,thUp,thBottom,bTQbefor,bTQafter] = CalcBStats(...
    factorCovEigenAdj,factorCovVolRegAdj,factorReturn,tStart,dayNumOfMonth);

% ��ͼ��ʾBͳ����
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

% ����12���¹���ƽ����Сbͳ����ֵ
tSeries = tStart:dayNumOfMonth:dayNum-dayNumOfMonth+1;
BbeforSeries = nan(1,length(tSeries)-monthWin+1);
BafterSeries = nan(1,length(tSeries)-monthWin+1);
for t = 1:size(BbeforSeries,2)
    BbeforSeries(t) = mean(nanstd((bTQbefor(:,tSeries(t:t+monthWin-1))')));
    BafterSeries(t) = mean(nanstd((bTQafter(:,tSeries(t:t+monthWin-1))')));
end   

% ��ͼ��ʾСbͳ��������12�¾�ֵ
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
% ����Э��������ǰ���Bͳ����
% -------------------------------------------------------------------------
function [Bbefor,Bafter,thUp,thBottom,bTQbefor,bTQafter] = CalcBStats(...
    covmatrixBefore,covmatrixAfter,factorReturn,tStart,dayNumOfMonth)

% ����������ҵ����ȱʧֵ���⣬�������Ϊ�˸��ֱ��棬ֱ���޳�������ҵ
invalid = 40;
factorReturn(invalid,:) = [];
[factorNum,dayNum] = size(factorReturn);
     
% �������ӹ�����ǰһ���µ�������
returnMonth = nan(factorNum,dayNum);
for iDay=1:dayNum-dayNumOfMonth+1
    returnMonth(:,iDay) = exp(sum(log(factorReturn(:,iDay:(iDay+dayNumOfMonth-1))+1),2,'omitnan'))-1;
end

% ��ʼ���м����
Ubefor = nan(factorNum,factorNum,dayNum);     
Uafter = nan(factorNum,factorNum,dayNum);     
sigmaFactorB = nan(factorNum,dayNum);
sigmaFactorA = nan(factorNum,dayNum);
factorReturnMb = nan(factorNum,dayNum);
factorReturnMa = nan(factorNum,dayNum);

% ����ÿ������
for iDay = dayNum:-1:1
    % ��ȡ����ǰ���Э��������������޳�������ҵ
    tmpBefore = covmatrixBefore(:,:,iDay); 
    tmpBefore(invalid,:) = []; tmpBefore(:,invalid) = [];
    tmpAfter = covmatrixAfter(:,:,iDay);
    tmpAfter(invalid,:) = []; tmpAfter(:,invalid) = [];
    if (sum(sum(isnan(tmpBefore)))+sum(sum(isnan(tmpAfter)))>0)
        continue;
    end
    % ��ȡ����ǰ��Э���������������ֵ�ֽ���
    [Ubefor(:,:,iDay),tempSigmaFactorB] = EigSorted(tmpBefore);
    [Uafter(:,:,iDay),tempSigmaFactorA] = EigSorted(tmpAfter);
    sigmaFactorB(:,iDay) = diag(tempSigmaFactorB);
    sigmaFactorA(:,iDay) = diag(tempSigmaFactorA);
end

% ��������������ÿ�б�ʾһ����ϵ�Ȩ����������ϵ��¶�������
for iDay = 1:dayNum-dayNumOfMonth+1
    factorReturnMb(:,iDay) = Ubefor(:,:,iDay)' * returnMonth(:,iDay);         
    factorReturnMa(:,iDay) = Uafter(:,:,iDay)' * returnMonth(:,iDay);       
end

% ����Bͳ����
bTQbefor = factorReturnMb ./ sqrt(sigmaFactorB);
bTQafter = factorReturnMa ./ sqrt(sigmaFactorA);
Bbefor = nanstd((bTQbefor(:,tStart:dayNumOfMonth:dayNum-dayNumOfMonth+1)'));
Bafter = nanstd((bTQafter(:,tStart:dayNumOfMonth:dayNum-dayNumOfMonth+1)'));

% ��ȡ��������
T = dayNum-dayNumOfMonth-tStart+1;  
thUp = ones(1,factorNum) + sqrt(2/ceil(T/dayNumOfMonth));
thBottom = ones(1,factorNum) - sqrt(2/ceil(T/dayNumOfMonth));

end