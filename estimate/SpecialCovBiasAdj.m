% -------------------------------------------------------------------------
% �в�Э�����Ҷ˹ѹ��������ȫ�����У�
% -------------------------------------------------------------------------
% [����]
% paramSet��           ȫ�ֲ�������
% daily_info��         ��Ƶ���ݼ���
% specialCovStructAdj���ṹ��������Ĳв�Э���stockNum * dayNum��
% [���]
% specialCovBiasAdj��  �в�Э������ƣ�stockNum * dayNum)
% -------------------------------------------------------------------------
function specialCovBiasAdj = SpecialCovBiasAdj(paramSet,daily_info,specialCovStructAdj)

fprintf('�в�Э�������Ҷ˹ѹ������');tic;

% ����׼��
q = paramSet.SpecialCov.BiasAdj.q;                                                
groupNum = paramSet.SpecialCov.BiasAdj.groupNum;                                  
blockRatio = paramSet.SpecialCov.BiasAdj.blockRatio;                                       
[~,dayNum] = size(specialCovStructAdj);

% ��ֵ����
weightCap = daily_info.close .* daily_info.float_a_shares;
threshold = prctile(weightCap,blockRatio);
weightCap = min(weightCap,repmat(threshold,size(weightCap,1),1));  
switch paramSet.global.capSqrtFlag
    case 0
        weightCap = weightCap.^1;
    case 1
        weightCap = weightCap.^0.5;
end

% ��ʼ�����
specialCovBiasAdj = specialCovStructAdj;  

% ��Ҷ˹ѹ������
for iDay = 1:dayNum
    
    % ����ÿ�����������ֵ
    panelW = weightCap(:,iDay);
    thresholdV = nan(1,groupNum+1); 
    thresholdV(1) = min(panelW)-1;                        	
    thresholdV(groupNum+1) = max(panelW)+1;                   
    for groupTh = 2:groupNum
        thresholdV(groupTh) = prctile(panelW,100*(groupTh-1)/groupNum); 
    end
    
    % ��ÿ��������д���
    for iGroup = 1:groupNum
        % ѡ��ĳ�������ڵ���Ч��Ʊ
        stockIn = (panelW>thresholdV(iGroup)) &(panelW<thresholdV(iGroup+1));                
        noNanLines = ~isnan(sum([panelW,specialCovStructAdj(:,iDay)],2));
        goodLines = (stockIn & noNanLines);
        % ����ÿ����ϵ���ֵ��Ȩ�����ʾ�ֵ
        sigmaMean = sum(weightCap(goodLines,iDay).*specialCovStructAdj(goodLines,iDay))/sum(weightCap(goodLines,iDay));                         
        if isnan(sigmaMean)
            continue;
        end
        % ��Ʊ������������ʲ����ʵı�׼��
        DeltaS = (nansum((specialCovStructAdj(goodLines,iDay)-sigmaMean).^2)/sum(goodLines))^0.5;   
        % ��Ʊ���ʲ����ʺͷ����Ȩ��ֵ��ƫ���
        offset = q * abs(specialCovStructAdj(stockIn,iDay)-sigmaMean);    
        % ѹ���ܶ�
        Vn = offset ./ (DeltaS+offset);                                     
        % ������ڼ�Ȩƽ��ֵѹ��
        specialCovBiasAdj(stockIn,iDay) = Vn*sigmaMean+(1-Vn).*specialCovStructAdj(stockIn,iDay); 
    end
    
end
specialCovBiasAdj(specialCovBiasAdj==0) = nan;
    
fprintf('  ��ʱ��%.4f��\n',toc);

end