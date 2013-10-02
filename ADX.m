function adx = ADX(closep,minp,maxp)

%first finds the DX
dx = DX(closep,minp,maxp);

L = length(dx)-13;

adx(1) = mean(dx(1:14));

for k = 2:L %=(previous ADX*13+today's DX)/14
    adx(k) = (adx(k-1)*13+dx(k+13))/14;
end

function dx = DX(closep,minp,maxp)

[mDI14 pDI14] = DI14(closep,minp,maxp);
DIdiff = abs(pDI14 - mDI14);
DIsum = pDI14 + mDI14;

dx = 100*DIdiff./DIsum;

function [mDI14 pDI14] = DI14(closep,minp,maxp)

L = length(closep)-13;
pDM14 = zeros(L,1);
mDM14 = zeros(L,1);
TR14 = zeros(L,1);
pDI14 = zeros(L,1);
mDI14 = zeros(L,1);

cont=1;
%evaluates pDI14 and mDI14 for the first (actually 2nd) day
for i=2:14
    pDM14(1) = pDM14(1) + pDM(minp(i),maxp(i),minp(i-1),maxp(i-1)); %+DM14
    mDM14(1) = mDM14(1) + mDM(minp(i),maxp(i),minp(i-1),maxp(i-1)); %-DM14    
    TR14(1) = TR14(1) + TR(minp(i),maxp(i),closep(i-1)); %True Value
end
pDI14(1) = pDM14(1)/TR14(1);
mDI14(1) = mDM14(1)/TR14(1);

%indicators for the rest of the chart
for k = 2:L
    pDM14(k) = pDM14(k-1) - pDM14(k-1)/14 + pDM(minp(k+13),maxp(k+13),minp(k+12),maxp(k+12));
    mDM14(k) = mDM14(k-1) - mDM14(k-1)/14 + mDM(minp(k+13),maxp(k+13),minp(k+12),maxp(k+12));
    TR14(k) = TR14(k-1) - TR14(k-1)/14 + TR(minp(k+13),maxp(k+13),closep(k+12));
    
    pDI14(k) = pDM14(k)/TR14(k);
    mDI14(k) = mDM14(k)/TR14(k);
end
pDI14 = 100*pDI14;
mDI14 = 100*mDI14;

function pdm = pDM(minp,maxp,minp_1,maxp_1)
 pdm = maxp - maxp_1; %today's high - yesterday's high
 mdm = minp_1 - minp; %yesterday's low - today's low
 
 if pdm < 0 & mdm < 0 %it is an inside day
     pdm = 0;
 elseif pdm == 0 & mdm == 0 %two identical days
     pdm = 0;
 elseif pdm > mdm %it is a +DM
     pdm = pdm;
 else %it is  a -DM
     pdm = 0;
 end
 
 function mdm = mDM(minp,maxp,minp_1,maxp_1)

 pdm = maxp - maxp_1; %today's high - yesterday's high
 mdm = minp_1 - minp; %yesterday's low - today's low
 
 if pdm < 0 & mdm < 0 %it is an inside day
     mdm = 0;
 elseif pdm == 0 & mdm == 0 %two identical days
     mdm = 0;
 elseif pdm > mdm %it is a +DM
     mdm = 0;
 else %it is  a -DM
     mdm = mdm;
 end
 
function tr = TR(minp,maxp,closep_1)
%evaluates True Value
tr = max(max(maxp-minp,maxp-closep_1),abs(minp-closep_1));
     
