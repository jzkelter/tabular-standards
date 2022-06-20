function ausgabe=skewness(X)
    
    ausgabe = ( sum((X-mean(X)).^3) / length(X) )  /  (  ((sum((X-mean(X)).^2))/length(X))^(3/2)  );