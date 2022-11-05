% -------------------------------------------------------------------------
% ���ݰ�˥�ڼ����ƶ���Ȩ���󣬸ú�������ȥ��forѭ�������Ч��
% -------------------------------------------------------------------------
% [����]
% dataMatrix������Ȩ����stockNum * dayNum��
% timeWin:    ����ʱ�����ȣ�Ҳ����ȨȨ�������ĳ���
% halfLife:   ָ��˥���İ�˥�ڣ�����Ȩ��˥���Ŀ��������������ʾ��Ȩ
% [���]
% weightMatrix����Ȩ����dayNum * dayNum-timeWin+1������ṹ����
% 
% w1  0   0   0
% w2  w1  0   0
% w3  w2  w1  0
% 0   w3  w2  w1
% 0   0   w3  w2
% 0   0   0   w3
% -------------------------------------------------------------------------
function weightMatrix = CalcMovingWeightMatrix(dataMatrix,timeWin,halfLife)

% ��ȡ��Ʊ������������
[~,dayNum]=size(dataMatrix);   

% ����Ȩ������
if nargin < 3                              
    weight = ones(1,timeWin);                        
else
    weight = power(1/2,(timeWin:-1:1)/halfLife);      
end

% ������һά����
zeroInterval = zeros(1,dayNum-timeWin+1);
tempWghtMtr = repmat([weight,zeroInterval],1,dayNum-timeWin);
tempWghtMtr = [tempWghtMtr,weight];

% ����������Ϊ����
weightMatrix = reshape(tempWghtMtr,dayNum,dayNum-timeWin+1);

% ��һ��
weightMatrix = weightMatrix./sum(weightMatrix);

end