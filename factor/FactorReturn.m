% -------------------------------------------------------------------------
% 1����������������
% 2����������ӡ���ҵ���ӡ��������ӱ�¶����
% -------------------------------------------------------------------------
% [����]
% paramSet��        ȫ�ֲ�������
% daily_info��      ������Ƶ����
% styleExpo:        ������ӱ�¶����
% indusExpo��       ��ҵ���ӱ�¶����stockNum * dayNum��
% validStockMatrix��������Ч״̬��ǣ�stockNum * dayNum��
% [���]
% factorReturn��    ���������ʼ�������factorNum * dayNum��
% factorExpo��      ���ӱ�¶���ܽ����stockNum * factorNum * dayNum��
% -------------------------------------------------------------------------
function [factorReturn,factorExpo] = FactorReturn(paramSet,daily_info,styleExpo,indusExpo,validStockMatrix)

fprintf('���������ʼ���');tic;

% �ض�����
validStockMatrix = validStockMatrix(:,paramSet.updateTBegin:end);
indusExpo = double(indusExpo(:,paramSet.updateTBegin:end));
indusExpo = indusExpo .* validStockMatrix;

% ����������Ŀ
styleNum = paramSet.global.styleFactorNum;
indusNum = paramSet.global.indusFactorNum;
countryNum = paramSet.global.countryFactorNum;
factorNum = styleNum + indusNum + countryNum;                 

% ���ɵ�����������
stockReturn = tick2ret(daily_info.close_adj')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];
stockReturn = stockReturn(:,paramSet.updateTBegin:end) .* validStockMatrix;
[stockNum,dayNum] = size(stockReturn);

% Ȩ������
weightCap = daily_info.close(:,paramSet.updateTBegin:end) .* daily_info.float_a_shares(:,paramSet.updateTBegin:end);
threshold = prctile(weightCap, paramSet.global.mktBlockRatio);
weightCap = min(weightCap,repmat(threshold,size(weightCap,1),1)); 
weightCap(isnan(weightCap)) = 0;                           

% ��ʼ�����
factorReturn = nan(factorNum,dayNum);                        
factorExpo = nan(stockNum,factorNum,dayNum);

% ����ÿ������
for iDay = 1:dayNum
    
    % ��ȡ�����ϵķ�����ӱ�¶
    panelStyleExpo = [styleExpo.size(:,iDay),styleExpo.beta(:,iDay),...
                styleExpo.momentum(:,iDay),styleExpo.residVola(:,iDay),...
                styleExpo.nonLinear(:,iDay),styleExpo.booktoPrice(:,iDay),...
                styleExpo.liquidity(:,iDay),styleExpo.earningYield(:,iDay),...
                styleExpo.growth(:,iDay),styleExpo.leverage(:,iDay)]; 
    
    % ��ȡ��ҵ�����Ʊ�������  
    panelIndusExpo = indusExpo(:,iDay);
    panelIndusExpo(isnan(panelIndusExpo)) = indusNum+1;
    panelIndusExpo = dummyvar(panelIndusExpo);
    panelIndusExpo = panelIndusExpo(:,1:indusNum);
%     % ��ʱ��������ΪĿǰ������������ҵ����������Ч���ݣ������������˹�����
%     % ����ǰ����ҵ����ֻ��29��ʱ���ᵼ�±߽��ȡ�����������������жϣ�δ
%     % �������ҵ�ײ���������滻���޼ӹ��汾�������ϾͲ���Ҫ��������ж���
%     if size(panelIndusExpo,2) < indusNum
%         panelIndusExpo = [panelIndusExpo,zeros(stockNum,1)];
%     else
%         panelIndusExpo = panelIndusExpo(:,1:indusNum);
%     end
    
    % �������ӱ�¶���
    factorExpo(:,:,iDay) = [panelStyleExpo, panelIndusExpo, ones(stockNum,1)];
    
    % ����һ������ӱ�¶�Ѿ��޷�����������
    if iDay == dayNum
        continue;
    end
    
    % ��ȡ�����Ʊ�����ʣ�ע������T�����Ӷ�T+1�������ʻع飩
    panelReturn = stockReturn(:,iDay+1);
    
    % ��ȡ���������ݵĸ��ɣ����¶����ҵ��¶����Ʊ�����ʾ�Ϊ��Чֵ��
    lineNoNan = ~isnan(sum([panelReturn,panelStyleExpo,panelIndusExpo],2));
    if sum(lineNoNan)==0
        continue;                                                       
    end
    
    % ��ȡ��Ч�Ļع��Ա������������Ȩ��
    Y = panelReturn(lineNoNan);
    X = [panelStyleExpo,panelIndusExpo]; X = X(lineNoNan,:);
    w = weightCap(lineNoNan,iDay);
    
    % �ع�ϵ�����ƣ�ע����Ҫ�޳�ȫ���У���Ϊ��ҵ�������ֹ������    
    beta = nan(size(X,2),1);
    validCol = sum(X~=0) > 0;
    X = X(:,validCol);
    beta(validCol) = (X' * diag(w) * X) \ (X' * diag(w) * Y);
       
    % �������������ֱ��ȡ�ع���   
    styleReturn = beta(1:styleNum);   
    
    % ������������������ҵ���������ʵ���ֵ��Ȩ
    indusWeight = w' * panelIndusExpo(lineNoNan,:);                
    indusReturn = beta((1+styleNum):(indusNum+styleNum));        
    countryReturn = nansum( indusReturn .* indusWeight') / ...
                    nansum((~isnan(indusReturn)) .* indusWeight');     
    
    % ��ҵ��������������ԭ�������ϼ�ȥ��������������
    indusReturn = indusReturn - countryReturn;   
    
    % �����ֵ��ע������洢���±���T+1�գ�Ҳ������T�����ӱ�¶��T+1��������
    % �õ��Ļع����Ǵ���T+1�գ�������֤û������δ����Ϣ
    factorReturn(:,iDay+1) = [styleReturn;indusReturn;countryReturn];   
         
end

fprintf('  ��ʱ��%.4f��\n',toc);

end
