% -------------------------------------------------------------------------
% �в�Э���������ƫ�������ȫ�����У�
% -------------------------------------------------------------------------
% [����]
% paramSet��           ȫ�ֲ�������
% daily_info��         ��Ƶ���ݼ���
% specialCovBiasAdj��  ��Ҷ˹ѹ��������Ĳв�Э���stockNum * dayNum��
% specialReturn��      �в����������У�stockNum * dayNum��
% [���]
% specialCovVolRegAdj���в�Э������ƣ�stockNum * dayNum)
% lambdaSall��         ���첨���ʵ���ϵ����1 * dayNum��
% CSVSt��              ���������Բ����ʣ�1 * dayNum��
% -------------------------------------------------------------------------
function [specialCovVolRegAdj,lambdaSall,CSVSt] = SpecialCovVolRegAdj(...
        paramSet,daily_info,specialCovBiasAdj,specialReturn)

fprintf('�в�Э�������Ҷ˹ѹ������');tic;

% ����׼��
timeWin = paramSet.SpecialCov.VolRegAdj.timeWindow;             
halfLife = paramSet.SpecialCov.VolRegAdj.halfLife;             
[stockNum,dayNum] = size(specialCovBiasAdj);

% ��˥��Ȩ��
weight = power(0.5,(timeWin:-1:1)/halfLife);  

% ��ֵ����
weightCap = daily_info.close .* daily_info.float_a_shares;
threshold = prctile(weightCap,paramSet.global.mktBlockRatio);
weightCap = min(weightCap,repmat(threshold,size(weightCap,1),1));  
switch paramSet.global.capSqrtFlag
    case 0
        weightCap = weightCap.^1;
    case 1
        weightCap = weightCap.^0.5;
end

% ����������������ȥ��ֵ
returnDay = specialReturn;                          
maxNum = 3;
tempMatrix = maxNum * repmat((nanstd((returnDay')))',[1,dayNum]);
returnDay(returnDay>tempMatrix) = tempMatrix(returnDay>tempMatrix);
tempMatrix = -maxNum*repmat((nanstd((returnDay')))',[1,dayNum]);
returnDay(returnDay<tempMatrix) = tempMatrix(returnDay<tempMatrix);
logReturnDay = log(returnDay+1);

% �����¶�����
logReturnMonth = nan(stockNum,dayNum);
for iDay = 1:dayNum-21+1
    logReturnMonth(:,iDay) = sum(logReturnDay(:,iDay:(iDay+21-1)),2);
end
returnMonth = exp(logReturnMonth) - 1;

% ��ʼ�����
specialCovVolRegAdj = nan(stockNum,dayNum);
lambdaSall = nan(1,dayNum);

% ������ƫ�����                      
returnToSSigma = returnMonth.^2 ./ specialCovBiasAdj.^2;                
returnToSSigma(returnToSSigma==inf) = nan;                                     
tempMarketValue = weightCap;
tempMarketValue(isnan(returnToSSigma)) = 0;
sumMarketValue = sum(tempMarketValue,1,'omitnan');                        
marketValueWeight = tempMarketValue ./ repmat(sumMarketValue,[stockNum,1]);  
% marketValueWeight = weightCap ./ repmat(sumMarketValue,[stockNum,1]); 
marketValueWeight(marketValueWeight==inf) = nan;
returnToSpcSig = sum(marketValueWeight.*returnToSSigma,'omitnan');
for iDay = timeWin:dayNum
    % ���ʲ����ʵ���ϵ��
    data = returnToSpcSig(iDay-timeWin+1:iDay);
    lambdaSall(iDay) = nansum(data.*weight,2) ./ sum(weight(~isnan(data)));
    % ���ʲ����ʵ���
    specialCovVolRegAdj(:,iDay) = lambdaSall(iDay)^0.5 * specialCovBiasAdj(:,iDay); 
end
specialCovVolRegAdj(specialCovVolRegAdj==0) = nan;

% �������ʲ�����
goodDataReturn = isnan(returnDay+weightCap);
returnDay(goodDataReturn) = nan;
weightCap(goodDataReturn) = nan;
weightCap = weightCap./repmat(nansum(weightCap),[stockNum,1]);
CSVSt = sqrt(nansum(returnDay.^2 .* weightCap));

fprintf('  ��ʱ��%.4f��\n',toc);

end