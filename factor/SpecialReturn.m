% -------------------------------------------------------------------------
% ����в�������
% -------------------------------------------------------------------------
% [����]
% paramSet��        ȫ�ֲ�������
% daily_info��      ������Ƶ����
% factorExpo:       ���ӱ�¶����stockNum * factorNum * dayNum��
% factorReturn��    ���������ʾ���factorNum * dayNum��
% [���]
% specialReturn��   �в������ʼ�������stockrNum * dayNum��
% -------------------------------------------------------------------------
function specialReturn = SpecialReturn(paramSet,daily_info,factorExpo,factorReturn)

fprintf('���������ʼ���');tic;

% ���ɵ�����������
stockReturn = tick2ret(daily_info.close_adj')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];
stockReturn = stockReturn(:,paramSet.updateTBegin:end);
[stockNum,dayNum] = size(stockReturn); 

% ��ʼ�����
specialReturn = nan(stockNum,dayNum);   

% �����������ʼ���
for iDay = 2:dayNum
    % ���ӱ�¶(stockNum * factorNum)
    panelExpo = factorExpo(:,:,iDay-1);
    % ���������ʣ�factorNum * 1��
    panelFactorReturn = factorReturn(:,iDay);
    panelFactorReturn(isnan(panelFactorReturn)) = 0;
    % ����в�������
    specialReturn(:,iDay) = stockReturn(:,iDay) - panelExpo * panelFactorReturn;
end

fprintf('  ��ʱ��%.4f��\n',toc);

end