% -------------------------------------------------------------------------
% 将原数据格式转换成最新的数据格式
% -------------------------------------------------------------------------
clear; clc; close all;
load('alpha.mat');
load('alpha_daily.mat');
load('alpha_daily_1.mat');

% -------------------------------------------------------------------------
% 个股数据
% -------------------------------------------------------------------------
% 个股基本信息
basic_info.stock_code = basicinfo.stock_number_wind;
basic_info.stock_name = basicinfo.stock_name;
basic_info.ipo_date = basicinfo.IPO_date;
basic_info.delist_date = basicinfo.delist_date;

% 个股日频数据
daily_info.dates = dailyinfo.dates;
daily_info.close = dailyinfo.close;
daily_info.close_adj = dailyinfo.close_adj;
daily_info.turn = dailyinfo.turn;
daily_info.total_shares = dailyinfo.total_shares;
daily_info.float_a_shares = dailyinfo.float_a_shares;
daily_info.cs_indus_code = dailyinfo.cs_indus_code;
daily_info.amt = dailyinfo_1.amt;
daily_info.volume = dailyinfo_1.volume;

% 个股月频数据
monthly_info.dates = monthlyinfo.dates(1,:);
% monthly_info.FilterStock = monthlyinfo.FilterStock;
% monthly_info.FilterStock_STPT = monthlyinfo.FilterStock_STPT;
% monthly_info.FilterStock_STPT_SPEND = monthlyinfo.FilterStock_STPT_SPEND;
% monthly_info.FilterStock_OPENUPLIMIT = monthlyinfo.FilterStock_OPENUPLIMIT;

% 个股季频数据
quarterly_info.dates = quarterlyinfo.dates;
quarterly_info.issue_date = quarterlyinfo.stm_issuingdate1;
quarterly_info.tot_liab = quarterlyinfo.tot_liab;
quarterly_info.tot_equity = quarterlyinfo.tot_equity;
quarterly_info.tot_assets = quarterlyinfo.tot_assets;
quarterly_info.tot_non_cur_liab = quarterlyinfo.tot_non_cur_liab;
quarterly_info.eqy_belongto_parcomsh = quarterlyinfo.eqy_belongto_parcomsh;
quarterly_info.oper_rev = quarterlyinfo.oper_rev;
quarterly_info.tot_oper_rev = quarterlyinfo.tot_oper_rev;
quarterly_info.net_profit_is = quarterlyinfo.net_profit_is;
quarterly_info.np_belongto_parcomsh = quarterlyinfo.np_belongto_parcomsh;
quarterly_info.net_cash_flows_oper_act = quarterlyinfo.net_cash_flows_oper_act;

% 保存结果
save('stock_data','basic_info','daily_info','monthly_info','quarterly_info');

% -------------------------------------------------------------------------
% 指数数据（指数收盘价为日频数据，成分股信息为月频，与个股共享日期数据）
% -------------------------------------------------------------------------
% 沪深300
index_data.HS300.close = indexinfo.SH000300.close;
index_data.HS300.stock_list = monthlyinfo.HS300_list;
index_data.HS300.stock_weight = monthlyinfo.HS300_weight;

% 中证500
index_data.ZZ500.close = indexinfo.SH000905.close;
index_data.ZZ500.stock_list = monthlyinfo.ZZ500_list;
index_data.ZZ500.stock_weight = monthlyinfo.ZZ500_weight;

% 中证800
index_data.ZZ800.close = indexinfo.SH000906.close;
index_data.ZZ800.stock_list = monthlyinfo.ZZ800_list;
index_data.ZZ800.stock_weight = monthlyinfo.ZZ800_weight;

% 中证1000
index_data.ZZ1000.close = indexinfo.SH000852.close;
index_data.ZZ1000.stock_list = monthlyinfo.ZZ1000_list;
index_data.ZZ1000.stock_weight = monthlyinfo.ZZ1000_weight;

% 中证全指
index_data.ZZQZ.close = indexinfo.CSI000985.close;
index_data.ZZQZ.stock_list = monthlyinfo.ZZquanzhi_list;
index_data.ZZQZ.stock_weight = monthlyinfo.ZZquanzhi_weight;

% 存储结果
save('index_data','index_data');

