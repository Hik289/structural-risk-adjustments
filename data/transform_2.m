% -------------------------------------------------------------------------
% 将原数据格式转换成最新的数据格式
% -------------------------------------------------------------------------
clear; clc; close all;
load('alpha.mat');
load('alpha_daily.mat');
load('alpha_daily_1.mat');
w = windmatlab;

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
% 日频起止日期
start_date = datestr(daily_info.dates(1),'yyyy-mm-dd');
end_date = datestr(daily_info.dates(end),'yyyy-mm-dd');
    
% 沪深300
index_data.HS300.stock_list = monthlyinfo.HS300_list;
index_data.HS300.stock_weight = monthlyinfo.HS300_weight;
index_data.HS300.close.net = indexinfo.SH000300.close;
[data,~,~,~,~,~] = w.wsd('H00300.CSI','close',start_date,end_date);
index_data.HS300.close.total = data';

% 中证500
index_data.ZZ500.stock_list = monthlyinfo.ZZ500_list;
index_data.ZZ500.stock_weight = monthlyinfo.ZZ500_weight;
index_data.ZZ500.close.net = indexinfo.SH000905.close;
[data,~,~,~,~,~] = w.wsd('H00905.CSI','close',start_date,end_date);
index_data.ZZ500.close.total = data';

% 中证800
index_data.ZZ800.stock_list = monthlyinfo.ZZ800_list;
index_data.ZZ800.stock_weight = monthlyinfo.ZZ800_weight;
index_data.ZZ800.close.net = indexinfo.SH000906.close;
[data,~,~,~,~,~] = w.wsd('H00906.CSI','close',start_date,end_date);
index_data.ZZ800.close.total = data';

% 中证1000
index_data.ZZ1000.stock_list = monthlyinfo.ZZ1000_list;
index_data.ZZ1000.stock_weight = monthlyinfo.ZZ1000_weight;
index_data.ZZ1000.close.net = indexinfo.SH000852.close;
[data,~,~,~,~,~] = w.wsd('H00852.SH','close',start_date,end_date);
index_data.ZZ1000.close.total = data';

% 中证全指
index_data.ZZQZ.stock_list = monthlyinfo.ZZquanzhi_list;
index_data.ZZQZ.stock_weight = monthlyinfo.ZZquanzhi_weight;
index_data.ZZQZ.close.net = indexinfo.CSI000985.close;
[data,~,~,~,~,~] = w.wsd('H00985.CSI','close',start_date,end_date);
index_data.ZZQZ.close.total = data';

% 存储结果
save('index_data','index_data');

% -------------------------------------------------------------------------
% 行业数据，下载中信行业指数收盘价，并填充至与个股数据相同长度
% -------------------------------------------------------------------------
% 目标行业(这个行业排序是和多因子底层数据库的行业编号相对应的，不要变更)
indus_info = {
    '煤炭',             'CI005002.WI';
    '交通运输',         'CI005024.WI';
    '房地产',           'CI005023.WI';
    '电力及公用事业',   'CI005004.WI';
    '机械',             'CI005010.WI';
    '电力设备及新能源', 'CI005011.WI';
    '有色金属',         'CI005003.WI';
    '基础化工',         'CI005006.WI';
    '商贸零售',         'CI005014.WI';
    '建筑',             'CI005007.WI';
    '轻工制造',         'CI005009.WI';
    '综合',             'CI005029.WI';
    '医药',             'CI005018.WI';
    '纺织服装',         'CI005017.WI';
    '食品饮料',         'CI005019.WI';
    '家电',             'CI005016.WI';
    '汽车',             'CI005013.WI';
    '电子',             'CI005025.WI';
    '建材',             'CI005008.WI';
    '消费者服务',       'CI005015.WI';
    '石油石化',         'CI005001.WI';
    '国防军工',         'CI005012.WI';
    '农林牧渔',         'CI005020.WI';
    '钢铁',             'CI005005.WI';
    '通信',             'CI005026.WI';
    '计算机',           'CI005027.WI';
    '非银行金融',       'CI005022.WI';
    '传媒',             'CI005028.WI';
    '银行',             'CI005021.WI';
    '综合金融',         'CI005030.WI';
};

% 下载04年底以来的收盘价
[daily_close,~,~,daily_dates,~,~] = w.wsd(...
    indus_info(:,2), 'close', '2004-12-31', daily_info.dates(end));

% 填充至与股票数据对齐的区间
full_close = nan(size(indus_info,1),length(daily_info.dates));
[~,index] = ismember(daily_dates,daily_info.dates);
full_close(:,index) = daily_close';

% 生成结果
indus_data.indus_name = indus_info(:,1);
indus_data.indus_close = full_close;
save('indus_data','indus_data');

% -------------------------------------------------------------------------
% 将个股收益预测的0设置为nan
% -------------------------------------------------------------------------
HS300 = importdata('HS300.mat');
HS300(HS300==0) = nan;
save('HS300','HS300');

ZZ500 = importdata('ZZ500.mat');
ZZ500(ZZ500==0) = nan;
save('ZZ500','ZZ500');

market = importdata('market.mat');
market(market==0) = nan;
save('market','market');


