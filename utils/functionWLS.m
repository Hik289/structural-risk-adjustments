%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Weight Least Square
% varX varY weight 矩阵大小一致。通常为1×N。
% -------------------------------------------------------------------------
% 使用优化算法，提升大量回归运算的效率
% 1. VarY 允许是一个M×N的矩阵
%       代表 VarX 对  VarY M行分别进行线性回归
%       此时 beta , error 为 M×1 向量。
%        beta , error向量中第 m 项表示 varX 对 varY 的第 m 行加权回归的结果。
% -------------------------------------------------------------------------
% 最复杂的输入情况说明 -- 原始代码不支持此功能，已修改(jwy 20190320)
% 当size(varY) 为[M,N],且size(weight) 为[K,N]时
% 输出beta,error为[M,K]的矩阵
% 其中第m行，第k列的数据表示varX在第k行的权重下，对varY第m行的数据回归。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ beta,error ] = functionWLS(varY,varX,weight)

    % ------------------------ begin: add by lic
    rStockWin = varY;
    rIndexWin = varX;
    weight1 = repmat(weight, size(rStockWin,1), 1);
    
    % 将因变量中的空值设为零，并调整权重向量
    nanIndex = isnan(rIndexWin);
    rIndexWin(nanIndex) = 0;
    weight1(:,nanIndex) = 0;
    
    % 将因变量中的空值设为零，并调整权重向量
    nanIndex = isnan(rStockWin);
    rStockWin(nanIndex) = 0;
    weight1(nanIndex) = 0;

    % 计算WLS回归解析解
    sumWeight1 = sum(weight1,2);                  
    weightVarY1 = rStockWin .* weight1;  
    sumWeightVarY1 = sum(weightVarY1,2);                   
    sumWeightVarX1 = weight1 * rIndexWin';
    meanVarX1 = sumWeightVarX1 ./ sumWeight1;       
    temp11 = weightVarY1*rIndexWin' - sumWeightVarY1.*meanVarX1;
    temp21 = weight1*rIndexWin.^2'-sumWeightVarX1.^2./sumWeight1;   
    beta1 = temp11 ./ temp21;
    error1 = sumWeightVarY1./sumWeight1 - beta1.*meanVarX1;
    
    % ------------------------ end: add by lic

    [lineNumY,~]=size(varY);
    if isnan(weight)                                    % 判断weight 确定是否设置等权重
        [~,timeLength]=size(varY);
        weight=ones(1,timeLength);                      % 默认size(weight)=[1,N]
    end
    [lineNumW,~]=size(weight);
    nanLocX=isnan(varX);
    varX(nanLocX)=0;                                    % varX中NAN值处理
    weight(:,nanLocX)=0;
    
    beta=nan(lineNumY,lineNumW);                        % 初始化输出的beta和error项
    error=nan(lineNumY,lineNumW);

    if ~all(all(nanLocX))                               % 判断varX中是否都是nan,如果不是才计算，以避免后续运算异常
        for iW=1:lineNumW
            newWeight=repmat(weight(iW,:),lineNumY,1);
            nanLocY=isnan(varY);
            newWeight(nanLocY)=0;                        % varY中NAN值处理
            varY(nanLocY)=0;
            
            sumWeight=sum(newWeight,2);                  % 中间步骤 优化程序计算速度
            weightVarY=varY.*newWeight;                  % jwy:有误 varY(M*N),newWeight((K*M)*N)
            sumWeightVarY=sum(weightVarY,2);                  % 
            sumWeightVarX=newWeight*varX';                   % 
            meanVarX=sumWeightVarX./sumWeight;         % 中间步骤 优化程序计算速度
            
            temp1=weightVarY*varX'-sumWeightVarY.*meanVarX;
            temp2=newWeight*varX.^2'-sumWeightVarX.^2./sumWeight;
            beta(:,iW)=temp1./temp2;
            error(:,iW)=sumWeightVarY./sumWeight-beta.*meanVarX;
        end
    end
end
