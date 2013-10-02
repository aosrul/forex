function rsi = RSI(closep)

L = length(closep);

up = zeros(1,L);
down = zeros(1,L);
for i=2:L
    if closep(i) > closep(i-1)
        up(i) = closep(i)-closep(i-1);
    elseif closep(i) < closep(i-1)
        down(i) = closep(i-1)-closep(i);
    end
end

count = 0;
for j=14:L
    count = count+1;
    RS = sum(up(j-13:j))/sum(down(j-13:j));
    rsi(count) = 100 - 100/(1+RS); %from Wilder's book
end