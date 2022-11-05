% -------------------------------------------------------------------------
% ���ӱ�¶���㣺��ģ���ӣ�Size��
% ���ڹ�ģ���Ӽ����ٶȽϿ죬����ÿ�ζ���ȫ�����¼���һ��
% -------------------------------------------------------------------------
% [����]
% paramSet��  ȫ�ֲ�������
% daily_info��������Ƶ����
% [���]
% expo��      Size���ӱ�¶��stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = SizeFactorExpo(paramSet,daily_info)

fprintf('��ģ����(Size)��¶�ȼ���');tic;

% ��Ʊԭʼ���̼ۣ�����Ȩ��
closePrice = daily_info.close;        

% �����Ʊ��ֵ��֧������ֵ����ͨ��ֵ�����ھ���
switch paramSet.Size.mrkCapType
    case 'total'
        TMC = closePrice .* daily_info.total_shares;  
    case 'float'
        TMC = closePrice .* daily_info.float_a_shares;  
end

% ����LNCAP����
TMC(TMC<1)=nan;                     
LNCAP=log(TMC);                       

% ��Ȩ�ϳ����ӱ�¶
expo = paramSet.Size.LNCAP.weight * LNCAP;

fprintf('  ��ʱ��%.4f��\n',toc);

end