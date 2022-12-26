function x=piece(b)
global table
x=1;
while(x<size(table,1)&& b>table{x,4})
    x=x+1;
end
