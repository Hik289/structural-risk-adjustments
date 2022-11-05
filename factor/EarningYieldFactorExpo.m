% -------------------------------------------------------------------------
% ���ӱ�¶���㣺ӯ������
% -------------------------------------------------------------------------
% [����]
% paramSet��      ȫ�ֲ�������
% daily_info��    ������Ƶ����
% quarterly_info�����ؼ�Ƶ��Ϣ
% useQuarterLoc�� ÿ���ܿ��������²Ʊ�������stockNum * dayNum) 
% [���]
% expo��          ӯ�����ӱ�¶��stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = EarningYieldFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc)

fprintf('ӯ������(EarningYield)��¶�ȼ���');tic;

% ������ֵ
switch paramSet.EarningYield.mrkCapType
    case 'total'
        MC = daily_info.close .* daily_info.total_shares;            
    case 'float'
        MC = daily_info.close .* daily_info.float_a_shares;          
end

% ��ȡ��������
quarterLoc = getfield(useQuarterLoc,paramSet.EarningYield.rptFreq);

% -------------------------------------------------------------------------
% ϸ������1����ȥ12���µ���ӯ��(ETOP)
% -------------------------------------------------------------------------
% ��ȡ��ĸ������TTMֵ
NPP = transformTTM(quarterly_info.np_belongto_parcomsh); 

% ���ղƱ��������ڣ�����Ƶ������������Ƶ
E = nan(size(MC));
for iStock = 1:size(MC,1)
    % ÿ���ܿ����ĲƱ�����
	qLoc = quarterLoc(iStock,:);
    % �����Ƶ��Ϣ
    E(iStock,~isnan(qLoc)) = NPP(iStock,qLoc(~isnan(qLoc)));              
end

% ����ETOP
ETOP = E./MC;

% -------------------------------------------------------------------------
% ϸ������2����ȥ12���µľ�Ӫ�Ծ��ֽ�������ֵ�ı�ֵ(CETOP)
% -------------------------------------------------------------------------
% ��ȡ��Ӫ�Ծ��ֽ���TTMֵ
NCF = transformTTM(quarterly_info.net_cash_flows_oper_act); 

% ���ղƱ��������ڣ�����Ƶ������������Ƶ
CE = nan(size(MC));
for iStock = 1:size(MC,1)
    % ÿ���ܿ����ĲƱ�����
	qLoc = quarterLoc(iStock,:);
    % �����Ƶ��Ϣ
    CE(iStock,~isnan(qLoc)) = NCF(iStock,qLoc(~isnan(qLoc)));              
end

% ����CETOP
CETOP = CE./MC;

% ��Ȩ�ϳ����ӱ�¶��ע��Barraԭ���л���Ҫ����EPFWD���ӣ�����ʡȥ�ˣ�
weightCETOP = paramSet.EarningYield.CETOP.weight;
weightETOP = paramSet.EarningYield.ETOP.weight;
expo = (weightCETOP*CETOP+weightETOP*ETOP) / (weightCETOP+weightETOP);

fprintf('  ��ʱ��%.4f��\n',toc);

end

% -------------------------------------------------------------------------
% ���ߺ�������ԭʼ�Ʊ��������ݣ��ھ�Ϊ�ۼ�ֵ��ת��ΪTTMֵ
% ת����ʽ������ttm = ���ڱ��� + ���һ�Σ����㱾�ڣ��걨 - ��һ��ͬ�ڱ���
% -------------------------------------------------------------------------
function ttmData = transformTTM(data)

% ȥ��ͬ�ڱ���
quarterYearBeforeData = [nan(size(data,1),4) data(:,1:end-4)];

% ȥ���걨��ע�Ȿ�����ݿ��һ��������1997���걨��
lastYearData = data;
lastYearData(:,2:4:end) = data(:,1:4:end-1);
lastYearData(:,3:4:end) = data(:,1:4:end-2);
lastYearData(:,4:4:end) = data(:,1:4:end-3);
lastYearData(:,5:4:end) = data(:,1:4:end-4);

% ����TTMֵ
ttmData = data + lastYearData - quarterYearBeforeData;

% ȱʧֵ���Ϊǰһ��ֵ
ttmData = fillmissing(ttmData,'prev',2);                               

end













