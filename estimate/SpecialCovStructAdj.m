% -------------------------------------------------------------------------
% �в�Э����ṹ������
% -------------------------------------------------------------------------
% [����]
% paramSet��      ȫ�ֲ�������
% daily_info��    ��Ƶ���ݼ���
% specialCovNW��  NW������Ĳв�Э���stockNum * dayNum��
% factorExpo��    ���ӱ�¶���ϣ�stockNum * factorNum * dayNum��
% [���]
% specialCovStructAdj��  �в�Э������ƣ�stockNum * dayNum)
% -------------------------------------------------------------------------
function specialCovStructAdj = SpecialCovStructAdj(paramSet,daily_info,specialCovNW,factorExpo)

fprintf('�в�Э�������ṹ������');tic;

% ����׼��
timeWin = paramSet.SpecialCov.StructAdj.timeWindow;
E0 = paramSet.SpecialCov.StructAdj.E0;       
regressMode = paramSet.SpecialCov.StructAdj.regressMode;    
factorNum = paramSet.SpecialCov.StructAdj.factorNum;
[stockNum,dayNum] = size(specialCovNW);

% ��ʼ�����
specialCovStructAdj = nan(stockNum,dayNum);
specialCovStructGama = nan(stockNum,dayNum);

% ����ع�Ȩ��
if isequal(regressMode,'WLS')                              
    weightCap = daily_info.close .* daily_info.float_a_shares;
    threshold = prctile(weightCap,paramSet.global.mktBlockRatio);
    weightCap = min(weightCap,repmat(threshold,size(weightCap,1),1));  
    weightCap(isnan(weightCap)) = 0;  
else
    weightCap = ones(size(daily_info.close));
end

% ����ÿ������
for iDay = max(timeWin,paramSet.updateTBegin):dayNum
    
    % ---------------------------------------------------------------------
    % ����ÿ֧��Ʊ��Э������
    % ---------------------------------------------------------------------
    % ��ȡ��������ʱ������
    tempData = specialCovNW(:,iDay-timeWin+1:iDay);                     
    % �Ƚ���׼�� SigmaU
    Q3 = prctile(tempData,75,2);                                          
    Q1 = prctile(tempData,25,2);                                         
    SigmaU = (1/1.35)*(Q3-Q1);                                              
    % �������������������׼��
    SigmaUEQ = std(tempData,0,2,'omitnan');                                  
    % ����Zu �����ж�β�ʳ̶�
    Zu = abs(SigmaUEQ./SigmaU-1);    
    % ����gamma
    timeWinValid = sum(~isnan(tempData),2);                               
    gammaNum1 = min(1,max(0,timeWinValid/120-0.5));                       
    gammaNum2 = min(1,exp(1-Zu));                                  
    specialCovStructGama(:,iDay) = gammaNum1 .* gammaNum2;    
    
    % ---------------------------------------------------------------------
    % ��������Э������Ϊ1�����ʹ�Ʊ������Ʊ����������Ĳ����ʶ�������������
    % ��¶�����Իع飬�õ�ÿ�����Ӷ����첨���Ĺ���ֵ
    % ---------------------------------------------------------------------
    % ��ȡ���������ӱ�¶                  
    panelFactorExpo = factorExpo(:,1:factorNum,iDay);  
    % ��ȡȡgammaAll=1����ֵ�ǿյĸ�������
    lnSigma = log(specialCovNW(:,iDay));                              
    lineNoNan = ~isnan(sum([lnSigma,panelFactorExpo],2));                      
    gamma1data = specialCovStructGama(:,iDay)==1;                                  
    goodDataNum = gamma1data & lineNoNan;                                 
    if sum(goodDataNum)<12
        continue;
    end
    % ��ȡ�ع��Ա������������Ȩ��
    Y = lnSigma(goodDataNum);
    X = panelFactorExpo(goodDataNum,:);
    w = weightCap(goodDataNum,iDay);
    % ��ȡ�ع������
    beta = zeros(size(X,2),1);
    validCol = sum(X~=0)>0;
    validX = X(:,validCol);
    beta(validCol) = (validX'*diag(w)*validX) \ (validX'*diag(w)*Y);
    
    % ---------------------------------------------------------------------
    % ��ȡÿ֧��Ʊ�Ľṹ��������Ԥ��ֵ�������н�����Լ�Ȩ
    % ��¶�����Իع飬�õ�ÿ�����Ӷ����첨���Ĺ���ֵ
    % ---------------------------------------------------------------------
    % ��ȡÿ֧��Ʊ�Ľṹ��������Ԥ��ֵ
    sigmaSTR = E0 * exp(panelFactorExpo*beta);                               
    % ���ɽ��
    specialCovStructAdj(:,iDay) = ...
        specialCovNW(:,iDay) .* specialCovStructGama(:,iDay) +...
        sigmaSTR .* (1-specialCovStructGama(:,iDay));
    
end

% ����ȱʧֵ
specialCovStructAdj(specialCovStructAdj==0) = nan;

% �������������ģʽ������Ҫ����ʷ���ƴ��
if paramSet.updateTBegin ~= 1
    % ��ȡ��ʷ����
    histResult = importdata([paramSet.global.save_path 'specialCovStructAdj.mat']);
    [n_stocks_before,~,~] = size(histResult);
    % ��Ʊά�ȸ���
    [n_stocks_after,~,n_days_new] = size(specialCovStructAdj);
    if n_stocks_before < n_stocks_after
        histResult(n_stocks_before+1:n_stocks_after,:) = nan;
    end
    % ʱ��ά�ȸ���    
    id_last_nan = find(sum(~isnan(specialCovStructAdj))==0,1,'last');
    histResult(:,id_last_nan+1:n_days_new) = specialCovStructAdj(:,id_last_nan+1:n_days_new);
    % ���ؽ��
    specialCovStructAdj = histResult;
end

fprintf('  ��ʱ��%.4f��\n',toc);

end