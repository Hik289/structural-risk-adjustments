% -------------------------------------------------------------------------
% �����ӷ���ģ�͵�һ�����������ӱ�¶�����������ʡ�����������
%  1) Ĭ�ϲ�����������ģʽ�����ݴ���Ϊ ParamSet.backLength ����
%     һ��Ӧ�ó���Ϊ�¶ȸ��£�����Ĭ�ϻ��ݳ���Ϊ23��������
%  2) ������ͷ��ʼ���У����Խ� ParamSet.backLength ����Ϊ-1
% -------------------------------------------------------------------------
clear; clc; close all;
addpath(genpath(pwd));
addpath('utils');   % ��Ź�������
addpath('factor');  % ������ӱ�¶������غ���
dbstop if error     % �������г���ʱͣ���ڳ���λ��

% -------------------------------------------------------------------------
% ����׼������������
% -------------------------------------------------------------------------
% ��ȡ��Ʊ������Ϣ����Ƶ��Ϣ����Ƶ��Ϣ����Ƶ��Ϣ
load('data/stock_data','basic_info','daily_info','monthly_info','quarterly_info');

% ��ȡ��׼ָ������
load('data/index_data');

% ����ȫ�ֲ���
paramSet =  ParamSet();

% ��ȡ������ʼ������֧�ִ�ͷ��ʼ���У�Ҳ֧����������ģʽ��
paramSet.updateTBegin = CalcUpdateTBegin(paramSet,daily_info);

% �ֱ��ȡÿ���������ܿ����������걨�����¼���λ������
useQuarterLoc.annual = CalcUseQuarterLoc(daily_info,quarterly_info,'annual');
useQuarterLoc.quarterly = CalcUseQuarterLoc(daily_info,quarterly_info,'quarterly');

% ��ȡ��Ч��Ʊ��ǣ��޳�δ���С������С�ͣ�ơ��޽��׵������
validStockMatrix = CalcValidStockMatrix(basic_info,daily_info);

% -------------------------------------------------------------------------
% �������ӱ�¶
% -------------------------------------------------------------------------
% ������ҵ���ӱ�¶��ֱ�ӻ�ȡ���ش洢�������
indusExpo = daily_info.cs_indus_code;

% �����ģ���ӱ�¶
styleExpo.size = SizeFactorExpo(paramSet,daily_info);

% ����Beta���ӱ�¶
[styleExpo.beta,volResidual] = BetaFactorExpo(paramSet,daily_info,index_data);

% ���㶯�����ӱ�¶
styleExpo.momentum = MomentumFactorExpo(paramSet,daily_info);

% ���㲨�������ӱ�¶
styleExpo.residVola = ResidVolaFactorExpo(paramSet,daily_info,volResidual);

% ��������Թ�ģ���ӱ�¶
styleExpo.nonLinear = NonLinearFactorExpo(paramSet,daily_info,styleExpo.size,indusExpo,validStockMatrix);

% ����������ֵ�����ӱ�¶
styleExpo.booktoPrice = BooktoPriceFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc);

% �������������ӱ�¶
styleExpo.liquidity = LiquidityFactorExpo(paramSet,daily_info);

% ����ӯ�����ӱ�¶
styleExpo.earningYield = EarningYieldFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc);

% ����ɳ����ӱ�¶
styleExpo.growth = GrowthFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc);

% ����ܸ����ӱ�¶
styleExpo.leverage = LeverageFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc);

% ���ӱ�¶�������������������²��֣�
styleExpo = FactorProcess(paramSet,daily_info,styleExpo,indusExpo,validStockMatrix);

% -------------------------------------------------------------------------
% ���������ʡ��в������ʼ���
% -------------------------------------------------------------------------
% �������������ʺ����ӱ�¶�������������²��֣�
[factorReturn,factorExpo] = FactorReturn(paramSet,daily_info,styleExpo,indusExpo,validStockMatrix);

% ����в������ʣ������������֣�
specialReturn = SpecialReturn(paramSet,daily_info,factorExpo,factorReturn);

% �����Ч��������ֹ�ڴ汨��
clear styleExpo indusExpo daily_info monthly_info quarterly_info

% �������������뱾�ش洢����ϲ�
MergeAndSaveFactorData(paramSet,factorExpo,factorReturn,specialReturn);













