% -------------------------------------------------------------------------
% ���ӱ�¶���㣺����������
% -------------------------------------------------------------------------
% [����]
% paramSet��      ȫ�ֲ�������
% daily_info��    ������Ƶ���� 
% [���]
% expo��          ���������ӱ�¶��stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = LiquidityFactorExpo(paramSet,daily_info)

fprintf('����������(Liquidity)��¶�ȼ���');tic;

% ��ȡ����������
turn = daily_info.turn;

% ��Ʊά�Ⱥ�����ά��
[stockNum,dayNum] = size(turn);       

% -------------------------------------------------------------------------
% ϸ������1����ȥһ���µ�������(STOM)
% -------------------------------------------------------------------------
% һ���°���������
timeWin = paramSet.Liquidity.dayNumOfMonth;

% �Ƿ����ȱʧֵ
nanOpt = paramSet.Liquidity.nanOpt;

% ��ʼ��
STOM = nan(stockNum,dayNum);    

% ����STOM
for iDay = max(timeWin,paramSet.updateTBegin):dayNum
    % ���������ڻ������ۼ�ֵ
    kernal = mean(turn(:,(iDay+1-timeWin):iDay),2,nanOpt)*timeWin;  
    % ȡ����
    STOM(:,iDay) = log(kernal);                                          
end

% ����������Ϊ��ĳ���
STOM(STOM==-inf) = nan;

% -------------------------------------------------------------------------
% ϸ������2����ȥһ�����ȵ�������(STOQ)
% -------------------------------------------------------------------------
% һ�����Ȱ������·���
monthNumSTOQ = paramSet.Liquidity.STOQ.T;    

% ��Ӧ����Ƶ����
timeWinSTOQ = paramSet.Liquidity.dayNumOfMonth * monthNumSTOQ;

% ��ʼ��
STOQ = nan(stockNum,dayNum);                         

% ����STOQ
for iDay = max(timeWinSTOQ,paramSet.updateTBegin):dayNum
    % ���������ڻ������ۼ�ֵ
    kernal = mean(turn(:,(iDay+1-timeWinSTOQ):iDay),2,nanOpt)*timeWinSTOQ; 
    % ȡ����
    STOQ(:,iDay) = log(kernal/monthNumSTOQ);                                  
end

% ����������Ϊ��ĳ���
STOQ(STOQ==-inf) = nan;

% -------------------------------------------------------------------------
% ϸ������3����ȥһ���������(STOA)
% -------------------------------------------------------------------------
% һ��������·���
monthNumSTOA = paramSet.Liquidity.STOA.T; 

% ��Ӧ����Ƶ����
timeWinSTOA = paramSet.Liquidity.dayNumOfMonth * monthNumSTOA;

% ��ʼ��
STOA = nan(stockNum,dayNum);                         

% ����STOA
for iDay = max(timeWinSTOA,paramSet.updateTBegin):dayNum
    % ���������ڻ������ۼ�ֵ
    kernal = mean(turn(:,(iDay+1-timeWinSTOA):iDay),2,nanOpt)*timeWinSTOA; 
    % ȡ����
    STOA(:,iDay) = log(kernal/monthNumSTOA);                                  
end

% ����������Ϊ��ĳ���
STOA(STOA==-inf) = nan;

% ��Ȩ�ϳ����ӱ�¶
expo = paramSet.Liquidity.STOM.weight*STOM + ...
       paramSet.Liquidity.STOQ.weight*STOQ +...
       paramSet.Liquidity.STOA.weight*STOA;

fprintf('  ��ʱ��%.4f��\n',toc);

end