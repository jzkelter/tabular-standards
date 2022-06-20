function plot_results(fig_num, Start_Month, End_Month)
    
    source 'info.m'
    
    
    figure(fig_num)
    clf
    
    subplot(2,3,1)
    hold on
    source 'Aggr_Production.m'
    %source 'Aggr_Sales.m'
    source 'Aggr_Demand_Unsattisfied.m'
    plot((Start_Month:End_Month)./12 , Aggr_Production(Start_Month:End_Month))
    %plot((Start_Month:End_Month)./12 , Aggr_Sales(Start_Month:End_Month))
    plot((Start_Month:End_Month)./12 , Aggr_Demand_Unsattisfied(Start_Month:End_Month))
    xlim([Start_Month./12 End_Month./12])
    ylabel('Production / Demand')  
    
    subplot(2,3,4)
    source 'Employment.m'
    plot((Start_Month:End_Month)./12 , Employment(Start_Month:End_Month))
    xlim([Start_Month./12 End_Month./12])
    ylabel('Employment')
        
    subplot(2,3,2)
    source 'PriceIndex.m'
    plot((Start_Month:End_Month)./12 , PriceIndex(Start_Month:End_Month,:))
    xlim([Start_Month./12 End_Month./12])
    ylabel('Price Index')
       
    subplot(2,3,5)
    source 'WageIndex.m'
    plot((Start_Month:End_Month)./12 , WageIndex(Start_Month:End_Month,:))
    xlim([Start_Month./12 End_Month./12])
    ylabel('Wage Index') 
    
    subplot(2,3,3)
    source 'FI_Profits.m'
    plot((Start_Month:End_Month)./12 , mean( FI_Profits(Start_Month:End_Month,:)' ))
    xlim([Start_Month./12 End_Month./12])
    ylabel('Mean Profits')    
    
    subplot(2,3,6)
    hold on
    source 'Money_FI_Mean.m'
    source 'Money_HH_Mean.m'
    plot((Start_Month*21-20:End_Month*21)./21./12 , Money_FI_Mean(Start_Month*21-20:End_Month*21))
    plot((Start_Month*21-20:End_Month*21)./21./12 , Money_HH_Mean(Start_Month*21-20:End_Month*21))
    xlim([ (Start_Month*21-20)./21./12  (End_Month*21-20)./21./12 ])
    ylabel('Mean Money')





    figure(fig_num+1)
    clf
    
    subplot(2,3,1)
    correlations = zeros(61,1);
    for t=-30:30
        correlations(t+31) = corr(Aggr_Production(Start_Month:End_Month),PriceIndex(Start_Month+t:End_Month+t) );
    end
    plot((-30:30)./3, correlations)
    xlabel('Lags (quarters)')
    ylabel('Correlation GDP_t with Inflation_{t+x}')
    
    subplot(2,3,2)
    plot(PriceIndex(Start_Month+6:End_Month)-PriceIndex(Start_Month:End_Month-6), NumberOfHH-Employment(Start_Month+6:End_Month) + 0.2*randn(1,End_Month-Start_Month-5), 'k.')

    subplot(2,3,3)
    hold on
    source 'Vacancies.m'
    plot(Vacancies(Start_Month:End_Month) + 0.2*randn(1,End_Month-Start_Month+1), NumberOfHH-Employment(Start_Month:End_Month) + 0.2*randn(1,End_Month-Start_Month+1), 'k.')
    
    subplot(2,3,4)
    hold on
    source 'FI_Strategy.m'
    plot((Start_Month:End_Month)./12, FI_Strategy(Start_Month:End_Month,1),'k')   %rise wage
    plot((Start_Month:End_Month)./12, FI_Strategy(Start_Month:End_Month,2),'b')   %lower wage
    plot((Start_Month:End_Month)./12, FI_Strategy(Start_Month:End_Month,3),'r')   %rise prices
    plot((Start_Month:End_Month)./12, FI_Strategy(Start_Month:End_Month,4),'g')   %lower prices
    plot((Start_Month:End_Month)./12, FI_Strategy(Start_Month:End_Month,5),'g')   %hire worker
    plot((Start_Month:End_Month)./12, FI_Strategy(Start_Month:End_Month,6),'g')   %fire worker

    subplot(2,3,5)
    hold on
    source 'FI_Size.m'
    plot((Start_Month:End_Month)./12, FI_Size(Start_Month:End_Month,:))
 
    subplot(2,3,6)
    connection = zeros( (End_Month-Start_Month+1) * size(FI_Size,2)  , 1);
    for t = Start_Month:End_Month
        connection((t-Start_Month)*size(FI_Size,2)+1 : (t-Start_Month+1)*size(FI_Size,2)) = [FI_Size(t,:)];
    end
    n=hist(connection,[1:30])   
    plot(1:30,n)
    
    
    