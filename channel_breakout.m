%function channel_breakout
function [brkt_max,brkt_min] = channel_breakout(day,minp,maxp,rule,color)

L = length(day)-rule+1;
for i=1:L
    brkt_max(i) = max(maxp(i:i+rule-1));
    brkt_min(i) = min(minp(i:i+rule-1));
end

plot(day(rule:length(day)),brkt_max,'color',color,'linewidth',2)
hold on
plot(day(rule:length(day)),brkt_min,'color',color,'linewidth',2)



