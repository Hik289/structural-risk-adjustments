% -------------------------------------------------------------------------
% ���ӱ�¶���㣺Beta����
% -------------------------------------------------------------------------
% [����]
% paramSet��   ȫ�ֲ�������
% daily_info�� ������Ƶ����
% index_info�� ��׼ָ�������Ϣ
% [���]
% expo��       Beta���ӱ�¶��stockNum * dayNum)
% volResidual���в���ʣ�stockNum * dayNum)�����ڼ��㲨��������
% -------------------------------------------------------------------------
function [expo,volResidual] = BetaFactorExpo(paramSet,daily_info,index_info)

fprintf('BETA����(Beta)��¶�ȼ���');tic;

% ʱ������
timeWindow = paramSet.Beta.timeWindow;                   

% Ȩ��ָ��˥���İ�˥��
halfLifeDays = paramSet.Beta.halfLife;   

% Ȩ������
dampling = power(1/2,(timeWindow:-1:1)/halfLifeDays);         

% ���ɵ�����������
stockReturn = tick2ret(daily_info.close_adj')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];
[stockNum,dayNum] = size(stockReturn);

% Ŀ��ָ��������������
indexClose = getfield(getfield(index_info,paramSet.Beta.indexName),'close');
indexReturn = [nan,tick2ret(indexClose')'];

% ��ʼ��                         
beta = nan(stockNum,dayNum);                           
alpha = nan(stockNum,dayNum);                                
volResidual = nan(stockNum,dayNum);                   

% ��������ֵ
for iDay = max(timeWindow+1,paramSet.updateTBegin):1:dayNum 
    
    % ��ȡ�������ڵĸ��������ʡ�ָ�������ʡ�Ȩ������
    rStockWin = stockReturn(:,iDay-timeWindow+1:1:iDay);
    rIndexWin = indexReturn(iDay-timeWindow+1:1:iDay);
    weight = repmat(dampling, stockNum, 1);
    
    % ��������еĿ�ֵ��Ϊ�㣬������Ȩ������
    nanIndex = isnan(rIndexWin);
    rIndexWin(nanIndex) = 0;
    weight(:,nanIndex) = 0;
    
    % ��������еĿ�ֵ��Ϊ�㣬������Ȩ������
    nanIndex = isnan(rStockWin);
    rStockWin(nanIndex) = 0;
    weight(nanIndex) = 0;

    % ����WLS�ع������
    sumWeight = sum(weight,2);                  
    weightVarY = rStockWin .* weight;  
    sumWeightVarY = sum(weightVarY,2);                   
    sumWeightVarX = weight * rIndexWin';
    meanVarX = sumWeightVarX ./ sumWeight;       
    temp1 = weightVarY*rIndexWin' - sumWeightVarY.*meanVarX;
    temp2 = weight*rIndexWin.^2'-sumWeightVarX.^2./sumWeight;   
    beta(:,iDay) = temp1 ./ temp2;
    alpha(:,iDay) = sumWeightVarY./sumWeight - beta(:,iDay).*meanVarX;
    
    % ����в���ʣ��������������Ӽ�������Ҫ�õ�
    betaResidual = rStockWin-beta(:,iDay)*rIndexWin-repmat(alpha(:,iDay),[1,timeWindow]);
    volResidual(:,iDay) = std(betaResidual,dampling,2,'omitnan'); 
    
end

% ��Ȩ�ϳ����ӱ�¶
expo = paramSet.Beta.BETA.weight * beta;

fprintf('  ��ʱ��%.4f��\n',toc);

end



