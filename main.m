%FOREX MARKET SIMULATOR
%----------------------
%USES HISTORIC TIME SERIES DATA TO
%1. PLOT SEVERAL CLASSICAL INDICATORS (RSI, MACD, ADX)
%2. MEASURE THE PERFORMANCE OF CHANNEL BREAKOUT

clear
close all
clc

margin = 5000; % $$
leverage = 50;
risk = 0.02; % risk per trade
trade = 10000; % $10000 is the minimum leverage*margin*risk %initial investment

rule1 = 70;
rule2 = 20;
adx_bishop = 40;
multL = 1;%+3.e-4;
multS = 1;%-3.e-4;

%[num,txt,raw] = xlsread('USDGB_1D_2000');
%[num,txt,raw] = xlsread('USDEUR_1D_2000');
%[num,txt,raw] = xlsread('EGPUSD_1D_2000');
%[num,txt,raw] = xlsread('CHFUSD_1D_2000');
[num,txt,raw] = xlsread('YNUSD_1D_2000');


L = length(num);
openp = num(1:L,4);
closep = num(1:L,5);
minp = num(1:L,6);
maxp = num(1:L,7);

%[maxp,minp,closep] = worked_example;

day = 1:L;

figure, subplot(3,1,1)
for i = 1:length(day)
    candleplot(day(i),openp(i),closep(i),minp(i),maxp(i));
    if i>=4 & i<=length(day)-1
        maxph = [transpose(maxp(i-3:i-1)) maxp(i+1)];
        minph = [transpose(minp(i-3:i-1)) minp(i+1)];
        swing(day(i),minp(i),maxp(i),minph,maxph)
    end
end
ylabel('price','fontsize',18)
xlim([0 day(end)])
grid on

[brkt_max55,brkt_min55] = channel_breakout(day,minp,maxp,rule1,'k');
[brkt_max20,brkt_min20] = channel_breakout(day,minp,maxp,rule2,'r');

%plots the ADX index
subplot(3,1,2)
adx = ADX(closep,minp,maxp);
plot(day(28:end),adx(2:end)) %the first adx should not be there...
hold on
ylabel('ADX/RSI','fontsize',18)
xlim([0 day(end)])
%plots line at ADX = 40
plot(day,40,'color','b')

%plots the RSI index
rsi = RSI(closep);
plot(day(14:end),rsi,'r') %the first adx should not be there...
plot(day,70,'color','r')
plot(day,30,'color','r')
hold on

%plots the MACD
subplot(3,1,3)
ema1 = EMA(closep,12);
ema2 = EMA(closep,26);

MACD = ema1(15:end)-ema2; % Moving Average Convergence/Divergence
plot(day(26:end),MACD)
ylabel('MACD','fontsize',18)


fill = 0;
long = 0;
short = 0;
gain = 0;
total = 0;
side = 0;
subplot(3,1,1)
pl = 0;
PL = 0;
stoploss = margin*risk;
%now let's trade!
for i=rule1+1:L-1 %starts from 56th day
    j1 = i-rule1+1;
    j2 = i-rule2;
    j3 = i-28;
    if side>0
        side = side+1;
    end
    if fill == 0
        if brkt_max55(j1)>multL*brkt_max55(j1-1) & adx(j3)>adx(j3-1) & (side>5|side==0) ...
                & adx(j3)>adx(j3-2) %go long
            fill = 1;
            long = 1;
            buyp = (1.+3.e-4)*openp(i+1);%maxp(i);
            stop = brkt_min20(j2);
            text(day(i),max(maxp),'long','color','g')
            display(['day #',num2str(i),' - get long @',num2str(buyp)])
            side = 0;
        end
        if brkt_min55(j1)<multS*brkt_min55(j1-1) & adx(j3)>adx(j3-1) & (side>5|side==0) ...
                & adx(j3)>adx(j3-2) %go short
            brkt_min55(j1);
            brkt_min55(j1-1);
            fill = 1;
            short = 1;
            sellp = (1-3.e-4)*openp(i+1); %minp(i);
            stop = brkt_max20(j2);
            text(day(i),min(minp),'short','color','g')
            display(['day #',num2str(i),' - get short @',num2str(sellp)])
            side = 0;
       end
    end
    if fill == 1
        if long == 1
            if brkt_min20(j2+1) < brkt_min20(j2) | ((adx(j3-1)>adx_bishop)&adx(j3)<adx(j3-1))
                sellp = (1.-3.e-4)*openp(i+1); %sells day after 
                gain = trade*(sellp - buyp);
                PL = PL + gain;
                if PL+margin<0
                    display('---------------------')
                    display('---------------------')
                    display('     BANKRUPT!!'      )
                    display('---------------------')
                    display('---------------------')
                    return
                end
                pl = pl + round(1.e4*(sellp - buyp));
                fill = 0;
                long = 0;
                text(day(i+1),min(minp),'exitL','color','g')
                display(['day #',num2str(i),' - exit long position @',num2str(sellp)])
                display(['       P/L = ',num2str(round(1.e4*(sellp - buyp))),' pips = $ ',num2str(gain)])
                side = side+1;
                stoploss = (margin+PL)*risk; %new stoploss based on current margin
            end
            vsellp = (1.-3.e-4)*openp(i+1); %sells day after 
            vgain = trade*(vsellp - buyp);
            if vgain < - stoploss %then it is a stop loss
                sellp = vsellp;
                gain = trade*(sellp - buyp);
                PL = PL + gain;
                if PL+margin<0
                    display('---------------------')
                    display('---------------------')
                    display('     BANKRUPT!!'      )
                    display('---------------------')
                    display('---------------------')
                    return
                end
                pl = pl + round(1.e4*(sellp - buyp));
                fill = 0;
                long = 0;
                text(day(i+1),min(minp),'stoploss','color','g')
                display(['day #',num2str(i),' - stop loss @',num2str(sellp)])
                display(['       P/L = ',num2str(round(1.e4*(sellp - buyp))),' pips = $ ',num2str(gain)])
                side = side+1;
                stoploss = (margin+PL)*risk; %new stoploss based on current margin
            end 
        elseif short == 1
            if brkt_max20(j2+1) > brkt_max20(j2) | ((adx(j3)>adx_bishop)&adx(j3+1)<adx(j3)) 
                buyp = (1.+3.e-4)*openp(i+1); %sells day after 
                gain = trade*(sellp - buyp);
                PL = PL + gain;
                if PL+margin<0
                    display('---------------------')
                    display('---------------------')
                    display('     BANKRUPT!!'      )
                    display('---------------------')
                    display('---------------------')
                    return
                end
                pl = pl + round(1.e4*(sellp - buyp));
                fill = 0;
                short = 0;
                text(day(i+1),max(maxp),'exitS','color','g')
                display(['day #',num2str(i),' - exit short position @',num2str(buyp)])
                display(['       P/L = ',num2str(round(1.e4*(sellp - buyp))),' pips = $ ',num2str(gain)])
                side = side+1;
                stoploss = (margin+PL)*risk; %new stoploss based on current margin
            end
            vbuyp = (1.-3.e-4)*openp(i+1); %sells day after 
            vgain = trade*(sellp - vbuyp);
            if vgain < - stoploss %then it is a stop loss
                buyp = vbuyp;
                gain = trade*(sellp - buyp);
                PL = PL + gain;
                if PL+margin<0
                    display('---------------------')
                    display('---------------------')
                    display('     BANKRUPT!!'      )
                    display('---------------------')
                    display('---------------------')
                    return
                end
                pl = pl + round(1.e4*(sellp - buyp));
                fill = 0;
                long = 0;
                text(day(i+1),min(minp),'stoploss','color','g')
                display(['day #',num2str(i),' - stop loss @',num2str(buyp)])
                display(['       P/L = ',num2str(round(1.e4*(sellp - buyp))),' pips = $ ',num2str(gain)])
                side = side+1;
                stoploss = (margin+PL)*risk; %new stoploss based on current margin
            end 
        end
    end
    if mod(i,365) == 0
        display('---------------')
        display(['Results after ',num2str(i/365), ' years'])
        display(['        P/L = ', num2str(pl), ' pips = $',num2str(PL)])
        display(['        Initial investment has become ', num2str(PL+margin)]) 
        display('---------------')
    end
end
display('-.-.-.-.-.-.-.-.-.-.-')
display(['P/L = ', num2str(pl), ' pips = $',num2str(PL)])
display(['Initial investment has become ', num2str(PL+margin)]) 


