% -------------------------------------------------------------------------
% ���ӱ�¶���㣺�ɳ�����
% -------------------------------------------------------------------------
% [����]
% paramSet��      ȫ�ֲ�������
% daily_info��    ������Ƶ����
% quarterly_info�����ؼ�Ƶ��Ϣ
% useQuarterLoc�� ÿ���ܿ��������²Ʊ�������stockNum * dayNum) 
% [���]
% expo��          �ɳ����ӱ�¶��stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = GrowthFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc)

fprintf('�ɳ�����(Growth)��¶�ȼ���');tic;

% ��ȡ��������
quarterLoc = getfield(useQuarterLoc,'annual');

% ���������ʼ����ʱ�䴰������λΪ�꣩
window = paramSet.Growth.yearWindow;

% ���������ʼ���ʱ��ĸ�˸�ֵ����
negaOpt = paramSet.Growth.negaOpt;

% -------------------------------------------------------------------------
% ϸ������1����ȥ5����ҵ����ĸ��˾������ĸ���������(EGRO)
% -------------------------------------------------------------------------
% ��ȡ��������������
profitGrowth = YearRegressionGrowth(quarterly_info.net_profit_is, window, negaOpt);

% �������Ƶ
EGRO = nan(size(daily_info.close));                                             
for iStock = 1:size(EGRO,1)
    % ÿ���ܿ����ĲƱ�����
	qLoc = quarterLoc(iStock,:);
    % �����Ƶ��Ϣ
    EGRO(iStock,~isnan(qLoc)) = profitGrowth(iStock,qLoc(~isnan(qLoc)));
end

% -------------------------------------------------------------------------
% ϸ������2����ȥ5����ҵӪҵ������ĸ���������(SGRO)
% -------------------------------------------------------------------------
% ��ȡ��������������
operGrowth = YearRegressionGrowth(quarterly_info.tot_oper_rev, window, negaOpt);

% �������Ƶ
SGRO = nan(size(daily_info.close));                                             
for iStock = 1:size(SGRO,1)
    % ÿ���ܿ����ĲƱ�����
	qLoc = quarterLoc(iStock,:);
    % �����Ƶ��Ϣ
    SGRO(iStock,~isnan(qLoc)) = operGrowth(iStock,qLoc(~isnan(qLoc)));
end

% ��Ȩ�ϳ����ӱ�¶
weightEGRO = paramSet.Growth.EGRO.weight;
weightSGRO = paramSet.Growth.SGRO.weight;
expo = (weightEGRO*EGRO+weightSGRO*SGRO) / (weightEGRO+weightSGRO);

fprintf('  ��ʱ��%.4f��\n',toc);

end


% -------------------------------------------------------------------------
% ���ߺ��������ûع鷽�����㸴��������
% data��   �Ʊ����ݣ�stockNum * quarterNum��
% window�� �ع���Ҫ�Ĵ��ڳ��ȣ���λΪ�꣩
% negaOpt����ĸ�˸�ֵ����abs��ʾȡ����ֵ��nan��ʾ��Ϊ��ֵ��
% -------------------------------------------------------------------------
function growth = YearRegressionGrowth(data, window, negaOpt)

% ��ȡ��Ƶ���ݣ��������ݿ��1997���걨��ʼ��Ҳ����һ�о����걨���ݣ�
yearlyData = data(:,1:4:end);

% ��ʼ��
yearlyBeta = nan(size(yearlyData));
yearlyMean = nan(size(yearlyData));

% ����ÿ����ȣ����㸴��������
for t = window:size(yearlyData,2)
    % ��ȡ����������
    sample = yearlyData(:,(t-window+1):t);
    % ����ع�ϵ��
    yearlyBeta(:,t) = sample * ((1:window) - (1+window) / 2)' / sqrt((window + 1) * (window - 1) / 12) / window;
    % ���㴰���ھ�ֵ�����Ը�ֵ���д���
    tmpMean = mean(sample,2);
    switch negaOpt
        case 'nan'
            tmpMean(tmpMean<0) = nan;       % ����ĸΪ��ʱ��nan
        case 'abs'
            tmpMean = abs(tmpMean);         % ����ĸΪ��ʱȡ����ֵ
    end
    yearlyMean(:,t) = tmpMean;
end   

% ����������
yearlyGrowth = yearlyBeta ./ yearlyMean;
yearlyGrowth(isinf(yearlyGrowth)) = nan;

% ����Ƶ�����������Ƶά��
growth = nan(size(data));
growth(:,1:4:end) = yearlyGrowth;

end







