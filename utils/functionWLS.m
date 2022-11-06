%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Weight Least Square
% varX varY weight �����Сһ�¡�ͨ��Ϊ1��N��
% -------------------------------------------------------------------------
% ʹ���Ż��㷨�����������ع������Ч��
% 1. VarY ������һ��M��N�ľ���
%       ���� VarX ��  VarY M�зֱ�������Իع�
%       ��ʱ beta , error Ϊ M��1 ������
%        beta , error�����е� m ���ʾ varX �� varY �ĵ� m �м�Ȩ�ع�Ľ����
% -------------------------------------------------------------------------
% ��ӵ��������˵�� -- ԭʼ���벻֧�ִ˹��ܣ����޸�(jwy 20190320)
% ��size(varY) Ϊ[M,N],��size(weight) Ϊ[K,N]ʱ
% ���beta,errorΪ[M,K]�ľ���
% ���е�m�У���k�е����ݱ�ʾvarX�ڵ�k�е�Ȩ���£���varY��m�е����ݻع顣
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ beta,error ] = functionWLS(varY,varX,weight)

    % ------------------------ begin: add by lic
    rStockWin = varY;
    rIndexWin = varX;
    weight1 = repmat(weight, size(rStockWin,1), 1);
    
    % ��������еĿ�ֵ��Ϊ�㣬������Ȩ������
    nanIndex = isnan(rIndexWin);
    rIndexWin(nanIndex) = 0;
    weight1(:,nanIndex) = 0;
    
    % ��������еĿ�ֵ��Ϊ�㣬������Ȩ������
    nanIndex = isnan(rStockWin);
    rStockWin(nanIndex) = 0;
    weight1(nanIndex) = 0;

    % ����WLS�ع������
    sumWeight1 = sum(weight1,2);                  
    weightVarY1 = rStockWin .* weight1;  
    sumWeightVarY1 = sum(weightVarY1,2);                   
    sumWeightVarX1 = weight1 * rIndexWin';
    meanVarX1 = sumWeightVarX1 ./ sumWeight1;       
    temp11 = weightVarY1*rIndexWin' - sumWeightVarY1.*meanVarX1;
    temp21 = weight1*rIndexWin.^2'-sumWeightVarX1.^2./sumWeight1;   
    beta1 = temp11 ./ temp21;
    error1 = sumWeightVarY1./sumWeight1 - beta1.*meanVarX1;
    
    % ------------------------ end: add by lic

    [lineNumY,~]=size(varY);
    if isnan(weight)                                    % �ж�weight ȷ���Ƿ����õ�Ȩ��
        [~,timeLength]=size(varY);
        weight=ones(1,timeLength);                      % Ĭ��size(weight)=[1,N]
    end
    [lineNumW,~]=size(weight);
    nanLocX=isnan(varX);
    varX(nanLocX)=0;                                    % varX��NANֵ����
    weight(:,nanLocX)=0;
    
    beta=nan(lineNumY,lineNumW);                        % ��ʼ�������beta��error��
    error=nan(lineNumY,lineNumW);

    if ~all(all(nanLocX))                               % �ж�varX���Ƿ���nan,������ǲż��㣬�Ա�����������쳣
        for iW=1:lineNumW
            newWeight=repmat(weight(iW,:),lineNumY,1);
            nanLocY=isnan(varY);
            newWeight(nanLocY)=0;                        % varY��NANֵ����
            varY(nanLocY)=0;
            
            sumWeight=sum(newWeight,2);                  % �м䲽�� �Ż���������ٶ�
            weightVarY=varY.*newWeight;                  % jwy:���� varY(M*N),newWeight((K*M)*N)
            sumWeightVarY=sum(weightVarY,2);                  % 
            sumWeightVarX=newWeight*varX';                   % 
            meanVarX=sumWeightVarX./sumWeight;         % �м䲽�� �Ż���������ٶ�
            
            temp1=weightVarY*varX'-sumWeightVarY.*meanVarX;
            temp2=newWeight*varX.^2'-sumWeightVarX.^2./sumWeight;
            beta(:,iW)=temp1./temp2;
            error(:,iW)=sumWeightVarY./sumWeight-beta.*meanVarX;
        end
    end
end
