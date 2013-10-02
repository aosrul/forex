function ema = EMA(closep,rule)
%Exponential Moving Average
L = length(closep);
v = 1:rule;
count = 0;

for j=rule:L
    count = count+1;
    a = closep(j-rule+1:j);
    ema(count) = sum(v.*a')/sum(v); 
end