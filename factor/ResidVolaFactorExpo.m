% -------------------------------------------------------------------------
% ���ӱ�¶���㣺����������
% -------------------------------------------------------------------------
% [����]
% paramSet��   ȫ�ֲ�������
% daily_info�� ������Ƶ����
% volResidual: Beta���Ӽ����еõ��ĸ��ɲв����
% [���]
% expo��       �����������ӱ�¶��stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = ResidVolaFactorExpo(paramSet,daily_info,volResidual)

fprintf('����������(ResidVola)��¶�ȼ���');tic;

% ��������������
stockClose = daily_info.close_adj;
stockReturn = tick2ret(stockClose')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];
[stockNum,dayNum] = size(stockReturn);

% -------------------------------------------------------------------------
% ����������1��DASTD����ʷ�����ʣ����ü�Ȩ���㷽ʽ��
% -------------------------------------------------------------------------
% ��������
timeWinDASTD = paramSet.ResidVola.DASTD.timeWindow; 
halfLifeDASTD = paramSet.ResidVola.DASTD.halfLife; 
nanOpt = paramSet.ResidVola.nanOpt;

% ����Ȩ������
damplingDASTD = power(1/2,(timeWinDASTD:-1:1)/halfLifeDASTD); 
damplingDASTD = damplingDASTD/sum(damplingDASTD,nanOpt);      
                   
% ��ʼ��
DASTD = nan(stockNum,dayNum);                            

% ����ÿ������
for iDay = max(timeWinDASTD+1,paramSet.updateTBegin):1:dayNum         
    % ��������������
	returnList = stockReturn(:,(iDay-timeWinDASTD+1):iDay); 
    % ��Ȩ������
	DASTD(:,iDay) = std(returnList,damplingDASTD,2,nanOpt); 
end

% -------------------------------------------------------------------------
% ����������2��CMAR����ʷ�����ʵĲ������ȣ�
% -------------------------------------------------------------------------
% ��������
monthNumCMAR = paramSet.ResidVola.CMRA.timeWindow;                  
dayNumOfMonth = paramSet.ResidVola.CMRA.dayNumOfMonth;                
negaOpt = paramSet.ResidVola.negaOpt;     

% ���㴰��
timeWinCMRA = monthNumCMAR * dayNumOfMonth;                         

% ��ʼ��
CMRA = nan(stockNum,dayNum);                                 

% ����CMRA
for iDay = max(timeWinCMRA+1,paramSet.updateTBegin):dayNum  
    % ��ȡ�������ڵ���Ƶ�±�����
	mIndex = (iDay-timeWinCMRA):dayNumOfMonth:iDay; 
    %  1-T�µĶ��������ۻ�
	returnCumMonth = log(stockClose(:,mIndex(2:end))./stockClose(:,mIndex(1)));  
    % �ۻ��������� Z(T)<=-1 �ĸ�ֵ����
	returnCumMonth(returnCumMonth<=-1) = negaOpt;    
    % �����ۼ������ʵĲ�������
	CMRA(:,iDay) = log(1+max(returnCumMonth,[],2))-log(1+min(returnCumMonth,[],2)); 
end

% -------------------------------------------------------------------------
% ����������3��HSIGMA��Beta���Ӽ��������Իع�в���ı�׼�
% -------------------------------------------------------------------------
% HSIGMA
HSIGMA = volResidual;

% ��Ȩ�ϳ����ӱ�¶
weightDASTD = paramSet.ResidVola.DASTD.weight;                                 
weightCMRA = paramSet.ResidVola.CMRA.weight;                                  
weightHSIGMA = paramSet.ResidVola.HSIGMA.weight;       
expo = weightDASTD*DASTD + weightCMRA*CMRA + weightHSIGMA*HSIGMA;   

fprintf('  ��ʱ��%.4f��\n',toc);

end

