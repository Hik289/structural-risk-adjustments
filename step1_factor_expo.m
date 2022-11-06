% -------------------------------------------------------------------------
% 多因子风险模型第一步：生成因子暴露、因子收益率、特质收益率
%  1) 默认采用增量运行模式，回溯窗长为 ParamSet.backLength 参数
%     一般应用场景为月度更新，所以默认回溯长度为23个交易日
%  2) 如需重头开始运行，可以将 ParamSet.backLength 设置为-1
% -------------------------------------------------------------------------
clear; clc; close all;
addpath(genpath(pwd));
addpath('utils');   % 存放公共函数
addpath('factor');  % 存放因子暴露计算相关函数
dbstop if error     % 程序运行出错时停留在出错位置

% -------------------------------------------------------------------------
% 数据准备、参数生成
% -------------------------------------------------------------------------
% 获取股票基本信息、日频信息、月频信息、季频信息
load('data/stock_data','basic_info','daily_info','monthly_info','quarterly_info');

% 获取基准指数数据
load('data/index_data');

% 生成全局参数
paramSet =  ParamSet();

% 获取计算起始索引（支持从头开始运行，也支持增量运行模式）
paramSet.updateTBegin = CalcUpdateTBegin(paramSet,daily_info);

% 分别获取每个截面上能看到的最新年报和最新季报位置索引
useQuarterLoc.annual = CalcUseQuarterLoc(daily_info,quarterly_info,'annual');
useQuarterLoc.quarterly = CalcUseQuarterLoc(daily_info,quarterly_info,'quarterly');

% 获取有效股票标记（剔除未上市、已退市、停牌、无交易等情况）
validStockMatrix = CalcValidStockMatrix(basic_info,daily_info);

% -------------------------------------------------------------------------
% 生成因子暴露
% -------------------------------------------------------------------------
% 计算行业因子暴露：直接获取本地存储结果即可
indusExpo = daily_info.cs_indus_code;

% 计算规模因子暴露
styleExpo.size = SizeFactorExpo(paramSet,daily_info);

% 计算Beta因子暴露
[styleExpo.beta,volResidual] = BetaFactorExpo(paramSet,daily_info,index_data);

% 计算动量因子暴露
styleExpo.momentum = MomentumFactorExpo(paramSet,daily_info);

% 计算波动率因子暴露
styleExpo.residVola = ResidVolaFactorExpo(paramSet,daily_info,volResidual);

% 计算非线性规模因子暴露
styleExpo.nonLinear = NonLinearFactorExpo(paramSet,daily_info,styleExpo.size,indusExpo,validStockMatrix);

% 计算账面市值比因子暴露
styleExpo.booktoPrice = BooktoPriceFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc);

% 计算流动性因子暴露
styleExpo.liquidity = LiquidityFactorExpo(paramSet,daily_info);

% 计算盈利因子暴露
styleExpo.earningYield = EarningYieldFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc);

% 计算成长因子暴露
styleExpo.growth = GrowthFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc);

% 计算杠杆因子暴露
styleExpo.leverage = LeverageFactorExpo(paramSet,daily_info,quarterly_info,useQuarterLoc);

% 因子暴露正交化（返回增量更新部分）
styleExpo = FactorProcess(paramSet,daily_info,styleExpo,indusExpo,validStockMatrix);

% -------------------------------------------------------------------------
% 因子收益率、残差收益率计算
% -------------------------------------------------------------------------
% 计算因子收益率和因子暴露（返回增量更新部分）
[factorReturn,factorExpo] = FactorReturn(paramSet,daily_info,styleExpo,indusExpo,validStockMatrix);

% 计算残差收益率（返回增量部分）
specialReturn = SpecialReturn(paramSet,daily_info,factorExpo,factorReturn);

% 清除无效变量，防止内存报错
clear styleExpo indusExpo daily_info monthly_info quarterly_info

% 将增量计算结果与本地存储结果合并
MergeAndSaveFactorData(paramSet,factorExpo,factorReturn,specialReturn);













