% -------------------------------------------------------------------------
% ���ӱ�¶���㣺������ֵ������
% -------------------------------------------------------------------------
% [����]
% paramSet��      ȫ�ֲ�������
% daily_info��    ������Ƶ����
% quarterly_info�����ؼ�Ƶ��Ϣ
% useQuarterLoc�� ÿ���ܿ��������²Ʊ�������stockNum * dayNum) 
% [���]
% expo��          ������ֵ�����ӱ�¶��stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = BooktoPriceFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc)

fprintf('������ֵ������(BooktoPrice)��¶�ȼ���');tic;

% ������ֵ
switch paramSet.BktoPrc.mrkCapType
    case 'total'
        MC = daily_info.close .* daily_info.total_shares;     
    case 'float'
        MC = daily_info.close .* daily_info.float_a_shares;  
end

% ��ȡ��������
quarterLoc = getfield(useQuarterLoc,paramSet.BktoPrc.rptFreq);

% ��ȡÿ�������ֵ
CE = nan(size(MC));                                             
for iStock = 1:size(CE,1)
    % ÿ���ܿ����ĲƱ�����
	qLoc = quarterLoc(iStock,:);
    % �����Ƶ��Ϣ
    CE(iStock,~isnan(qLoc)) = quarterly_info.tot_equity(iStock,qLoc(~isnan(qLoc)));
end

% ����������ֵ��BTOP
BTOP = CE./MC;                                                   

% ��Ȩ�ϳ����ӱ�¶
expo = paramSet.BktoPrc.BTOP.weight * BTOP;

fprintf('  ��ʱ��%.4f��\n',toc);

end
