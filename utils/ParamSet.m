% -------------------------------------------------------------------------
% ȫ�ֲ�������
% -------------------------------------------------------------------------
function param = ParamSet()

% -------------------------------------------------------------------------
% ȫ�ֲ���
% -------------------------------------------------------------------------
% ÿ�θ������ݺ󣬻������ж����죬����Ϊ-1�ͱ�ʾ��ʼ��ģʽ
param.global.backLength = -1;    

% ��ֵ��ȨȨ���Ƿ�ȡƽ������1-ȡ��0-��ȡ
param.global.capSqrtFlag = 1;           

% ��������ֵ��Ʊ��������λ��
param.global.mktBlockRatio = 95;     

% ȱʧֵ�����ҵ��ֵʱ����Ч����������
param.global.thDataTooFew = 0;    

% Z-scoreȥ��ֵ�е���ֵ(��λ���ı���)
param.global.thZscore = 3;         

% �м�������·��
param.global.save_path = '~/Desktop/matlab-barra����ģ��/result/';     

% ������ӡ���ҵ���ӡ��������Ӹ����������޸ĵĲ�����
param.global.styleFactorNum = 10;       
param.global.indusFactorNum = 30;       
param.global.countryFactorNum = 1;       

% -------------------------------------------------------------------------
% ���ӱ�¶������ز���
% -------------------------------------------------------------------------
% ��ģ���ӣ�Size��
param.Size.mrkCapType = 'total';             % 'total'-����ֵ��'float'-��ͨ��ֵ
param.Size.LNCAP.weight = 1.0;               % ϸ�����Ӻϳ�Ȩ�� 

% Beta���ӣ�Beta��
param.Beta.timeWindow = 252;                 % ʱ������ 
param.Beta.halfLife = 63;                    % ��˥�ڳ��� 
param.Beta.indexName = 'ZZQZ';               % �ع��׼
param.Beta.BETA.weight = 1.0;                % ϸ�����Ӻϳ�Ȩ�� 

% �������ӣ�Momentum��
param.Mmnt.timeWindow = 504;                 % ʱ������ 
param.Mmnt.halfLife = 126;                   % ��˥�ڳ��� 
param.Mmnt.lag = 21;                         % �޳���1һ�������� 
param.Mmnt.RSTR.weight = 1.0;                % ϸ�����Ӻϳ�Ȩ��

% �����ʣ�Residual Volatility��
param.ResidVola.nanOpt = 'omitnan';          % DASTD��HSIGMA�������Ƿ����nan��'omitnan'-����nan��'includenan'-������nan 
param.ResidVola.negaOpt = -0.99;             % CMRA�����У��ۻ�T�¶�������Z(T)<=-1ʱ�ĸ�ֵ���� 
param.ResidVola.indexName = '��֤ȫָ';      % �ع��׼
param.ResidVola.DASTD.timeWindow = 252;      % DASTD  ʱ������ 
param.ResidVola.DASTD.halfLife = 42;         % DASTD  Ȩ��ָ��˥���İ�˥�ڳ��� 
param.ResidVola.CMRA.timeWindow = 12;        % CMRA   ʱ������
param.ResidVola.CMRA.dayNumOfMonth = 21;     % CMRA   ���ʱ�����γ��� 
param.ResidVola.HSIGMA.timeWindow = 252;     % HSIGMA ʱ������
param.ResidVola.HSIGMA.halfLife = 63;        % HSIGMA Ȩ��ָ��˥���İ�˥�ڳ��� 
param.ResidVola.HSIGMA.regressWindow = 252;  % HSIGMA �ع����-ʱ�� 
param.ResidVola.HSIGMA.regressHalfLife = 63; % HSIGMA �ع����-��˥�� 
param.ResidVola.DASTD.weight = 0.74;         % DASTD  Ȩ��
param.ResidVola.CMRA.weight = 0.16;          % CMRA   Ȩ�� 
param.ResidVola.HSIGMA.weight = 0.10;        % HSIGMA Ȩ�� 

% �����Թ�ģ����(Non-linear Size)
param.NonLinear.NLSIZE.weight = 1;           % NLSIZEȨ�� 

% Book to Price
param.BktoPrc.rptFreq = 'annual';            % ʹ�òƱ����ͣ�'annual'-ֻʹ�������걨���ݣ�'quarterly'-ʹ�����µļ�Ƶ���� 
param.BktoPrc.mrkCapType = 'total';          % ��ֵ���ͣ�'total'-����ֵ��'float'-��ͨ��ֵ 
param.BktoPrc.BTOP.weight = 1.0;             % BTOP Ȩ��

% ������(Liquidity)
param.Liquidity.nanOpt = 'omitnan';          % �����ʼ������Ƿ����nan��'omitnan'-����nan��'includenan'-������nan  
param.Liquidity.dayNumOfMonth = 21;          % �����ʼ�������(��)���� 
param.Liquidity.STOQ.T=3;                    % STOQ �����ʼ����ʱ�䳤��(��) 
param.Liquidity.STOA.T=12;                   % STOA �����ʼ����ʱ�䳤��(��)
param.Liquidity.STOM.weight = 0.35;          % ���Ӻϳ��� STOM ��Ȩ�� 
param.Liquidity.STOQ.weight = 0.35;          % ���Ӻϳ��� STOQ ��Ȩ�� 
param.Liquidity.STOA.weight = 0.30;          % ���Ӻϳ��� STOA ��Ȩ�� 

% Earning Yield����
param.EarningYield.mrkCapType = 'total';     % CETOP��ETOP�е���ֵ���ͣ�'total'-����ֵ��'float'-��ͨ��ֵ 
param.EarningYield.rptFreq = 'quarterly';    % ʹ�òƱ����ͣ�'annual'-ֻʹ�������걨���ݣ�'quarterly'-ʹ�����µļ�Ƶ����  
param.EarningYield.EPFWD.weight = 0.68;      % ���Ӻϳ��� EPFWD ��Ȩ��(һ��Ԥ������,ʵ����ȥ) 
param.EarningYield.CETOP.weight = 0.21;      % ���Ӻϳ��� CETOP ��Ȩ��(ʵ��Ϊ0.21/(0.21+0.11)=0.66)  
param.EarningYield.ETOP.weight = 0.11;       % ���Ӻϳ��� ETOP ��Ȩ�� (ʵ��Ϊ0.11/(0.21+0.11)=0.34) 

% �ɳ�������(Growth)
param.Growth.negaOpt = 'abs';                % EGRO�����з�ĸΪ��ʱ�ĵ�����'abs'-��ĸȡ����ֵ��'nan'-��ĸ��nan 
param.Growth.yearWindow = 5;                 % ���������ĸ���������
param.Growth.EGRLF.weight = 0.18;            % ���Ӻϳ��� EGRLF ��Ȩ��(һ��Ԥ������,��ȥ) 
param.Growth.EGRSF.weight = 0.11;            % ���Ӻϳ��� EGRSF ��Ȩ��(һ��Ԥ������,��ȥ) 
param.Growth.EGRO.weight = 0.24;             % ���Ӻϳ��� EGRO ��Ȩ�� (ʵ��Ϊ0.24/(0.24+0.47)=0.34) 
param.Growth.SGRO.weight = 0.47;             % ���Ӻϳ��� SGRO ��Ȩ�� (ʵ��Ϊ0.47/(0.24+0.47)=0.66) 

% �ܸ����ӣ�Leverage��
param.Leverage.rptFreq = 'annual';           % ʹ�òƱ����ͣ�'annual'-ֻʹ�������걨���ݣ�'quarterly'-ʹ�����µļ�Ƶ���� 
param.Leverage.MLEV.weight = 0.38;           % ���Ӻϳ��� MLEV ��Ȩ�� 
param.Leverage.DTOA.weight = 0.35;           % ���Ӻϳ��� DTOA ��Ȩ�� 
param.Leverage.BLEV.weight = 0.27;           % ���Ӻϳ��� BLEV ��Ȩ�� 

% -------------------------------------------------------------------------
% Э������������ز���
% -------------------------------------------------------------------------
% ����Э������� Newey-West���� 
param.FactorCov.NW.tBegin = 1000;           % ����Э��������NW���� ����Ŀ�ʼ���� 
param.FactorCov.NW.timeWindow = 252;        % NW������ʱ������ 
param.FactorCov.NW.timeWindowS = 42;        % NW������ʱ�����ȣ���ʱ���� 
param.FactorCov.NW.halfLife = 90;           % NW�����У�ָ����Ȩ�İ�˥�� 
param.FactorCov.NW.dayNumOfMonth = 21;      % NW�����У�����Ϊ��Ƶ����ʹ�õı���,����ÿ������
param.FactorCov.NW.D = 2;                   % NW�����У���λ����صĴ�λ������� 

% ����Э������� ����ֵ����
param.FactorCov.EigenAdj.MCS = 3000;        % ���ؿ���ģ����� 
param.FactorCov.EigenAdj.timeWindow = 100;  % ����ֵ����ѡȡ��ʱ�䴰���� 
param.FactorCov.EigenAdj.A = 1.5;           % ���ڼ���β��������Ҫ��ģ�����ƫ����е��� 

% ����Э������� �����ʵ���
param.FactorCov.VolRegAdj.timeWin = 252;    % ������ƫ�������ʱ�䴰���� 
param.FactorCov.VolRegAdj.halfLife = 42;    % ������ƫ�������ָ����Ȩ�İ�˥�� 

% ������Э������� Newey-West����
param.SpecialCov.NW.tBegin = 1000;          % ������Э��������NW���� ����Ŀ�ʼ����
param.SpecialCov.NW.timeWindow = 252;       % NW������ʱ������ 
param.SpecialCov.NW.halfLife = 90;          % NW�����У�ָ����Ȩ�İ�˥�� 
param.SpecialCov.NW.dayNumOfMonth = 21;     % NW�����У�����Ϊ��Ƶ����ʹ�õı��� 
param.SpecialCov.NW.D = 5;                  % NW�����У���λ����صĴ�λ�������

% ������Э�������  �ṹ������
param.SpecialCov.StructAdj.timeWindow = 252;     % �ṹ�������У�ʱ�䴰���� 
param.SpecialCov.StructAdj.E0 = 1.05;            % ����E0�����ڵ����в��Ӱ�� 
param.SpecialCov.StructAdj.regressMode = 'WLS';  % 'WLS'-��ͨ��ֵ��Ȩ�ع飻'OLS'-��Ȩ�ع� 
param.SpecialCov.StructAdj.factorNum = 41;       % ������Ϊֻѡ������� 
                              
% ������Э������� ��Ҷ˹ѹ��
param.SpecialCov.BiasAdj.q = 1;                  % ��Ҷ˹ѹ���У�ϵ��q 
param.SpecialCov.BiasAdj.groupNum = 10;          % ��Ҷ˹ѹ���У���ֵ�������Ŀ
param.SpecialCov.BiasAdj.blockRatio = 95;        % ��ֵ��Ȩʱ������ֵ�����ķ�λ��

% ������Э������� �����ʵ���
param.SpecialCov.VolRegAdj.timeWindow = 252;     % �����ʵ��� ʱ�䴰
param.SpecialCov.VolRegAdj.halfLife = 42;        % �����ʵ��� ��˥��

% -------------------------------------------------------------------------
% �ز��������
% -------------------------------------------------------------------------
% �ز����ʼ�·�(��������Ԥ�������Ǵӵ�154�����濪ʼ��Ч�ģ���Ӧ2011-01-31)
param.beginMonth = 154;    

% �ز�Ľ����·�
param.endMonth = 273;      

% ���׵�������
param.fee = 0.002;

% ������ӡ���ҵ���ӡ��������Ӹ����������޸ĵĲ�����
param.styleFactorNum = 10;       
param.indusFactorNum = 30;       
param.countryFactorNum = 1;

% ������׼���ͣ�ԭʼָ��(net)��ȫ����ָ��(total)
% ����ָ����ǿʱ����ƽ���Ӧ�ñȶ�ȫ����ָ������Ϊ�ز��в��ø��ɸ�Ȩ�۸�
% �൱�ڷֺ���Ͷ���ˣ����Լ�����óɷֹ�Ȩ�ؽ��и���Ҳ����Ӯ����ָ��
param.baseType = 'net';

% -------------------------------------------------------------------------
% ��ҵģ��۵�������ز���
% -------------------------------------------------------------------------
% ����ģ��۵�ʱ�Ŀ��ࡢ������ҵ����
param.longIndusNum = 5;  
param.shortIndusNum = 5; 
param.unNeturalIndusNum = param.longIndusNum + param.shortIndusNum;  

% -------------------------------------------------------------------------
% �����Ż��������ص���ζ���
% -------------------------------------------------------------------------
% ��ָѡ�񣺻���300(HS300)����֤500(ZZ500)����֤800(ZZ800)
% ��֤1000�ĳɷֹ���Ч����̫����֤ȫָ��ȫ����ָ������̫��
param.targetIndex = 'HS300';  

% �������ϵ����ȡֵΪ���ʾ�������Թ滮��⣬������ι滮��⣨���к�����
param.lambda = 0;

% �������ϵ�������ڽ���ҵ�ֶ�Ԥ��۵�ֱ�ӵ��ӵ���������Ԥ����ȥ
% ʹ�õ������Ԥ������ʱ��betaΪ������ҵȨ�أ��������λΪX����׼��
% �������Ͻ�����������Ԥ�������Ϊ�Ǳ�׼��̫�ֲ�����ô��betaȡֵΪ1ʱ
% ������Ϊ��ҵ�۵�͸�������Ԥ��۵��Ȩ�أ����betaֵԽ����˵����ҵ
% �۵��������Խ�󣬷�֮��ԭ��������Ԥ�������Խ��
param.beta = 0;

% �Ƿ�Ŀ��ָ����ѡ�ɣ�1=�ǣ�0=�񣩣�������ȫA��������
param.selectInIndex = 0;   

% ����Ȩ��ƫ�����ƣ�Ҳ����������ڻ�׼���ƫ����٣�
param.stockWeightUpLimit = 0.01;   

% ����/������ҵ��ƫ�����ޡ�����
param.indusWeightUpLimit = 0.04;   
param.indusWeightDownLimit = 0.01;  

% ��ҵ�������ã�Ҳ��ƫ����ٷ�Χ����Ϊ����ҵ����
param.indusWeightNeutralLimit = 0.00;   

% ��ֵ�������ã�Ҳ��ƫ����ٷ�Χ����Ϊ����ֵ����
param.sizeFactorLimit = 0.0; 

end