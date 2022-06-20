function corr = correlation(X,Y)
    
    corr = sum((X-mean(X)).*(Y-mean(Y)))  /  ((length(X)-1)*std(X)*std(Y));