% -------------------------------------------------------------------------
% ������ӱ�¶����������׼��
% -------------------------------------------------------------------------
% [����]
% paramSet��        ȫ�ֲ�������
% daily_info��      ������Ƶ����
% styleExpo:        ������ӱ�¶����
% indusExpo��       ��ҵ���ӱ�¶����stockNum * dayNum��
% validStockMatrix��������Ч״̬��ǣ�stockNum * dayNum��
% [���]
% processedExpo��   ����������׼��������ӱ�¶�ṹ��
% -------------------------------------------------------------------------
function processedExpo = FactorProcess(paramSet,daily_info,styleExpo,indusExpo,validStockMatrix)

fprintf('���ӱ�¶����������׼��');tic;

% ������ʼλ������
startLoc = paramSet.updateTBegin;

% ������ͨ��ֵ
floatCap = daily_info.close(:,startLoc:end) .* daily_info.float_a_shares(:,startLoc:end);

% �������ֵ��������
threshold = prctile(floatCap, paramSet.global.mktBlockRatio);
floatCap = min(floatCap,repmat(threshold,size(floatCap,1),1));  

% ���������ݰ��ո�����ʼ��ض�
styleExpo = structfun(@(x) x(:,startLoc:end),styleExpo,'UniformOutput',false);
indusExpo = indusExpo(:,startLoc:end);
validStockMatrix = validStockMatrix(:,startLoc:end);

% ���ӱ�׼������
styleExpo.size = Standardize(paramSet,styleExpo.size,floatCap,indusExpo,validStockMatrix);
styleExpo.beta = Standardize(paramSet,styleExpo.beta,floatCap,indusExpo,validStockMatrix);
styleExpo.momentum = Standardize(paramSet,styleExpo.momentum,floatCap,indusExpo,validStockMatrix);
styleExpo.nonLinear = Standardize(paramSet,styleExpo.nonLinear,floatCap,indusExpo,validStockMatrix);
styleExpo.booktoPrice = Standardize(paramSet,styleExpo.booktoPrice,floatCap,indusExpo,validStockMatrix);
styleExpo.earningYield = Standardize(paramSet,styleExpo.earningYield,floatCap,indusExpo,validStockMatrix);
styleExpo.growth = Standardize(paramSet,styleExpo.growth,floatCap,indusExpo,validStockMatrix);
styleExpo.leverage = Standardize(paramSet,styleExpo.leverage,floatCap,indusExpo,validStockMatrix);

% ���������ӶԹ�ģ��Beta������������Ȼ����б�׼��
baseFactor(:,:,1) = styleExpo.size;
baseFactor(:,:,2) = styleExpo.beta;
styleExpo.residVola = Orthogonalize(styleExpo.residVola,baseFactor,floatCap,validStockMatrix);
styleExpo.residVola = Standardize(paramSet,styleExpo.residVola,floatCap,indusExpo,validStockMatrix);

% ���������ӶԹ�ģ������������Ȼ���׼��
baseFactor = styleExpo.size;
styleExpo.liquidity = Orthogonalize(styleExpo.liquidity,baseFactor,floatCap,validStockMatrix);
styleExpo.liquidity = Standardize(paramSet,styleExpo.liquidity,floatCap,indusExpo,validStockMatrix);

% �������ս��
processedExpo = styleExpo;

fprintf('  ��ʱ��%.4f��\n',toc);


end