function sma = SMA(closep,rule)
%Simple Moving Average
L = length(closep);

count = 0;
for j=rule:L
    count = count+1;
    SMA(count) = mean(closep(j-rule+1:j)); 
end