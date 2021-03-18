function plot_results_2(fig_num, Start_Month, End_Month)
    
    source 'info.m'
    
    
    figure(fig_num)
    clf
    
    subplot(2,3,1)
    hold on
    source 'Aggr_Demand_Planned.m';
    source 'Aggr_Demand_Unsattisfied.m';
    plot((Start_Month:End_Month)./12 ,Aggr_Demand_Unsattisfied(Start_Month:End_Month) ./ Aggr_Demand_Planned(Start_Month:End_Month), 'k')
    xlim([Start_Month./12 End_Month./12])
    title('Unsattisfied Demand (Relative)')  
    
    subplot(2,3,4)
    End_Month_empl = min(End_Month,Start_Month+500);
    source 'Employment.m'
    plot((Start_Month:End_Month_empl)./12 , Employment(Start_Month:End_Month_empl))
    xlim([Start_Month./12 End_Month_empl./12])
    title('Employment')
  
    subplot(2,3,2)
    source 'PriceIndex.m'
    plot(PriceIndex(Start_Month+3:End_Month)-PriceIndex(Start_Month:End_Month-3), NumberOfHH-Employment(Start_Month+3:End_Month) + rand(1,End_Month-Start_Month-2)-0.5, 'k.')
    xlabel('Inflation')
    ylabel('Unemployment')
    
    subplot(2,3,5)
    source 'Vacancies.m'
    plot(Vacancies(Start_Month:End_Month) + rand(1,End_Month-Start_Month+1)-0.5, NumberOfHH-Employment(Start_Month:End_Month) + rand(1,End_Month-Start_Month+1)-0.5, 'k.')
    xlabel('Vacancies')
    ylabel('Unemployment')
    
    subplot(2,3,3)
    correlations = zeros(49,1);
    for t=-24:24
        correlations(t+25) = corr(Employment(Start_Month:End_Month),PriceIndex(Start_Month+t:End_Month+t) );
    end
    plot((-24:24)./3, correlations)
    xlabel('Lags (quarters)')
    ylabel('Correlation GDP_t with Inflation_{t+x}')
    hold on
    load correlations_data
    plot(-8:8,correlations_data,'k:')
    load correlations_data_2
    plot(-8:8,correlations_data_2,'k--')

    source 'FI_Size.m'
    subplot(2,3,6)
    connection = zeros( (End_Month-Start_Month+1) * size(FI_Size,2)  , 1);
    for t = Start_Month:End_Month
        connection((t-Start_Month)*size(FI_Size,2)+1 : (t-Start_Month+1)*size(FI_Size,2)) = FI_Size(t,:);
    end
    n=hist(connection,[1:max(connection)])   
    plot([1:max(connection)],n,'k')
    title('Firm Size')