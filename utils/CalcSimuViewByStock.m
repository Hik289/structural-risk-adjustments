function indusView = CalcSimuViewByStock(param,dailyClose,fullStockWeight,factorExpo)
% -------------------------------------------------------------------------
% 函数功能：根据行业内成分股计算，生成指定胜率的行业多空观点
% -------------------------------------------------------------------------

% 行业因子暴露的索引
indusFactorIndex = param.styleFactorNum+1:param.styleFactorNum+param.indusFactorNum;

% 初始化结果
indusView = nan(length(indusFactorIndex),length(param.month2day));

% 遍历每个截面
for iMonth = param.beginMonth:(param.endMonth-1)
        
    % 获取日期索引
    thisMonthEnd = param.month2day(1,iMonth);
    nextMonthEnd = param.month2day(1,iMonth+1);
    
    % 获取当前截面对应的行业因子暴露
    indusExpo = factorExpo(:,indusFactorIndex,thisMonthEnd);
    
    % 获取当前截面上个股权重
    stockWeight = fullStockWeight(:,iMonth);
    
    % 获取个股下月收益
    stockReturn = dailyClose(:,nextMonthEnd)./dailyClose(:,thisMonthEnd)-1;
     
    % 根据个股收益加权合成行业下月收益
    panelIndusReturn =  nan(length(indusFactorIndex),1);
    for iIndus = 1:length(indusFactorIndex)
        % 条件1：个股属于目标行业
        condition1 = indusExpo(:,iIndus) == 1;
        % 条件2：个股权重非零
        condition2 = stockWeight > 0;
        % 条件3：个股下期收益非空
        condition3 = ~isnan(stockReturn);
        % 获取有效的个股权重及下期收益
        valid = condition1 & condition2 & condition3;
        validWeight = stockWeight(valid);
        validReturn = stockReturn(valid);
        % 计算加权收益
        panelIndusReturn(iIndus) = validWeight'*validReturn / sum(validWeight);
    end
    
    % 生成截面预测观点
    view = [];
    while isempty(view)
        try 
            view = IndusViewGeneration(param,panelIndusReturn);
        catch
            % nothing to do
        end
    end
    indusView(:,iMonth) = view;
    
end

end

% -------------------------------------------------------------------------
% 函数功能：根据设置的精度生成行业多空观点
% 
% [输入]
% param：           全局参数结构体
% panelIndusReturn：行业指数下月的真实收益
%
% [输出]
% view： 看多行业为1，看空行业标记为-1，中性行业记为0（indusFactorNum * 1）
% -------------------------------------------------------------------------
function view = IndusViewGeneration(param,panelIndusReturn)

% 预测精度
accuracy = param.accuracy;

% 行业等权收益
average_return = nanmedian(panelIndusReturn);

% 收益大于所有行业中位数看多，小于看空
upwardIndus = find(panelIndusReturn >= average_return); % 应当看多的行业
downwardIndus = find(panelIndusReturn < average_return);% 应当看空的行业

% 均值为accuracy的0-1二项分布,0标记表示预测错误，1标记表示预测正确
accuracy_vector = binornd(1,accuracy,param.unNeturalIndusNum,1);

% 初始化结果
view = nan(1,param.indusFactorNum);

% 目前看多(空)的行业计数器
longIndusNum = 0;
shortIndusNum = 0; 

% 依次生成多、空行业观点
for iIndus = 1:param.unNeturalIndusNum

    % 假设当前观点是正确预测
    if accuracy_vector(iIndus)  
        if  longIndusNum < param.longIndusNum 
            % 在真实[跑赢]的行业中挑选一个加入[看多]集合中
            longIndus = upwardIndus(randperm(length(upwardIndus),1));
            view(longIndus) = 1;
            upwardIndus(upwardIndus == longIndus) = []; 
            longIndusNum = longIndusNum + 1;
        elseif shortIndusNum < param.shortIndusNum 
            % 在真实[跑输]的行业中挑选一个加入[看空]集合中
            shortIndus = downwardIndus(randperm(length(downwardIndus),1));
            view(shortIndus) = -1;
            downwardIndus(downwardIndus == shortIndus) = [];
            shortIndusNum = shortIndusNum + 1;
        end
    % 假设当前观点预测错误    
    else  
        if longIndusNum < param.longIndusNum 
            % 在真实[跑输]的行业中挑选一个加入[看多]集合中
            longIndus = downwardIndus(randperm(length(downwardIndus),1));
            view(longIndus) = 1;
            downwardIndus(downwardIndus == longIndus) = [];
            longIndusNum = longIndusNum+1;
        elseif shortIndusNum < param.shortIndusNum 
            % 在真实[跑赢]的行业中挑选一个加入[看空]集合中
            shortIndus = upwardIndus(randperm(length(upwardIndus),1));
            view(shortIndus) = -1;
            upwardIndus(upwardIndus == shortIndus) = [];
            shortIndusNum = shortIndusNum+1;
        end
    end    
end

% 保持中性的行业标记为0
view(isnan(view)) = 0;

end

