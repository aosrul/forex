function candleplot(day,open,close,min,max)

plotrect = 0;

line([day,day],[min,max])
line([day-.125,day+.125],[max,max])
line([day-.125,day+.125],[min,min])
hold on

if open>close
    lc = close;
    fc = 'r';
    plotrect = 1;
elseif open<close
    lc = open;
    fc = 'g';
    plotrect = 1;    
else
    line([day-.125,day+.125],[open,open])
end

if plotrect==1
    rectangle('position',[day-.125,lc,0.25,abs(close-open)+1.e-6],'facecolor',fc)
end
