% -------------------------------------------------------------------------
% ���ӱ�¶���㣺��������
% -------------------------------------------------------------------------
% [����]
% paramSet��   ȫ�ֲ�������
% daily_info�� ������Ƶ����
% [���]
% expo��       �������ӱ�¶��stockNum * dayNum)
% -------------------------------------------------------------------------
function expo = MomentumFactorExpo(paramSet,daily_info)

fprintf('��������(Momentum)��¶�ȼ���');tic;

% ʱ�䴰��
timeWindow = paramSet.Mmnt.timeWindow;             

% ������������Ҫ�޳����һ������
lag = paramSet.Mmnt.lag;  

% ��˥�ڳ���
halfLifeDays = paramSet.Mmnt.halfLife;   

% ���ɶ�������������
stockReturn = tick2ret(daily_info.close_adj')';
stockReturn = [nan(size(stockReturn,1),1),stockReturn];
stockLogReturn = log(stockReturn+1);
stockLogReturnIsNaN = isnan(stockLogReturn);
stockLogReturn(stockLogReturnIsNaN) = 0;

% ��˥�ڼ�Ȩ����         
weightMatrix = CalcMovingWeightMatrix(stockLogReturn,timeWindow,halfLifeDays);

% �����Ȩ�������Ӽ�����
RSTR = nan(size(stockLogReturn));
RSTR(:,timeWindow+lag:end) = stockLogReturn * weightMatrix(:,1:end-lag);

% ��Ҫ����Чλ����Ϊnan������0ֵ���ܻᱻ������Ч�����ӱ�¶��
RSTRIsNaN = [true(size(stockReturn,1),timeWindow+lag-1),...
            (stockLogReturnIsNaN*weightMatrix(:,1:end-lag))>0];
RSTR(RSTRIsNaN) = nan;                                    

% ��Ȩ�ϳ����ӱ�¶
expo = paramSet.Mmnt.RSTR.weight * RSTR;

fprintf('  ��ʱ��%.4f��\n',toc);

end


