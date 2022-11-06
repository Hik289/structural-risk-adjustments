%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Weight Least Square ��Ԫ���Իع�
% --------------------------------------------
% ��������:
% varY - M * 1
% varX - M * (K+1)
% weight - M * 1
% ��ʾvarX�е�ǰK�У���weight��Ȩ�ض�varY���лع飻
% varX�ĵ�K+1��Ϊ���ⲹ���һ��M��1�е�ones����������WLS����
% --------------------------------------------
% ������ݣ�
% beta - ��K+1��*1
% ���һ��Ϊ��ϲв֮ǰ��K�ж�ӦX��ǰK�е�betaֵ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ beta ] = functionWLSmultiple(varY,varX,weight)
    % ��ʼ�����
    beta = nan(size(varX,2),1);
    
    if isnan(weight)
        weight=ones(size(varY));
    end
    
    % ȥ����Ϊ0����
    id_valid = sum(varX~=0)>0;
    varX = varX(:,id_valid);
    
    matrixWeight=diag(weight);
%     beta=(varX'*matrixWeight*varX)^-1*(varX'*matrixWeight*varY);
    % beta=(varX'*matrixWeight*varX)\(varX'*matrixWeight*varY);
    beta(id_valid)=(varX'*matrixWeight*varX)\(varX'*matrixWeight*varY);
end