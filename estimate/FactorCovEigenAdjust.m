% -------------------------------------------------------------------------
% 因子协方差：特征值调整（效率较低，运行增量部分，并和历史结果拼接）
% -------------------------------------------------------------------------
% [输入]
% paramSet：      全局参数集合
% factorCovNW：   NW调整后的因子协方差矩阵（factorNum * factorNum * dayNum）
% [输出]
% factorCovEigenAdj：     特征值调整估计（styleNum * styleNum * dayNum)
% -------------------------------------------------------------------------
function factorCovEigenAdj = FactorCovEigenAdjust(paramSet,factorCovNW)
    
fprintf('因子协方差矩阵特征值调整');tic;

% 参数设置
MCS = paramSet.FactorCov.EigenAdj.MCS;                      
A = paramSet.FactorCov.EigenAdj.A;        
timeWin = paramSet.FactorCov.EigenAdj.timeWindow;
[factorNum,~,dayNum] = size(factorCovNW);   

% 初始化结果
factorCovEigenAdj = nan(factorNum,factorNum,dayNum);
factorCovEigenAdjGamma = nan(factorNum,dayNum);

% 循环计算所有截面的数据
for iDay = paramSet.updateTBegin:dayNum
    
    fprintf('    截面编号：%d\n', iDay);

    % NAN值处理：由于行业个数出现过变更，较早之前的数据有一个因子维度有缺失
    tempFnw = factorCovNW(:,:,iDay);
    Fnw = tempFnw(~isnan(tempFnw));
    FnwDims = sqrt(size(Fnw,1));
    if FnwDims == 0
        continue;
    end
    Fnw = reshape(Fnw,[FnwDims,FnwDims]);

    % 蒙特卡洛模拟：计算模拟风险偏差
    [U0,D0] = EigSorted(Fnw);                    
    lambda = zeros(FnwDims,1);
    tempRM = U0*sqrt(D0);                                  
    for iterMCS=1:MCS
        rng(iterMCS);     % 固定随机数种子点
        rm = tempRM * randn(FnwDims,timeWin);
        Fm = cov(rm');
        [Um,Dm] = EigSorted(Fm);              
        DmReal = diag(Um'*Fnw*Um);           
        lambda=lambda+DmReal./diag(Dm);       
    end
    lambda = sqrt(lambda/MCS);                        

    % 协方差矩阵：特征值调整
    gamma = A * (lambda-1) + 1;                    
    D0Real = D0 .* diag(gamma.^2);                        
    Feigen = U0 * D0Real * U0';                             

    % 存储结果
    FeigenReal = nan(size(tempFnw));
    FeigenReal(~isnan(tempFnw)) = Feigen(1:end);
    factorCovEigenAdj(:,:,iDay) = FeigenReal;        
    factorCovEigenAdjGamma(1:FnwDims,iDay) = gamma;
end

% 如果是增量运行模式，则需要和历史结果拼接
if paramSet.updateTBegin ~= 1
    % 获取历史数据
    histResult = importdata([paramSet.global.save_path 'factorCovEigenAdj.mat']);
    % 时间维度更新
    [~,~,n_days_new] = size(factorCovEigenAdj);
    histResult(:,:,paramSet.updateTBegin:n_days_new) = factorCovEigenAdj(:,:,paramSet.updateTBegin:n_days_new);
    % 返回结果
    factorCovEigenAdj = histResult;
end
    
fprintf('  耗时：%.4f秒\n',toc);

end