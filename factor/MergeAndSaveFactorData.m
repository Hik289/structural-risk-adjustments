% -------------------------------------------------------------------------
% ���������ּ������ͱ�����ʷ���ƴ��
% -------------------------------------------------------------------------
% [����]
% paramSet��        ȫ�ֲ�������
% factorExpoAdd��   ���ӱ�¶���ݣ�stockNum * factorNum * dayNum��
% factorReturnAdd�� ���������ʣ�factorNum * dayNum��
% specialReturnAdd�����������ʣ�stockNum * dayNum��
% [���]
% factorExpo��      ���ӱ�¶���ݣ�stockNum * factorNum * dayNum��
% factorReturn��    ���������ʣ�factorNum * dayNum��
% specialReturn��   ���������ʣ�stockNum * dayNum��
% -------------------------------------------------------------------------
function [factorExpo,factorReturn,specialReturn] = ...
    MergeAndSaveFactorData(paramSet,factorExpoAdd,factorReturnAdd,specialReturnAdd)

fprintf('ƴ�Ӽ�����');tic;

if paramSet.updateTBegin == 1 
    
    % ��ʼ��ģʽ
    factorExpo = single(factorExpoAdd);
    factorReturn = factorReturnAdd;
    specialReturn = specialReturnAdd;
    
else
    
    % ƴ�����ӱ�¶����
    factorExpo = importdata([paramSet.global.save_path 'factorExpo.mat']);
    [n_stocks_before,~,~] = size(factorExpo);
    [n_stocks_after,~,n_days_add] = size(factorExpoAdd);
    n_days_after = paramSet.updateTBegin - 1 + n_days_add;
    factorExpo(1:n_stocks_after,:,paramSet.updateTBegin:n_days_after) = factorExpoAdd(:,:,1:end);
    if n_stocks_before < n_stocks_after
        factorExpo(n_stocks_before+1:n_stocks_after,:,1:paramSet.updateTBegin-1) = nan;
    end
    
    % ƴ����������������
    factorReturn = importdata([paramSet.global.save_path 'factorReturn.mat']);
    firstValidCol = find(sum(~isnan(factorReturnAdd)),1,'first');
    factorReturn(:,paramSet.updateTBegin-1+firstValidCol:n_days_after) = factorReturnAdd(:,firstValidCol:end);
    
    % ƴ�Ӳв�������
    specialReturn = importdata([paramSet.global.save_path 'specialReturn.mat']);
    firstValidCol = find(sum(~isnan(specialReturnAdd)),1,'first');
    specialReturn(1:n_stocks_after,paramSet.updateTBegin-1+firstValidCol:n_days_after) = specialReturnAdd(:,firstValidCol:end);
    if n_stocks_before < n_stocks_after
        specialReturn(n_stocks_before+1:n_stocks_after,1:paramSet.updateTBegin) = nan;
    end
    
end

% ��ƴ�ӽ����ŵ�Ŀ��·��
save([paramSet.global.save_path 'factorExpo'], 'factorExpo','-v7.3');
save([paramSet.global.save_path 'factorReturn'], 'factorReturn');
save([paramSet.global.save_path 'specialReturn'], 'specialReturn');
    
fprintf('  ��ʱ��%.4f��\n',toc);

end
