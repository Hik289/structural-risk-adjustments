% -------------------------------------------------------------------------
% ����Э���Newey-West������Ч�ʽϸߣ�ֱ��ȫ�����У�
% -------------------------------------------------------------------------
% [����]
% paramSet��      ȫ�ֲ�������
% factorReturn��  �������������У�factorNum * dayNum��
% [���]
% factorCov��     ����Э������ƣ�styleNum * styleNum * dayNum)
% -------------------------------------------------------------------------
function factorCov = FactorCovNeweyWest(paramSet, factorReturn)

fprintf('����Э�������Newey-West����');tic;

% ����׼��
tBegin = paramSet.FactorCov.NW.tBegin;
timeWin = paramSet.FactorCov.NW.timeWindow;
halfLife = paramSet.FactorCov.NW.halfLife;
dayNumOfMonth = paramSet.FactorCov.NW.dayNumOfMonth;
D = paramSet.FactorCov.NW.D;

% ��ȡ��������������
[styleNum,dayNum] = size(factorReturn);

% ��˥��Ȩ������
weightList = power(0.5,(timeWin:-1:1)/halfLife);      

% ��ʼ�����
factorCov = nan(styleNum,styleNum,dayNum);

% ����ÿ������
for iDay = tBegin : dayNum
    
    % ��ȡ����������
    data = factorReturn(:,iDay-timeWin+1:iDay);
    if sum(sum(~isnan(data)))<5                                        
        data = nan(size(data));
    end
    
    % ��������Э����
    weight = weightList / sum(weightList);
    data = data - repmat(sum(data.*weight,2,'omitnan'),[1,timeWin]);    
    FNW = data * diag(weight) * data';
    
    % �����������
    for q = 1:D
        k = 1- q/(D+1);
        sumw = sum(weightList(q+1:end));
        weight= weightList(q+1:end) / sumw;
        dataleft = data(:,q+1:end) * diag(weight) * data(:,1:end-q)';
        dataright = data(:,1:end-q) * diag(weight) * data(:,q+1:end)';
        FNW = FNW + k * (dataleft + dataright);
    end
    
    % ������
    factorCov(:,:,iDay) = dayNumOfMonth * FNW;   
    
end

fprintf('  ��ʱ��%.4f��\n',toc);

end
