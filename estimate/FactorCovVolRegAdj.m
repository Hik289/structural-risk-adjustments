% -------------------------------------------------------------------------
% ����Э���������ƫ�������ȫ�����У�
% -------------------------------------------------------------------------
% [����]
% paramSet��      ȫ�ֲ�������
% factorEigenAdj������ֵ��������Э�������factorNum * factorNum * dayNum��
% factorReturn��  �������������У�factorNum * dayNum��
% [���]
% factorCovVolRegAdj���ز�����ƫ�������������styleNum * styleNum * dayNum)
% -------------------------------------------------------------------------
function factorCovVolRegAdj = FactorCovVolRegAdj(paramSet,factorEigenAdj,factorReturn)

fprintf('����Э������󲨶���ƫ�����');tic;

% ����׼��
timeWin = paramSet.FactorCov.VolRegAdj.timeWin;    
halfLife = paramSet.FactorCov.VolRegAdj.halfLife;  
[factorNum,~,dayNum] = (size(factorEigenAdj));

% ��������δ��һ���µĶ���������
logReturnMonth = nan(factorNum,dayNum);
logReturnDay = log(factorReturn+1);
for iDay = 1:dayNum-21+1
    logReturnMonth(:,iDay) = sum(logReturnDay(:,iDay:(iDay+21-1)),2);
end
returnMonth = exp(logReturnMonth) - 1;

% ��ʼ�����
factorCovVolRegAdj = nan(size(factorEigenAdj));
lambdaFall = nan(1,dayNum);

% ��ȡ������������ֵ������Ĳ�����
singleFactorEigAdj = nan(factorNum,dayNum);
for iDay = 1:dayNum
    singleFactorEigAdj(:,iDay) = diag(factorEigenAdj(:,:,iDay));
end

% �����������ӵ���ƫ��ͳ����
FktToSIGMAkt = returnMonth.^2 ./ singleFactorEigAdj;                     
BFt = nanmean(FktToSIGMAkt);                                              
weight = power(0.5,(timeWin:-1:1)/halfLife);                              
for iDay = timeWin:dayNum
    % ���㲨���ʵ���ϵ��
    data = BFt(iDay-timeWin+1:iDay);
    lambdaF = nansum(data.*weight,2) ./ sum(weight(~isnan(data)));
    lambdaFall(1,iDay) = lambdaF;
    % ���в����ʵ���
    factorCovVolRegAdj(:,:,iDay) = lambdaF * factorEigenAdj(:,:,iDay);      
end

% ����������Ӳ����ʣ����ڼ��鲨����ƫ��������
% CSVFt = nanstd(returnMonth,1,1);

fprintf('  ��ʱ��%.4f��\n',toc);

end