% -------------------------------------------------------------------------
% 函数功能：按照财报发布时间，在日频日期内定位最新可使用的财报数据
% -------------------------------------------------------------------------
% [输入]
% daily_info：    本地日频数据 
% quarterly_info: 本地季频数据
% rptFreq:        财报使用频率，使用所有季报(quarterly)，只使用年报(annual)
% [输出]
% useQuarterLoc： 每个日频日期能获取的最新财报索引（stockNum * dayNum）
% -------------------------------------------------------------------------
function useQuarterLoc = CalcUseQuarterLoc(daily_info,quarterly_info,rptFreq)

% 日频日期序列
dailyDates = daily_info.dates;

% 个股财报真实公布时间(stockNum * quarterNum)
issueDate = quarterly_info.issue_date;

% 根据使用的财报类型，抽取相应的真实公布日期
if isequal(rptFreq,'annual')
    columnInterval = 4;
else
    columnInterval = 1;
end

% 本地数据库中季报是从1997年年报开始存储，也即第一列为年报
selectColumn = 1:columnInterval:size(issueDate,2);    
selectIssueDate = issueDate(:,selectColumn);

% 初始化输出矩阵
useQuarterLoc = nan(size(issueDate,1),size(dailyDates,2)); 

% 遍历每支股票
for iStock = 1:size(selectIssueDate,1)
    
    if sum(~isnan(selectIssueDate(iStock,:)))
        
        % 获取当前股票有效的财务报表真实公布日期序列
        [~,validColumn] = find(~isnan(selectIssueDate(iStock,:)));
        validIssueDate = selectIssueDate(iStock,validColumn);
        
        % 正常情况下财报公布日期是顺序的，但由于存在事后修正操作，导致财报
        % 公布日期错乱（比如2005年年报在2008年才公布），此时需要剔除无效值
        % 剔除条件：当某期季报的真实公布日期晚于后面任何一期季报公布日期
        min_val = arrayfun(@(x) min(validIssueDate(x:end)),1:length(validIssueDate));
        valid_index = validIssueDate <= min_val;
        validIssueDate = validIssueDate(valid_index);
        validColumn = validColumn(valid_index);
        
        % 将财报索引填入全日频日期序列中，也即找到大于公布日期的第一个点
        dailyIndex = cell2mat(arrayfun(@(x) find(dailyDates>=x,1),validIssueDate,'UniformOutput',false));
        useQuarterLoc(iStock,dailyIndex) = selectColumn(validColumn(1:length(dailyIndex)));
        
    end
end

% 将缺失值用前一刻值填充，每个截面上都是读取最新财报数据
useQuarterLoc = fillmissing(useQuarterLoc,'prev',2);
 
end


        
    
    
    
    