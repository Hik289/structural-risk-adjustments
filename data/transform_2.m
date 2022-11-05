% -------------------------------------------------------------------------
% ��ԭ���ݸ�ʽת�������µ����ݸ�ʽ
% -------------------------------------------------------------------------
clear; clc; close all;
load('alpha.mat');
load('alpha_daily.mat');
load('alpha_daily_1.mat');
w = windmatlab;

% -------------------------------------------------------------------------
% ��������
% -------------------------------------------------------------------------
% ���ɻ�����Ϣ
basic_info.stock_code = basicinfo.stock_number_wind;
basic_info.stock_name = basicinfo.stock_name;
basic_info.ipo_date = basicinfo.IPO_date;
basic_info.delist_date = basicinfo.delist_date;

% ������Ƶ����
daily_info.dates = dailyinfo.dates;
daily_info.close = dailyinfo.close;
daily_info.close_adj = dailyinfo.close_adj;
daily_info.turn = dailyinfo.turn;
daily_info.total_shares = dailyinfo.total_shares;
daily_info.float_a_shares = dailyinfo.float_a_shares;
daily_info.cs_indus_code = dailyinfo.cs_indus_code;
daily_info.amt = dailyinfo_1.amt;
daily_info.volume = dailyinfo_1.volume;

% ������Ƶ����
monthly_info.dates = monthlyinfo.dates(1,:);

% ���ɼ�Ƶ����
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

% ������
save('stock_data','basic_info','daily_info','monthly_info','quarterly_info');

% -------------------------------------------------------------------------
% ָ�����ݣ�ָ�����̼�Ϊ��Ƶ���ݣ��ɷֹ���ϢΪ��Ƶ������ɹ����������ݣ�
% -------------------------------------------------------------------------
% ��Ƶ��ֹ����
start_date = datestr(daily_info.dates(1),'yyyy-mm-dd');
end_date = datestr(daily_info.dates(end),'yyyy-mm-dd');
    
% ����300
index_data.HS300.stock_list = monthlyinfo.HS300_list;
index_data.HS300.stock_weight = monthlyinfo.HS300_weight;
index_data.HS300.close.net = indexinfo.SH000300.close;
[data,~,~,~,~,~] = w.wsd('H00300.CSI','close',start_date,end_date);
index_data.HS300.close.total = data';

% ��֤500
index_data.ZZ500.stock_list = monthlyinfo.ZZ500_list;
index_data.ZZ500.stock_weight = monthlyinfo.ZZ500_weight;
index_data.ZZ500.close.net = indexinfo.SH000905.close;
[data,~,~,~,~,~] = w.wsd('H00905.CSI','close',start_date,end_date);
index_data.ZZ500.close.total = data';

% ��֤800
index_data.ZZ800.stock_list = monthlyinfo.ZZ800_list;
index_data.ZZ800.stock_weight = monthlyinfo.ZZ800_weight;
index_data.ZZ800.close.net = indexinfo.SH000906.close;
[data,~,~,~,~,~] = w.wsd('H00906.CSI','close',start_date,end_date);
index_data.ZZ800.close.total = data';

% ��֤1000
index_data.ZZ1000.stock_list = monthlyinfo.ZZ1000_list;
index_data.ZZ1000.stock_weight = monthlyinfo.ZZ1000_weight;
index_data.ZZ1000.close.net = indexinfo.SH000852.close;
[data,~,~,~,~,~] = w.wsd('H00852.SH','close',start_date,end_date);
index_data.ZZ1000.close.total = data';

% ��֤ȫָ
index_data.ZZQZ.stock_list = monthlyinfo.ZZquanzhi_list;
index_data.ZZQZ.stock_weight = monthlyinfo.ZZquanzhi_weight;
index_data.ZZQZ.close.net = indexinfo.CSI000985.close;
[data,~,~,~,~,~] = w.wsd('H00985.CSI','close',start_date,end_date);
index_data.ZZQZ.close.total = data';

% �洢���
save('index_data','index_data');

% -------------------------------------------------------------------------
% ��ҵ���ݣ�����������ҵָ�����̼ۣ�������������������ͬ����
% -------------------------------------------------------------------------
% Ŀ����ҵ(�����ҵ�����ǺͶ����ӵײ����ݿ����ҵ������Ӧ�ģ���Ҫ���)
indus_info = {
    'ú̿',             'CI005002.WI';
    '��ͨ����',         'CI005024.WI';
    '���ز�',           'CI005023.WI';
    '������������ҵ',   'CI005004.WI';
    '��е',             'CI005010.WI';
    '�����豸������Դ', 'CI005011.WI';
    '��ɫ����',         'CI005003.WI';
    '��������',         'CI005006.WI';
    '��ó����',         'CI005014.WI';
    '����',             'CI005007.WI';
    '�Ṥ����',         'CI005009.WI';
    '�ۺ�',             'CI005029.WI';
    'ҽҩ',             'CI005018.WI';
    '��֯��װ',         'CI005017.WI';
    'ʳƷ����',         'CI005019.WI';
    '�ҵ�',             'CI005016.WI';
    '����',             'CI005013.WI';
    '����',             'CI005025.WI';
    '����',             'CI005008.WI';
    '�����߷���',       'CI005015.WI';
    'ʯ��ʯ��',         'CI005001.WI';
    '��������',         'CI005012.WI';
    'ũ������',         'CI005020.WI';
    '����',             'CI005005.WI';
    'ͨ��',             'CI005026.WI';
    '�����',           'CI005027.WI';
    '�����н���',       'CI005022.WI';
    '��ý',             'CI005028.WI';
    '����',             'CI005021.WI';
    '�ۺϽ���',         'CI005030.WI';
};

% ����04������������̼�
[daily_close,~,~,daily_dates,~,~] = w.wsd(...
    indus_info(:,2), 'close', '2004-12-31', daily_info.dates(end));

% ��������Ʊ���ݶ��������
full_close = nan(size(indus_info,1),length(daily_info.dates));
[~,index] = ismember(daily_dates,daily_info.dates);
full_close(:,index) = daily_close';

% ���ɽ��
indus_data.indus_name = indus_info(:,1);
indus_data.indus_close = full_close;
save('indus_data','indus_data');

% -------------------------------------------------------------------------
% ����������Ԥ���0����Ϊnan
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


