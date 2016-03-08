function p = myFilterFunc(x)
%MYFILTERFUNC checks the color in a window and returns the most frequent
%color
%
% Copyright: Omer Demirel (omerddd@gmail.com), University of Zurich, 2015
if range(x(:)) == 0
    p = x(1);                %# if one color, return it
else
    p = mode(x(x~=0));       %# else, return the most frequent color
end
end
