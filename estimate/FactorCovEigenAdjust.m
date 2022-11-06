% -------------------------------------------------------------------------
% ����Э�������ֵ������Ч�ʽϵͣ������������֣�������ʷ���ƴ�ӣ�
% -------------------------------------------------------------------------
% [����]
% paramSet��      ȫ�ֲ�������
% factorCovNW��   NW�����������Э�������factorNum * factorNum * dayNum��
% [���]
% factorCovEigenAdj��     ����ֵ�������ƣ�styleNum * styleNum * dayNum)
% -------------------------------------------------------------------------
function factorCovEigenAdj = FactorCovEigenAdjust(paramSet,factorCovNW)
    
fprintf('����Э�����������ֵ����');tic;

% ��������
MCS = paramSet.FactorCov.EigenAdj.MCS;                      
A = paramSet.FactorCov.EigenAdj.A;        
timeWin = paramSet.FactorCov.EigenAdj.timeWindow;
[factorNum,~,dayNum] = size(factorCovNW);   

% ��ʼ�����
factorCovEigenAdj = nan(factorNum,factorNum,dayNum);
factorCovEigenAdjGamma = nan(factorNum,dayNum);

% ѭ���������н��������
for iDay = paramSet.updateTBegin:dayNum
    
    fprintf('    �����ţ�%d\n', iDay);

    % NANֵ����������ҵ�������ֹ����������֮ǰ��������һ������ά����ȱʧ
    tempFnw = factorCovNW(:,:,iDay);
    Fnw = tempFnw(~isnan(tempFnw));
    FnwDims = sqrt(size(Fnw,1));
    if FnwDims == 0
        continue;
    end
    Fnw = reshape(Fnw,[FnwDims,FnwDims]);

    % ���ؿ���ģ�⣺����ģ�����ƫ��
    [U0,D0] = EigSorted(Fnw);                    
    lambda = zeros(FnwDims,1);
    tempRM = U0*sqrt(D0);                                  
    for iterMCS=1:MCS
        rng(iterMCS);     % �̶���������ӵ�
        rm = tempRM * randn(FnwDims,timeWin);
        Fm = cov(rm');
        [Um,Dm] = EigSorted(Fm);              
        DmReal = diag(Um'*Fnw*Um);           
        lambda=lambda+DmReal./diag(Dm);       
    end
    lambda = sqrt(lambda/MCS);                        

    % Э�����������ֵ����
    gamma = A * (lambda-1) + 1;                    
    D0Real = D0 .* diag(gamma.^2);                        
    Feigen = U0 * D0Real * U0';                             

    % �洢���
    FeigenReal = nan(size(tempFnw));
    FeigenReal(~isnan(tempFnw)) = Feigen(1:end);
    factorCovEigenAdj(:,:,iDay) = FeigenReal;        
    factorCovEigenAdjGamma(1:FnwDims,iDay) = gamma;
end

% �������������ģʽ������Ҫ����ʷ���ƴ��
if paramSet.updateTBegin ~= 1
    % ��ȡ��ʷ����
    histResult = importdata([paramSet.global.save_path 'factorCovEigenAdj.mat']);
    % ʱ��ά�ȸ���
    [~,~,n_days_new] = size(factorCovEigenAdj);
    histResult(:,:,paramSet.updateTBegin:n_days_new) = factorCovEigenAdj(:,:,paramSet.updateTBegin:n_days_new);
    % ���ؽ��
    factorCovEigenAdj = histResult;
end
    
fprintf('  ��ʱ��%.4f��\n',toc);

end