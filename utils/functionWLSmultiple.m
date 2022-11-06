%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Weight Least Square 多元线性回归
% --------------------------------------------
% 输入数据:
% varY - M * 1
% varX - M * (K+1)
% weight - M * 1
% 表示varX中的前K列，以weight的权重对varY进行回归；
% varX的第K+1列为额外补充的一个M行1列的ones向量，用于WLS计算
% --------------------------------------------
% 输出数据：
% beta - （K+1）*1
% 最后一行为拟合残差，之前的K行对应X的前K列的beta值
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ beta ] = functionWLSmultiple(varY,varX,weight)
    % 初始化结果
    beta = nan(size(varX,2),1);
    
    if isnan(weight)
        weight=ones(size(varY));
    end
    
    % 去除均为0的列
    id_valid = sum(varX~=0)>0;
    varX = varX(:,id_valid);
    
    matrixWeight=diag(weight);
%     beta=(varX'*matrixWeight*varX)^-1*(varX'*matrixWeight*varY);
    % beta=(varX'*matrixWeight*varX)\(varX'*matrixWeight*varY);
    beta(id_valid)=(varX'*matrixWeight*varX)\(varX'*matrixWeight*varY);
end