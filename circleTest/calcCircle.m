counter = 0:0.03:10*pi;
counterSize = size(counter);

xDiff=zeros(1,counterSize(2));
yDiff=zeros(1,counterSize(2));

amplitude = 20;

x=amplitude*sin(counter);
y=amplitude*cos(counter);

xCount = size(x);
yCount = size(y);

for i=1:1:xCount(2)-1
  xDiff(i) = x(i+1)-x(i);  
end

for i=1:1:yCount(2)-1
  yDiff(i) = y(i+1)-y(i);
end