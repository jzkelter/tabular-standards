function plot_results_2(fig_num, Start_Month, End_Month)
    Aggr_Demand_Unsattisfied
    source 'info.m'
    save -ascii 'Start_Month.m' Start_Month
    save -ascii 'End_Month.m' End_Month

    figure(1)
    clf
    source 'Aggr_Demand_PlannedDaily.m';
    source 'Aggr_Demand_Unsattisfied.m';
    hist(Aggr_Demand_Unsattisfied(Start_Month:End_Month) ./ (21*Aggr_Demand_Planned(Start_Month:End_Month)), 100)
    xlim([0 0.002])
    title('Unsattisfied Demand (Relative)')  
    ylabel('absoloute frequency')
    sort_frequencies = sort(Aggr_Demand_Unsattisfied(Start_Month:End_Month) ./ (21*Aggr_Demand_Planned(Start_Month:End_Month)));
    sort_frequencies(length(sort_frequencies)*0.95)
    histogram_data = Aggr_Demand_Unsattisfied(Start_Month:End_Month) ./ (21*Aggr_Demand_Planned(Start_Month:End_Month));
    save -ascii 'histogram_data.m' histogram_data
    
	% In 95% of all periods the relative unsattisfied demand lies below xxx
    rel_unsattisfied_Demand_95 = sort_frequencies(round(0.95*length(sort_frequencies)))
        
    
    figure(2)
    clf
    End_Month_empl = min(End_Month,Start_Month+600);
    source 'Employment.m'
    plot(((Start_Month:End_Month_empl)-Start_Month)./12 , Employment(Start_Month:End_Month_empl), 'k')
    ylabel('Employment')
    xlabel('Years')
    employment_data = Employment(Start_Month:End_Month_empl);
    %save -ascii 'employment_data.m' employment_data;
    
    figure(3)
    clf
    source 'PriceIndex.m'
    plot(PriceIndex(Start_Month+3:End_Month)-PriceIndex(Start_Month:End_Month-3), NumberOfHH-Employment(Start_Month+3:End_Month) + rand(1,End_Month-Start_Month-2)-0.5, 'k.')
    xlabel('Inflation')
    ylabel('Unemployment')
    inflation_data = PriceIndex(Start_Month+3:End_Month)-PriceIndex(Start_Month:End_Month-3);
    save -ascii 'inflation_data.m' inflation_data;
    Unempl_data = NumberOfHH-Employment(Start_Month+3:End_Month) + rand(1,End_Month-Start_Month-2)-0.5;
    save -ascii 'Unempl_data.m' Unempl_data
    
    figure(4)
    clf
    source 'Vacancies.m'
    plot(Vacancies(Start_Month:End_Month) + rand(1,End_Month-Start_Month+1)-0.5, NumberOfHH-Employment(Start_Month:End_Month) + rand(1,End_Month-Start_Month+1)-0.5, 'k.')
    xlabel('Vacancies')
    ylabel('Unemployment')
    Vacancie_data = Vacancies(Start_Month:End_Month) + rand(1,End_Month-Start_Month+1)-0.5;
    save -ascii 'Vacancie_data.m' Vacancie_data;
    Unempl_beveridge_data = NumberOfHH-Employment(Start_Month:End_Month) + rand(1,End_Month-Start_Month+1)-0.5;
    save -ascii 'Unempl_beveridge_data.m' Unempl_beveridge_data;
    
    figure(5)
    clf
    for t=-24:24
        correlations(t+25) = corr(Employment(Start_Month:End_Month),PriceIndex(Start_Month+t:End_Month+t) );
    end
    plot((-24:24)./3, correlations, 'k')
    xlabel('Lags (quarters)')
    ylabel('Correlation GDP with lagged Price Index')
    hold on
    load correlations_data
    plot(-8:8,correlations_data,'k:')
    load correlations_data_2
    plot(-8:8,correlations_data_2,'k--')
    legend('model','1947Q1-2007Q3','1947Q1-2010Q3','location','northwest')
    save -ascii 'correlations_model_data.m' correlations;
    save -ascii 'correlations_withoutFK_data.m' correlations_data;
    save -ascii 'correlations_withFK_data.m' correlations_data_2;

    figure(6)
    clf
    correlation_distribution = zeros();
    plot((-24:24)./3, correlations, 'k')
    xlabel('Lags (quarters)')
    ylabel('Correlation GDP with lagged Price Index')
    hold on
    load correlation_data_bootstrap_upper
    plot(-8:8,correlation_data_bootstrap_upper,'k:')
    load correlation_data_bootstrap_lower
    plot(-8:8,correlation_data_bootstrap_lower,'k:')
    save -ascii 'correlation_data_bootstrap_upper.m' correlation_data_bootstrap_upper;
    save -ascii 'correlation_data_bootstrap_lower.m' correlation_data_bootstrap_lower;

    
    figure(7)
    clf
    source 'FI_Size.m'
    connection = zeros( (End_Month-Start_Month+1) * size(FI_Size,2)  , 1);
    for t = Start_Month:End_Month
        connection((t-Start_Month)*size(FI_Size,2)+1 : (t-Start_Month+1)*size(FI_Size,2)) = FI_Size(t,:);
    end
    n=hist(connection,[1:max(connection)]);
    plot([1:max(connection)],n,'k')
    title('Firm Size')
    ylabel('absolute frequency')
    skewness_of_firm_size = skewness(connection)
    save -ascii 'Firm_Size_data.m' connection;
    
    figure(8)
    clf
    hold on
    source 'Money_FI_Mean.m'
    source 'Money_HH_Mean.m'
    plot((1*22-21:7*22)./22 , Money_HH_Mean(Start_Month*22-21:(Start_Month+6)*22),'k')
    plot((1*22-21:7*22)./22 , Money_FI_Mean(Start_Month*22-21:(Start_Month+6)*22),'k-.')
    xlim([ 1 7 ])
    ylabel('Aggr. Liquidity')
    xlabel('Months')
    legend('Households','Firms','location','northeast')
    Money_HH_Mean_data = Money_HH_Mean(Start_Month*22-21:(Start_Month+6)*22);
    Money_FI_Mean_data = Money_FI_Mean(Start_Month*22-21:(Start_Month+6)*22);
    save -ascii 'Money_HH_Mean_data.m' Money_HH_Mean_data;
    save -ascii 'Money_FI_Mean_data.m' Money_FI_Mean_data;

    figure(9)
    clf
    hold on
    source 'FI_Strategy.m'
    Amount_Of_Relative_Price_Changes = (FI_Strategy(Start_Month:End_Month,4) +  FI_Strategy(Start_Month:End_Month,3))/NumberOfFI;
    hist(Amount_Of_Relative_Price_Changes, 34)
    mean_P_change_in_percent = mean((FI_Strategy(Start_Month:End_Month,4) +  FI_Strategy(Start_Month:End_Month,3))/100)
    std_P_change_in_percent = std((FI_Strategy(Start_Month:End_Month,4) +  FI_Strategy(Start_Month:End_Month,3))/100)
    sort_PriceChanges = (sort((FI_Strategy(Start_Month:End_Month,4) +  FI_Strategy(Start_Month:End_Month,3))/100));
    median_P_change_in_percent = sort_PriceChanges(length(sort_PriceChanges)*0.5)
    skewness_P_changes_in_percent = skewness(sort_PriceChanges)
    save -ascii 'Amount_Of_Relative_Price_Changes.m' Amount_Of_Relative_Price_Changes;
    
    
   
    
    % How often does a wage cut at end of period occur?
    source 'Rel_EndOfPeriodWageCuts.m'
    Prob_WageCut_MoreThan5Percent = sum(sum(Rel_EndOfPeriodWageCuts(1000:end,:)>0.05)) / (4000*100)
    Prob_WageCut_MoreThan10Percent = sum(sum(Rel_EndOfPeriodWageCuts(1000:end,:)>0.1)) / (4000*100)