% -------------------------------------------------------------------------
% �������ܣ������ӱ�¶���ݽ�����λ��ȥ��ֵ��ȱʧֵ����ҵ��ֵ����׼������
% -------------------------------------------------------------------------
% [����]
% paramSet��        ȫ�ֲ�������
% oldExpo��         Ԥ����ǰ�����ӱ�¶���ݣ�stockNum * dayNum)
% floatCap��        ��ͨ��ֵ��stockNum * dayNum��
% indusFactorExpo�� ��ҵ���ӱ�¶����stockNum * dayNum��
% validStockMatrix��������Ч״̬��ǣ�stockNum * dayNum��
% [���]
% newExpo��         ��׼��������ӱ�¶���ݣ�stockNum * dayNum)
% -------------------------------------------------------------------------
function newExpo = Standardize(paramSet,oldExpo,floatCap,indusFactorExpo,validStockMatrix)

% ��ʼ�����
newExpo = oldExpo .* validStockMatrix;                                  
[stockNum,dayNum] = size(newExpo);                                     

% -------------------------------------------------------------------------
% ��λ��ȥ��ֵ
% -------------------------------------------------------------------------
% Z-scoreȥ��ֵ�е���ֵ(��λ���ı���)
thZscore = paramSet.global.thZscore;

% ����������ֵ�ļ���ֵ����Ϊ����ֵ
medianData = nanmedian(newExpo,1);
matrixMedianData = repmat(medianData,stockNum,1);
tempData = abs(newExpo-matrixMedianData);
mediaTempData = nanmedian(tempData,1);
matrixMedianTempData = repmat(mediaTempData,stockNum,1);
thresholdHMatrix = matrixMedianData + thZscore*matrixMedianTempData;
thresholdLMatrix = matrixMedianData - thZscore*matrixMedianTempData;
newExpo(newExpo>thresholdHMatrix) = thresholdHMatrix(newExpo>thresholdHMatrix); 
newExpo(newExpo<thresholdLMatrix) = thresholdLMatrix(newExpo<thresholdLMatrix); 

% -------------------------------------------------------------------------
% ���ȱʧֵ��������ҵ��ֵ��
% -------------------------------------------------------------------------
% ����ÿ����������ҵ�ڰ�������Ч���ݼ�����ҵ��ֵ
indusMean = nan(stockNum,dayNum); 
for iDay = 1:dayNum                              
    for iIndus = 1:paramSet.global.indusFactorNum    
        % ��ȡ��ǰ����������Ŀ����ҵ�ĸ��ɼ���
        includeStockIndex = (indusFactorExpo(:,iDay)==iIndus);    
        % ����Ŀ����ҵ���ж���ֻ��Ʊ
        includeStockNum = sum(includeStockIndex);      
        % ������Ч���ݵľ�ֵ
        tempMean = mean(newExpo(includeStockIndex,iDay),'omitnan');    
        % ������Ч���ݵĸ���
        validDataNum = sum(~isnan(newExpo(includeStockIndex,iDay)));    
        % ֻ�е���Ч�����㹻ʱ�Ž�ȱʧֵ���Ϊ��ҵ��ֵ������ֱ�����Ϊ0
        if  validDataNum > paramSet.global.thDataTooFew                                                     % ȷ��validDataNum��Ŀ�Ƿ��㹻
            indusMean(includeStockIndex,iDay) = tempMean*ones(includeStockNum,1);
        else
            indusMean(includeStockIndex,iDay) = zeros(includeStockNum,1);
        end
    end
end

% ���ȱʧֵ
nanIndex = isnan(newExpo);
newExpo(nanIndex) = indusMean(nanIndex);

% �ٴ���Ϊ��Ч���ݣ�������Щ��Ч�Ĺ�ƱҲ�������ҵ��ֵ�ˣ�
newExpo = newExpo .* validStockMatrix;

% -------------------------------------------------------------------------
% ���Ļ�����׼��
% -------------------------------------------------------------------------
% ���ݲ������þ����Ƿ����ֵ���п����Ŵ���
switch paramSet.global.capSqrtFlag
    case 0
        floatCap = floatCap.^1;
    case 1
        floatCap = floatCap.^0.5;
end

% ����Ч��Ʊ������ֵ��Ϊ��ֵ
floatCap(isnan(newExpo)) = nan;

% ����������ӱ�¶��ֵ����ֵ��Ȩ��
meanExpo = nansum(newExpo.*floatCap,1) ./ nansum(floatCap,1);       

% ���Ļ�
newExpo = newExpo - repmat(meanExpo,stockNum,1);

% ��׼��
newExpo = newExpo ./ repmat(nanstd(newExpo,1),stockNum,1);
    
end