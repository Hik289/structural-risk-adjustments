% -------------------------------------------------------------------------
% �в�Э���Newey-West����
% -------------------------------------------------------------------------
% [����]
% paramSet��      ȫ�ֲ�������
% specialReturn�� �в����������У�stockNum * dayNum��
% [���]
% specialCovNW��  ����Э������ƣ�stockNum * dayNum)��ֻ�����Խ���Ԫ��
% -------------------------------------------------------------------------
function specialCovNW = SpecialCovNeweyWest(paramSet,specialReturn)

fprintf('�в�Э�������Newey-West����');tic;

% ����׼��
tBegin = paramSet.SpecialCov.NW.tBegin;
timeWin = paramSet.SpecialCov.NW.timeWindow;
halfLife = paramSet.SpecialCov.NW.halfLife;
dayNumOfMonth = paramSet.SpecialCov.NW.dayNumOfMonth;
D = paramSet.SpecialCov.NW.D;

% ����׼��
[stockNum,dayNum] = size(specialReturn);

% ��˥��Ȩ������
weightList = power(0.5,(timeWin:-1:1)/halfLife);

% ��ʼ�����
specialCovNW = nan(stockNum,dayNum);

% ����ÿ������
for iDay = tBegin : dayNum
    
    % ��ȡ����������
    data = specialReturn(:,iDay-timeWin+1:iDay);
    if sum(sum(~isnan(data)))<5                                        
        data = nan(size(data));
    end
    
    % ȥ��ֵ
    weight = weightList / sum(weightList);
    data = data - repmat(sum(data.*weight,2,'omitnan'),[1,timeWin]);    
    
    % ����в�Э����
    SNW = sum (data.^2 .* repmat(weight,[stockNum,1]), 2, 'omitnan');
    for q = 1:D
        k = 1- q/(D+1);
        sumw = sum(weightList(q+1:end));
        weight= weightList(q+1:end) / sumw;
        omega = 2 * sum(data(:,q+1:end).* repmat(weight,[stockNum,1]).* data(:,1:end-q), 2, 'omitnan');
        SNW = SNW + k * omega;
    end
    
    % �洢���
    specialCovNW(:,iDay) = dayNumOfMonth * SNW;
    
end

% ע������ȡ�˿������������������ʵ�����Ǳ�׼�����
specialCovNW = sqrt(specialCovNW);        
specialCovNW(specialCovNW==0) = nan;

fprintf('  ��ʱ��%.4f��\n',toc);

end
