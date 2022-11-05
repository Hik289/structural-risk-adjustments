% -------------------------------------------------------------------------
% �������ܣ����ղƱ�����ʱ�䣬����Ƶ�����ڶ�λ���¿�ʹ�õĲƱ�����
% -------------------------------------------------------------------------
% [����]
% daily_info��    ������Ƶ���� 
% quarterly_info: ���ؼ�Ƶ����
% rptFreq:        �Ʊ�ʹ��Ƶ�ʣ�ʹ�����м���(quarterly)��ֻʹ���걨(annual)
% [���]
% useQuarterLoc�� ÿ����Ƶ�����ܻ�ȡ�����²Ʊ�������stockNum * dayNum��
% -------------------------------------------------------------------------
function useQuarterLoc = CalcUseQuarterLoc(daily_info,quarterly_info,rptFreq)

% ��Ƶ��������
dailyDates = daily_info.dates;

% ���ɲƱ���ʵ����ʱ��(stockNum * quarterNum)
issueDate = quarterly_info.issue_date;

% ����ʹ�õĲƱ����ͣ���ȡ��Ӧ����ʵ��������
if isequal(rptFreq,'annual')
    columnInterval = 4;
else
    columnInterval = 1;
end

% �������ݿ��м����Ǵ�1997���걨��ʼ�洢��Ҳ����һ��Ϊ�걨
selectColumn = 1:columnInterval:size(issueDate,2);    
selectIssueDate = issueDate(:,selectColumn);

% ��ʼ���������
useQuarterLoc = nan(size(issueDate,1),size(dailyDates,2)); 

% ����ÿ֧��Ʊ
for iStock = 1:size(selectIssueDate,1)
    
    if sum(~isnan(selectIssueDate(iStock,:)))
        
        % ��ȡ��ǰ��Ʊ��Ч�Ĳ��񱨱���ʵ������������
        [~,validColumn] = find(~isnan(selectIssueDate(iStock,:)));
        validIssueDate = selectIssueDate(iStock,validColumn);
        
        % ��������²Ʊ�����������˳��ģ������ڴ����º��������������²Ʊ�
        % �������ڴ��ң�����2005���걨��2008��Ź���������ʱ��Ҫ�޳���Чֵ
        % �޳���������ĳ�ڼ�������ʵ�����������ں����κ�һ�ڼ�����������
        min_val = arrayfun(@(x) min(validIssueDate(x:end)),1:length(validIssueDate));
        valid_index = validIssueDate <= min_val;
        validIssueDate = validIssueDate(valid_index);
        validColumn = validColumn(valid_index);
        
        % ���Ʊ���������ȫ��Ƶ���������У�Ҳ���ҵ����ڹ������ڵĵ�һ����
        dailyIndex = cell2mat(arrayfun(@(x) find(dailyDates>=x,1),validIssueDate,'UniformOutput',false));
        useQuarterLoc(iStock,dailyIndex) = selectColumn(validColumn(1:length(dailyIndex)));
        
    end
end

% ��ȱʧֵ��ǰһ��ֵ��䣬ÿ�������϶��Ƕ�ȡ���²Ʊ�����
useQuarterLoc = fillmissing(useQuarterLoc,'prev',2);
 
end


        
    
    
    
    