% -------------------------------------------------------------------------
% �������ܣ���Ŀ�����ӶԻ�׼���ӣ�1������������ͨ��ֵ��Ȩ������
% �㷨�������裺
% targetFactor[] = resultFactor[]+beta*baseFactor[]+error
% ����resultFactor��������������ӱ�¶����baseFactor��ȫ�������������
% -------------------------------------------------------------------------
% [����]
% targetFactor ��   ���������ӵ����ӱ�¶��stockNum * dayNum)
% baseFactor��      ���������ӵ����ӱ�¶���ϣ�stockNum * dayNum * factorNum)
% weight��          ��Ȩ��С����Ȩ�أ�stockNum * dayNum)
% validStockMatrix���ɽ��׹�Ʊ�ı�Ǿ��� ��stockNum * dayNum��
% [���]
% resultFactor��    ������������Ϊ�µ����ӱ�¶ֵ��stockNum * dayNum)
% -------------------------------------------------------------------------
function resultFactor = Orthogonalize(targetFactor,baseFactor,weight,validStockMatrix)
    
% ��ȡ��Ч���ӱ�¶
targetFactor = targetFactor .* validStockMatrix;

% ��ȡ��Ʊά��������ά��
[stockNum,dayNum] = size(targetFactor);

% ��ʼ�����
resultFactor = nan(size(targetFactor));

% ����ÿ������
for iDay = 1:1:dayNum
    % �Ա������������Ȩ��
    Y = targetFactor(:,iDay);
    X = squeeze(baseFactor(:,iDay,:));
    w = weight(:,iDay);
    % ��������ֵ����Ч������
    validStock = ~isnan(sum([Y,X,w],2));
    validY = Y(validStock,:);
    validX = X(validStock,:);
    validW = w(validStock,:);
    % ֱ�ӻ��ڽ�����õ��ع�ϵ������
    tmpX = [validX,ones(size(validX,1),1)];
    tmpW = diag(validW);
    ret = (tmpX'*tmpW*tmpX)\(tmpX'*tmpW*validY);
    beta = ret(1:end-1);  alpha = ret(end);
    resultFactor(:,iDay) = Y-X*beta-ones(stockNum,1)*alpha;
end

end