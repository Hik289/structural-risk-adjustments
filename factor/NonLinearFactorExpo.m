% -------------------------------------------------------------------------
% ���ӱ�¶���㣺�����Թ�ģ����
% -------------------------------------------------------------------------
% [����]
% paramSet��        ȫ�ֲ�������
% daily_info��      ������Ƶ����
% sizeFactorExpo:   ��ģ���ӱ�¶����stockNum * dayNum��
% indusFactorExpo�� ��ҵ���ӱ�¶����stockNum * dayNum��
% validStockMatrix��������Ч״̬��ǣ�stockNum * dayNum��
% [���]
% expo��       �����Թ�ģ���ӱ�¶��stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = NonLinearFactorExpo(paramSet,daily_info,sizeFactorExpo,indusFactorExpo,validStockMatrix)

fprintf('�����Թ�ģ����(NonLinear)��¶�ȼ���');tic;

% ������ͨ��ֵ
floatCap = daily_info.close .* daily_info.float_a_shares;

% �������ֵ��������
threshold = prctile(floatCap,paramSet.global.mktBlockRatio);
floatCap = min(floatCap,repmat(threshold,size(floatCap,1),1));  

% �����׼������ֵ���ӱ�¶
standSizeFactorExpo = Standardize(paramSet,sizeFactorExpo,floatCap,indusFactorExpo,validStockMatrix);

% ����ģ���ӵ����η��Թ�ģ����������ȡ�в���Ϊ�����Թ�ģ����
targetFactor = power(standSizeFactorExpo,3);
baseFactor = standSizeFactorExpo;
NLSIZE = Orthogonalize(targetFactor,baseFactor,floatCap,validStockMatrix);
    
% ��Ȩ�ϳ����ӱ�¶
expo = paramSet.NonLinear.NLSIZE.weight * NLSIZE;

fprintf('  ��ʱ��%.4f��\n',toc);

end