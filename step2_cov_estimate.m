% -------------------------------------------------------------------------
% 多因子风险模型第二步：生成因子协方差和残差协方差估计
% -------------------------------------------------------------------------
clear; clc; close all;
addpath('utils');     % 存放公共函数
addpath('estimate');  % 存放协方差估计相关函数
dbstop if error       % 程序运行出错时停留在出错位置

% -------------------------------------------------------------------------
% 数据准备、参数生成
% -------------------------------------------------------------------------
% 获取因子暴露、因子收益率、特质收益率
load('result/factorExpo.mat');
load('result/factorReturn.mat');
load('result/specialReturn.mat');

% 获取股票日频信息
load('data/stock_data.mat','daily_info')

% 生成全局参数
paramSet =  ParamSet();

% 获取计算起始索引（支持从头开始运行，也支持增量运行模式）
paramSet.updateTBegin = CalcUpdateTBegin(paramSet,daily_info);

% -------------------------------------------------------------------------
% 因子协方差估计
% -------------------------------------------------------------------------
% 因子协方差估计：Newey-West调整（全局运行）
factorCovNW = FactorCovNeweyWest(paramSet, factorReturn);

% 因子协方差估计：特征值调整（运行增量部分，然后和历史结果拼接）
factorCovEigenAdj = FactorCovEigenAdjust(paramSet,factorCovNW);

% 因子协方差估计：波动率偏误调整（全局运行）
factorCovVolRegAdj = FactorCovVolRegAdj(paramSet,factorCovEigenAdj,factorReturn);

% -------------------------------------------------------------------------
% 残差协方差调整
% -------------------------------------------------------------------------
% 残差协方差估计：NW调整（全局运行）
specialCovNW = SpecialCovNeweyWest(paramSet,specialReturn);

% 残差协方差估计：结构化调整（运行增量部分，然后和历史结果拼接）
specialCovStructAdj = SpecialCovStructAdj(paramSet,daily_info,specialCovNW,factorExpo);

% 残差协方差估计：贝叶斯压缩调整（全局运行）
specialCovBiasAdj = SpecialCovBiasAdj(paramSet,daily_info,specialCovStructAdj);

% 残差协方差估计：波动率偏误调整（全局运行）
specialCovVolRegAdj = SpecialCovVolRegAdj(paramSet,daily_info,specialCovBiasAdj,specialReturn);

% -------------------------------------------------------------------------
% 验证每步调整的效果（复现报告中相关结论，不需要每次更新数据后重新运行）
% -------------------------------------------------------------------------
beginDate = '2011-01-31';
dates = daily_info.dates;
clear daily_info factorExpo

% 因子协方差估计效果评估
CheckFactorCov(dates,beginDate,factorReturn,factorCovNW,factorCovEigenAdj,factorCovVolRegAdj);

% 残差协方差估计效果评估
CheckSpecialCov(dates,beginDate,specialReturn,specialCovNW,...
    specialCovStructAdj,specialCovBiasAdj,specialCovVolRegAdj)

% -------------------------------------------------------------------------
% 所有步骤运行正常后保存相关结果
% -------------------------------------------------------------------------
% 保存因子协方差估计结果
save([paramSet.global.save_path 'factorCovNW.mat'],'factorCovNW');
save([paramSet.global.save_path 'factorCovEigenAdj.mat'],'factorCovEigenAdj');
save([paramSet.global.save_path 'factorCovVolRegAdj.mat'],'factorCovVolRegAdj');

% 保存残差协方差估计结果
save([paramSet.global.save_path 'specialCovNW.mat'],'specialCovNW');
save([paramSet.global.save_path 'specialCovStructAdj.mat'],'specialCovStructAdj');
save([paramSet.global.save_path 'specialCovBiasAdj.mat'],'specialCovBiasAdj');
save([paramSet.global.save_path 'specialCovVolRegAdj.mat'],'specialCovVolRegAdj');

