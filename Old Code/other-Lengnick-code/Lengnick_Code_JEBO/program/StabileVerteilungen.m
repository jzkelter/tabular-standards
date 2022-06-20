source 'FI_Size.m'    
    

figure(1)
clf
hold on

for i=1000:500:9500
    Start_Month = i;
    End_Month = i + 30;

    connection = zeros( (End_Month-Start_Month+1) * size(FI_Size,2)  , 1);
    for t = Start_Month:End_Month
        connection((t-Start_Month)*size(FI_Size,2)+1 : (t-Start_Month+1)*size(FI_Size,2)) = FI_Size(t,:);
    end
    
    n=hist(connection,[1:max(connection)]);
    plot([1:max(connection)],n./length(connection));
end



Start_Month = 1000;
End_Month = 10000;

connection = zeros( (End_Month-Start_Month+1) * size(FI_Size,2)  , 1);
for t = Start_Month:End_Month
    connection((t-Start_Month)*size(FI_Size,2)+1 : (t-Start_Month+1)*size(FI_Size,2)) = FI_Size(t,:);
end
n=hist(connection,[1:max(connection)]);
plot([1:max(connection)],n./length(connection),'k','linewidth',3)


disp('fertig');