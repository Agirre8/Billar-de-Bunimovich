clear all, close all, clc, warning off

% define punto de inicio de la bolilla (xi,yi,angi)
xi = 1;             % xi = en el centro del Estadio de Binouvich
yi = 1;             % yi = en el centro del Estadio de Binouvich
angi = 30;          % Angulo respecto a la horizontal
NR = 100;            % Numero de rebotes en las paredes del Estadio Binuovich

rad = 1;      % Radio de la zona curva del Estadio de Binouvich
Lon = 6;      % Longitude de la zona recta


%% Visualiza el Estadio de Binouvich %%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   NO CAMBIAR hacia adelante  %%%%%%
%%% Visualización la forma del Billar Binuovich

global table
syms t

w = Lon;
rx = rad;
ry = rx;
to = 0;
table = [];
length=rx*quad(inline(['1+',num2str((ry^2-rx^2)/rx^2),'*sin(t).^2']),0,2*pi)/2;
	
table{1,3}=to;
table{1,4}=table{1,3}+w;
table{1,5}=1;
table{2,3}=table{1,4};
table{2,4}=table{2,3}+length;
table{2,5}=2;
table{3,3}=table{2,4};
table{3,4}=table{3,3}+w;
table{3,5}=1;
table{4,3}=table{3,4};
table{4,4}=table{4,3}+length;
table{4,5}=2;

table{1,1}=inline(['-t+',num2str(w/2+table{1,3})]);
table{1,2}=inline(num2str(-ry),'t');
table{2,1}=inline([num2str(-w/2),'+',num2str(rx),'*sin(pi+(t-',num2str(table{2,3}),')/',num2str(length/pi),')']);
table{2,2}=inline([num2str(ry),'*cos(pi+(t-',num2str(table{2,3}),')/',num2str(length/pi),')']);
table{3,1}=inline(['t-',num2str(table{3,3}+w/2)]);
table{3,2}=inline(num2str(ry),'t');
table{4,1}=inline([num2str(w/2),'-',num2str(rx),'*sin((t-',num2str(table{4,3}-length),')/',num2str(length/pi),')']);
table{4,2}=inline([num2str(-ry),'*cos((t-',num2str(table{4,3}-length),')/',num2str(length/pi),')']);

% Visualiza el contorno del Billar de Binouvich
for n=1:size(table,1)
    temp = ezplot(table{n,1},table{n,2},[table{n,3},table{n,4}]);   %Grafica cada segmento del contorno del Estadio de Binouvich
    hold on
    set(temp,'LineW',3,'color','b') 
end

% Visualiza el punto inicial y su orientación de águlo respecto a la horizontal
quiver(xi,yi,0.5*cosd(angi),0.5*sind(angi),'LineW',3,'color','r')
hold on
plot(xi,yi,'o','LineWidth',1,...
    'MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor','r')
grid on, box on
title('Billar de Binouvich')
hold off

%% Realiza las iteraciones por cada rebote
xo = xi; 
yo = yi;
ao = angi*pi/180;
nmax = NR;
initcond =[xo,yo,ao];

% Evalua la derivada (tangente de la curva) en función del contorno de
% forma simbolica
deriv=sym(zeros(size(table,1),1));
for m=1:size(table,1)
    x=eval(char(table{m,1}));   % Evalua la funciín en el contorno x(t)
    y=eval(char(table{m,2}));   % Evalua la funciín en el contorno y(t)
    deriv(m,1)=atan(diff(y,t)/diff(x,t));
end
data=zeros(nmax,4);     % Inicializa la matriz data de puntos de rebote

n=1;    %Inicializa las iteraciones
calculo %calcula la primera iteración, sobre la condición inicial
derivComp=zeros(nmax,4);  

%Bucle que calcula los rebotes con la funcion calculo
for m = 1:nmax
    derivComp(n,1)=xo;    %x, y, pieces and angular components used in the derivative function
    derivComp(n,2)=yo;
    derivComp(n,3)=data(n,3);
    derivComp(n,4)=data(n,4);
    n=n+1;

    xo=table{data(n-1,4),1}(data(n-1,1));       % x en la intersección
    yo=table{data(n-1,4),2}(data(n-1,1));       % y en la itersección
    ao=data(n-1,2);             %angulo de la intersección   
    
    try
        calculo     % Busca la localización y angulo de la sgte colisión
    catch           % si se produce un error continua buscando rebotes 
    end    
end

%%
% Visualiza los rebotes
line([initcond(1),table{data(1,4),1}(data(1,1))],...
    [initcond(2),table{data(1,4),2}(data(1,1))],'Linew',1.2,'color','k')   
hold on
plot(table{data(1,4),1}(data(1,1)),table{data(1,4),2}(data(1,1)),'o','LineWidth',1,...
    'MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','c')
text(table{data(1,4),1}(data(1,1)),table{data(1,4),2}(data(1,1)),num2str(1),'FontSize',8)


for n=2:size(data,1)
    line([table{data(n-1,4),1}(data(n-1,1)),table{data(n,4),1}(data(n,1))],...
        [table{data(n-1,4),2}(data(n-1,1)),table{data(n,4),2}(data(n,1))],...
        'Linew',1.2,'color','k') 
    hold on 
    plot(table{data(n,4),1}(data(n,1)),table{data(n,4),2}(data(n,1)),'o','LineWidth',1,...
    'MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','c')
text(table{data(n,4),1}(data(n,1)),table{data(n,4),2}(data(n,1)),num2str(n),'FontSize',8)
title(['Billar de Binouvich ',' Rebote N° ',num2str(n-1)],'FontSize',15,'color','k')
pause(0.5)
end
