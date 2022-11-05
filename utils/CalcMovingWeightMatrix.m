% -------------------------------------------------------------------------
% 根据半衰期计算移动加权矩阵，该函数可以去除for循环，提高效率
% -------------------------------------------------------------------------
% [输入]
% dataMatrix：待加权矩阵（stockNum * dayNum）
% timeWin:    数据时窗长度，也即加权权重向量的长度
% halfLife:   指数衰减的半衰期，决定权重衰减的快慢，不输入则表示等权
% [输出]
% weightMatrix：加权矩阵（dayNum * dayNum-timeWin+1），其结构如下
% 
% w1  0   0   0
% w2  w1  0   0
% w3  w2  w1  0
% 0   w3  w2  w1
% 0   0   w3  w2
% 0   0   0   w3
% -------------------------------------------------------------------------
function weightMatrix = CalcMovingWeightMatrix(dataMatrix,timeWin,halfLife)

% 获取股票数，数据天数
[~,dayNum]=size(dataMatrix);   

% 计算权重向量
if nargin < 3                              
    weight = ones(1,timeWin);                        
else
    weight = power(1/2,(timeWin:-1:1)/halfLife);      
end

% 先生成一维向量
zeroInterval = zeros(1,dayNum-timeWin+1);
tempWghtMtr = repmat([weight,zeroInterval],1,dayNum-timeWin);
tempWghtMtr = [tempWghtMtr,weight];

% 将向量重塑为矩阵
weightMatrix = reshape(tempWghtMtr,dayNum,dayNum-timeWin+1);

% 归一化
weightMatrix = weightMatrix./sum(weightMatrix);

end