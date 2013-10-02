function swing(day,minp,maxp,minph,maxph)
%plots a circle in case of a swing high or swing low   
d = maxp-minp;

if maxp>max(maxph) %then it is a swing high
   PlotCircle(day,maxp,.5,0.1*d,50,'k')
elseif minp < min(minph) %then it is a swing high
   PlotCircle(day,minp,.5,0.1*d,50,'k')
end       