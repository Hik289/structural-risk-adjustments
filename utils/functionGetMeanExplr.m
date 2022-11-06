%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �������ܣ������ӱ�¶ȱʧֵ�Ϊ��ҵ��ֵ������ҵ��Чֵ����������ΪNANʱ��ֱ����0
% --------------------------------
% ���룺
%    - factorExplr�����ӱ�¶���ݣ�stockNum * dayNum)
%    - industryFactorExpr����Ʊ������ҵ����1-29 ��stockNum * dayNum��
%    - stockFilter���ɽ��׹�Ʊ�ı�Ǿ��� ��stockNum * dayNum��
%    - paramFile�������ļ����ƣ���'param.mat'
% �����
%    - newFactorExplr��ȱʧֵ���������ӱ�¶���ݣ�stockNum * dayNum)
% -------------------------------
% ����汾����ƽ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newFactorExplr] = functionGetMeanExplr(paramSet,factorExplr,industryFactorExpr,stockFilter)
    % ����׼��
%     load(paramFile);
%     threshold=paraThresholdDataTooFew;                                      % ������paraFile����Ч�����������ޡ����ڸ�ֵʱ��nanֱ������Ϊ0
%     indusNum=paraIndustryNum;                                                % ������paraFile����ҵ��Ŀ
    [stockNum,dayNum]=size(factorExplr);                                    % ȷ������ - ��Ʊ������ - ����
    
    threshold = paramSet.global.thDataTooFew;
    indusNum = 30;

    factorExplr=factorExplr.*stockFilter;                                   % �����¶�ȼ����е���Ч��Ʊ
    
    newFactorExplr=factorExplr;                                             % ��ʼ�� newFactorExplr
    tempFactorExplr=nan(stockNum,dayNum);                                   % ��ʼ�� tempFactorExplr
    
    % ѭ������ÿ�����桢ÿ����ҵ�ı�¶�Ⱦ�ֵ
    for iterD=1:dayNum                              % ���� ѭ��
        for iterIndst=1:indusNum                    % ��ҵ ѭ��
            stockIterIndst=(industryFactorExpr(:,iterD)==iterIndst);                  % ȷ�����iterIndst����ҵ����Щ��
            stockNumIndst=sum(stockIterIndst);                              % ������ҵ���ж���ֻ��Ʊ
            tempMean=mean(factorExplr(stockIterIndst,iterD),'omitnan');     % ������ҵ��ֵ
            validDataNum=sum(~isnan(factorExplr(stockIterIndst,iterD)));    % �������ڼ����ֵ����Ч������(validDataNum)
            MEASURE = ( validDataNum > threshold );                         % ���жϲ�����ȷ���Ƿ���������Ϊ��ҵ��ֵ
            if  MEASURE                                                     % ȷ��validDataNum��Ŀ�Ƿ��㹻
                tempFactorExplr(stockIterIndst,iterD)=tempMean*ones(stockNumIndst,1);
            else
                tempFactorExplr(stockIterIndst,iterD)=zeros(stockNumIndst,1);
            end
        end
    end
    
    % �Ա�¶���е�NAN���и�ֵ
    badFactor=isnan(factorExplr);
    newFactorExplr(badFactor)=tempFactorExplr(badFactor);
    newFactorExplr=newFactorExplr.*stockFilter;
end