% -------------------------------------------------------------------------
% �����ӷ���ģ�͵ڶ�������������Э����Ͳв�Э�������
% -------------------------------------------------------------------------
clear; clc; close all;
addpath('utils');     % ��Ź�������
addpath('estimate');  % ���Э���������غ���
dbstop if error       % �������г���ʱͣ���ڳ���λ��

% -------------------------------------------------------------------------
% ����׼������������
% -------------------------------------------------------------------------
% ��ȡ���ӱ�¶�����������ʡ�����������
load('result/factorExpo.mat');
load('result/factorReturn.mat');
load('result/specialReturn.mat');

% ��ȡ��Ʊ��Ƶ��Ϣ
load('data/stock_data.mat','daily_info')

% ����ȫ�ֲ���
paramSet =  ParamSet();

% ��ȡ������ʼ������֧�ִ�ͷ��ʼ���У�Ҳ֧����������ģʽ��
paramSet.updateTBegin = CalcUpdateTBegin(paramSet,daily_info);

% -------------------------------------------------------------------------
% ����Э�������
% -------------------------------------------------------------------------
% ����Э������ƣ�Newey-West������ȫ�����У�
factorCovNW = FactorCovNeweyWest(paramSet, factorReturn);

% ����Э������ƣ�����ֵ�����������������֣�Ȼ�����ʷ���ƴ�ӣ�
factorCovEigenAdj = FactorCovEigenAdjust(paramSet,factorCovNW);

% ����Э������ƣ�������ƫ�������ȫ�����У�
factorCovVolRegAdj = FactorCovVolRegAdj(paramSet,factorCovEigenAdj,factorReturn);

% -------------------------------------------------------------------------
% �в�Э�������
% -------------------------------------------------------------------------
% �в�Э������ƣ�NW������ȫ�����У�
specialCovNW = SpecialCovNeweyWest(paramSet,specialReturn);

% �в�Э������ƣ��ṹ�������������������֣�Ȼ�����ʷ���ƴ�ӣ�
specialCovStructAdj = SpecialCovStructAdj(paramSet,daily_info,specialCovNW,factorExpo);

% �в�Э������ƣ���Ҷ˹ѹ��������ȫ�����У�
specialCovBiasAdj = SpecialCovBiasAdj(paramSet,daily_info,specialCovStructAdj);

% �в�Э������ƣ�������ƫ�������ȫ�����У�
specialCovVolRegAdj = SpecialCovVolRegAdj(paramSet,daily_info,specialCovBiasAdj,specialReturn);

% -------------------------------------------------------------------------
% ��֤ÿ��������Ч�������ֱ�������ؽ��ۣ�����Ҫÿ�θ������ݺ��������У�
% -------------------------------------------------------------------------
beginDate = '2011-01-31';
dates = daily_info.dates;
clear daily_info factorExpo

% ����Э�������Ч������
CheckFactorCov(dates,beginDate,factorReturn,factorCovNW,factorCovEigenAdj,factorCovVolRegAdj);

% �в�Э�������Ч������
CheckSpecialCov(dates,beginDate,specialReturn,specialCovNW,...
    specialCovStructAdj,specialCovBiasAdj,specialCovVolRegAdj)

% -------------------------------------------------------------------------
% ���в������������󱣴���ؽ��
% -------------------------------------------------------------------------
% ��������Э������ƽ��
save([paramSet.global.save_path 'factorCovNW.mat'],'factorCovNW');
save([paramSet.global.save_path 'factorCovEigenAdj.mat'],'factorCovEigenAdj');
save([paramSet.global.save_path 'factorCovVolRegAdj.mat'],'factorCovVolRegAdj');

% ����в�Э������ƽ��
save([paramSet.global.save_path 'specialCovNW.mat'],'specialCovNW');
save([paramSet.global.save_path 'specialCovStructAdj.mat'],'specialCovStructAdj');
save([paramSet.global.save_path 'specialCovBiasAdj.mat'],'specialCovBiasAdj');
save([paramSet.global.save_path 'specialCovVolRegAdj.mat'],'specialCovVolRegAdj');

