% -------------------------------------------------------------------------
% ���ӱ�¶���㣺�ܸ�����
% -------------------------------------------------------------------------
% [����]
% paramSet��      ȫ�ֲ�������
% daily_info��    ������Ƶ����
% quarterly_info�����ؼ�Ƶ��Ϣ
% useQuarterLoc�� ÿ���ܿ��������²Ʊ�������stockNum * dayNum) 
% [���]
% expo��          �ܸ����ӱ�¶��stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = LeverageFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc)

fprintf('�ܸ�����(Leverage)��¶�ȼ���');tic;

% ����ֵ
MC = daily_info.close .* daily_info.total_shares;   

% ��ȡ��������
quarterLoc = getfield(useQuarterLoc,paramSet.Leverage.rptFreq);

% ��ȡ��Ƶ��������
LD = nan(size(MC));           % ���ڸ�ծ
TD = nan(size(MC));           % �ܸ�ծ
TA = nan(size(MC));           % ���ʲ�
BE = nan(size(MC));           % ��Ȩ��
for iStock=1:size(MC,1)
    % ÿ���ܿ����ĲƱ�����
	qLoc = quarterLoc(iStock,:);
    % �������
    LD(iStock,~isnan(qLoc)) = quarterly_info.tot_non_cur_liab(iStock,qLoc(~isnan(qLoc)));
    TD(iStock,~isnan(qLoc)) = quarterly_info.tot_liab(iStock,qLoc(~isnan(qLoc)));
    TA(iStock,~isnan(qLoc)) = quarterly_info.tot_assets(iStock,qLoc(~isnan(qLoc)));
    BE(iStock,~isnan(qLoc)) = quarterly_info.tot_equity(iStock,qLoc(~isnan(qLoc)));   
end

% ����MLEV
MLEV = 1 + LD./MC;

% ����DTOA
DTOA = TD./TA;

% ����BLEV 
BLEV = 1 + LD./BE;

% ��Ȩ�ϳ����ӱ�¶
weightMLEV = paramSet.Leverage.MLEV.weight;     
weightDTOA = paramSet.Leverage.DTOA.weight;    
weightBLEV = paramSet.Leverage.BLEV.weight;     
expo = weightMLEV*MLEV + weightDTOA*DTOA + weightBLEV*BLEV;

fprintf('  ��ʱ��%.4f��\n',toc);

end
