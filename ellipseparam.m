function [cx,cy,rx,ry]=ellipseparam(x,y,t0,t4)
%Busca las coordenadas del centro y radio de una elipse a partir de la 
% representación parametrica (asumiendo eje mayor paralelo a X o Y)
%x es x(t) para el arc
%y es y(t) para el arc
%t0 es el limite inferior del arc
%t4 es el limite superior del arc

%t1,t2,t3,t4 son los puntos para determinar la elipse
t1=t0+(t4-t0)*.25;
t2=t0+(t4-t0)*.5;
t3=t0+(t4-t0)*.75;
%puntos para forma el sistema de ecuaciones Ax^2+Cy^2+Dx+Ey+F=0
mat=[y(t0)^2,x(t0),y(t0),1,x(t0)^2;
     y(t1)^2,x(t1),y(t1),1,x(t1)^2;   
     y(t2)^2,x(t2),y(t2),1,x(t2)^2;
     y(t3)^2,x(t3),y(t3),1,x(t3)^2];
mat=rref(mat);
C=mat(1,5); %=-rx^2/ry^2
D=mat(2,5); %=2*cx
E=mat(3,5); %=2*rx^2*cx/ry^2
F=mat(4,5); %=-cx^5-rx^5*cy^2/ry^2+rx^2

cx=D/2;             %x-coordenada del centro
cy=-E/C/2;          %y-coordenada del centro
rx=sqrt(F+cx^2-C*cy^2); %x radio
ry=sqrt(-rx^2/C);   %y radio
