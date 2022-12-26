%Iteración para encontrar la localización y angulo de la colisión

%n actual iteración o colisión
%xo es el valor xo de última intersección
%yo es el valor yo de última intersección
%ao es el angulo de última intersección, respecto a la horizontal
%data tiene 4 columnas:  t, anguloh horizontal, angulo incidente,Num

z=[];

for j=1:size(table,1)

    fun=inline([num2str(tan(ao)),'*(',char(table{j,1}),'-',num2str(xo),')-(',char(table{j,2}),')+',num2str(yo)]);    
    a=table{j,3};   %Limite inferior de t
    b=table{j,4};   %Limite superior de t
    
    % Cuando el punto esta sobre la línea
    if table{j,5}==1
       root=fzero(fun,(a+b)/2);     % Usa el valor promedio de a y b para iniciar
       if root>=a & root<=b         % Verifica si existe una raiz o solución
           z=[z,root];              % si lo hay agrega una posible solución a z
       end

       
    % Cuando el punto esta sobre la zona curva o eliptica
    % xx1,xx2,yy1,yy2 son coordenadas de la intersección de la línea con el arco del círculo
    elseif table{j,5}==2    
         %  busca las coordenadas X Y del centro del radio del circulo
        [cx,cy,rx,ry]=ellipseparam(table{j,1},table{j,2},table{j,3},table{j,4});
        hit=0;  %indica si la trayectoria esta sobre el arco o no
        if abs(mod(ao,pi)-pi/2)<10^-10
            if cx-rx<=xo & xo<=cx+rx
                hit=1;
                xx1=xo;
                xx2=xo;
                yy1=-sqrt(rx^2*(1-xx1^2/ry^2));
                yy2=sqrt(rx^2*(1-xx2^2/ry^2));
            end
        else
            m=tan(ao);  %encuentra la pendiente de la trayectoria
            b0=-m*xo+m*cx+yo-cy;   % y-intercepción de la trayectoria      y-(yo-cy)=m(x-(xo-cx))
            aq=rx^2*m^2+ry^2;      % a en la formula cuadratica para la raiz o solución
            bq=2*m*b0*rx^2;        % b en la formula cuadratica para la raiz o solución
            cq=b0^2*rx^2-rx^2*ry^2;% c en la formula cuadratica para la raiz o solución
            if bq^2-4*aq*cq>=0     % Verifica el determinante para ver si encuentra
                hit=1;             % trajectory hits arc
                xx1=(-bq-sqrt(bq^2-4*aq*cq))/2/aq;   %x-coordenada de intersección 1
                xx2=(-bq+sqrt(bq^2-4*aq*cq))/2/aq;   %x-coordenada de intersección 2
                yy1=m*xx1+b0; %y-coordenada de intersección 1
                yy2=m*xx2+b0; %y-coordenada de intersección 2
            end
        end
        if hit  % Si la trayectoria se encuentra sobre la curva del arco
            lt=mod(atan2((table{j,2}(table{j,3})-cy)/ry,(table{j,1}(table{j,3})-cx)/rx),2*pi);   %angulo del centro al punto inferior
            ut=mod(atan2((table{j,2}(table{j,4})-cy)/ry,(table{j,1}(table{j,4})-cx)/rx),2*pi);   %angulo del centro al punto superior

            %Si el angulo es menor que 0 o mayor a 2pi, entonces debe ir de 0 a 2pi
            if abs(lt)<.001 | abs(lt-2*pi)<.001
                if table{j,2}((b-a)/4+a)>table{j,2}(a)
                    lt=0;
                else  
                    lt=2*pi;
                end
            end
            if abs(ut)<.001 | abs(ut-2*pi)<.001
                if table{j,2}((a-b)/4+b)>table{j,2}(b)  
                    ut=0;
                else 
                    ut=2*pi;
                end
            end
            
            
            % Casos especiales: Si el arco es semicirculo e intersecta con una línea vertical
            if abs(table{j,1}(a)-table{j,1}(b))<.001 & abs(cx+rx - table{j,1}((a+b)/2))<.001 %x-coordinate of arc endpoints are same and midpoint of arc has x-coordinate a distance of 1 radius to the right
                if lt>pi    %convert lt angle to -pi/2 if it is 3pi/2
                    lt=lt-2*pi;
                end
                
                alpha=atan2(yy1/ry,xx1/rx);
                if abs(alpha)<pi/2      
                    z=[z,abs(alpha-lt)/pi*(b-a)+a];   
                end
                alpha=atan2(yy2/ry,xx2/rx);
                if abs(alpha)<pi/2     
                    z=[z,abs(alpha-lt)/pi*(b-a)+a]; 
                end                

            else   
               xmid = table{j,1}((table{j,3} + table{j,4})/2);
               ymid = table{j,2}((table{j,3} + table{j,4})/2);
               %beta es el angulo del punto medio, medido desde el centro del arco
               beta = mod((atan2((ymid-cy)/ry ,(xmid-cx)/rx)),2*pi); 
               uswitch = 0;
               lswitch = 0;
               if lt < ut
                    if (lt >= beta || beta >= ut)
                        ut = ut - 2*pi; 
                        uswitch = 1;
                    end
                end
                if ut < lt
                    if (ut >= beta || beta >= lt)
                        lt = lt - 2*pi;   
                        lswitch = 1;
                    end
                end
                %alpha es uno de los dos angulos de intersección medidos desde el centro del arco
                alpha=mod(atan2(yy1/ry,xx1/rx),2*pi); 
                
                %if switch esta por encima o debajo ajusta el alpha
                if uswitch == 1
                    if alpha > ut + 2*pi
                        alpha = alpha - 2*pi;
                    end
                end
                if lswitch == 1
                    if alpha > lt + 2*pi
                        alpha = alpha - 2*pi;
                    end
                end
                
                if lt<=ut & lt<=alpha & alpha<=ut  
                    z=[z,(alpha-lt)/(ut-lt)*(b-a)+a];    
                end
                if lt>=ut & lt>=alpha & alpha>=ut   
                    z=[z,(alpha-ut)/(lt-ut)*(a-b)+b];   
                end
                %2nd Busca una segunda raiz, por si haya otra intersección
                alpha=mod(atan2(yy2/ry,xx2/rx),2*pi);
                %if switch esta por encima o debajo ajusta el alpha
                if uswitch == 1
                    if alpha > ut + 2*pi
                        alpha = alpha - 2*pi;
                    end
                end
                if lswitch == 1
                    if alpha > lt + 2*pi
                        alpha = alpha - 2*pi;
                    end
                end
                
                if lt<=ut & lt<=alpha & alpha<=ut   
                    z=[z,(alpha-lt)/(ut-lt)*(b-a)+a];   
                end
                if lt>=ut & lt>=alpha & alpha>=ut  
                    z=[z,(alpha-ut)/(lt-ut)*(a-b)+b];   
                end
            end
        end

    % Para cuando esta sobre el arco de curvatura
    else
        root=fzero(fun,a);  %use fzero para encontrar el pto medio
        if root>a & root<b  % Si la raíz esta entre límite inferior y superior
            z=[z,root]; %agrega la raíz a la lista  de soluciones
        end
        root=fzero(fun,b);  %use fzero para encontrar el pto medio
        if root>a & root<b  % Si la raíz esta entre límite inferior y superior
            z=[z,root]; %agrega la raíz a la lista  de soluciones
        end
        if fun(a)*fun(b)<0  
            root=fzero(fun,[a,b]);  
        else    
            root=fzero(fun,(a+b)/2);    %use fzero para encontrar el pto medio
        end
        if root>a & root<b  % Si la raíz esta entre límite inferior y superior
            z=[z,root]; 
            if fun(root-(b-a)/100)*fun(a)<0 
                root=fzero(fun,[a,root-(b-a)/20]);  
                z=[z,root]; 
            end
            if fun(root+(b-a)/100)*fun(b)<0 
                root=fzero(fun,[root+(b-a)/20,b]); 
                z=[z,root]; 
            end
        end
    end
end
zzz=z;  

remove=[];  %Elimina las incorrectas
%remueve las raices que van en la dirección equivocada  o que pasan de la
%barrera del contorno del billar 
if abs(mod(ao,pi)-pi/2)<10^-2  
    for k=1:size(z,2)
        if (table{piece(z(k)),2}(z(k))-yo)*sin(ao)<0    %Si la raíz encontrada corresponde a una dirección opuesta
            remove=[remove,k];
        end
    end
else
    for k=1:size(z,2)   
        if (table{piece(z(k)),1}(z(k))-xo)*cos(ao)<-5*10^-6    %Si la raíz encontrada corresponde a una dirección opuesta
            remove=[remove,k];
            
        end
    end
end

z(remove)=[];

zz=z; 
    
if n~=1
    z=z(find(abs(z-data(n-1,1))>2*10^-4));  %remueve la raíz
end

% Si no encuentra una solución, aumenta la tolerancia  a la raíz
if size(z,2)==0    
    z=zz;
    z=z(find(abs(z-data(n-1,1))>10^-8)); 
end
    
% Encuentra el valor de t que tiene la minima distancia desde punto anterior


if size(z,2)~=1
    distance=zeros(1,size(z,2));
    for k=1:size(z,2)
        i=piece(z(k));
        distance(1,k)=(xo-table{i,1}(z(k))).^2+(yo-table{i,2}(z(k))).^2;
    end
    distance(find(distance<10^-6))=inf;   %elimina alguna valor que no da movimiento 
    if length(find(distance==min(distance)))~=1
        k=find(distance==min(distance));
        data(n,1)=z(k(1));
    else
       try
           data(n,1)=z(find(distance==min(distance)));  %Almacena el vaor correcto para este iteración
       catch
       end
   end
else
    data(n,1)=z;  %Almacena el vaor correcto para este iteración
end
told=data(n,1);  
data(n,4)=piece(told);
newpiece=data(n,4);  


if (told-table{newpiece,3}<2*10^-4 | table{newpiece,4}-told<2*10^-4) & (abs(table{newpiece,1}(table{newpiece,3})-table{newpiece,1}(table{newpiece,4}))>10^-8 | abs(table{newpiece,2}(table{newpiece,3})-table{newpiece,2}(table{newpiece,4}))>10^-8)
    % colisiona con la esquina detectada
    j=1;    
    x=inline(char(diff(eval(char(table{newpiece,1})),t)));   %x'(t)
    y=inline(char(diff(eval(char(table{newpiece,2})),t)));   %y'(t)
        
    if told-table{newpiece,3}<2*10^-4  
        while abs(table{j,1}(table{j,4})-table{newpiece,1}(told))>5*10^-4  | abs(table{j,2}(table{j,4})-table{newpiece,2}(told))>5*10^-4  
            j=j+1;   %Trata de buscar un par en la otra esquina 
        end

        xj=inline(char(diff(eval(char(table{j,1})),t)));        %x'(t)
        yj=inline(char(diff(eval(char(table{j,2})),t)));        %y'(t) 
            
        % Calcula el ángulo de reflexión para las fronteras fuera de la esquinas            
        data(n,2)=atan2(y(table{newpiece,3}),x(table{newpiece,3}))+atan2(yj(table{j,4}),xj(table{j,4}))-ao;

    else
        while abs(table{j,1}(table{j,3})-table{newpiece,1}(told))>5*10^-4 | abs(table{j,2}(table{j,3})-table{newpiece,2}(told))>5*10^-4
            j=j+1;  %Trata de buscar un par en la otra esquina 
        end
            
        xj=inline(char(diff(eval(char(table{j,1})),t)));        %x'(t) 
        yj=inline(char(diff(eval(char(table{j,2})),t)));        %y'(t) 
 
        % Calcula el ángulo de reflexión para las fronteras fuera de la esquinas
        data(n,2)=atan2(y(table{newpiece,4}),x(table{newpiece,4}))+atan2(yj(table{j,3}),xj(table{j,3}))-ao;

            
    end
    data(n,2)=mod(data(n,2),2*pi); % cambia el angulo de reflexión al inicio
    data(n,3)=NaN;                  % Coloca nan cuando no encuentra una intersección
else
    % No encuentra punto de colisión
    at=subs(deriv(newpiece),told);  % angulo de la línea tangente en el punto de colisión
    data(n,2)=mod(-ao+2*at,2*pi);   % ángulo horizontal
    data(n,3)=mod(-ao+pi/2+at,pi);  % angulo incidente
    if data(n,3)>pi/2
        data(n,3)=data(n,3)-pi;  %angulo incendente sobre intervalo correcto
    end
end
if data(n,2)>pi
    data(n,2)=data(n,2)-2*pi;  % Corrige el angulo horizontal
end
