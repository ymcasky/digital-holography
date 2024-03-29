% Funcion que usa los coeficientes de la transformada wavelet integrados en
% tiempo para obtener una matriz que contiene el exponente de Hurst
% estimado para cada bloque de pixeles de tama�o quad x quad. Usa s�lo las
% escalas indicadas para el c�lculo de la pendiente.

function Hurst = HurstIM(Ejs,escalas,quad)

idx = [find(isnan(Ejs)); find(isinf(Ejs))];
while(length(idx)>0)
    Ejs(idx) = Ejs(idx+1);
    idx = [find(isnan(Ejs)); find(isinf(Ejs))];
end

escalas = escalas';
s_Ejs = size(Ejs);
Hurst = zeros(s_Ejs(1:2));
A = [ones(length(escalas),1) escalas];
Mat = inv(A'*A)*A'; % Matriz para hacer cuadrados m�nimos
for k_fil = 1:s_Ejs(1)
    filas = k_fil : min(k_fil+quad-1,s_Ejs(1));
    for k_col = 1:s_Ejs(2)
        columnas = k_col : min(k_col + quad-1,s_Ejs(2));
        % Promedio las energ�as de los pixeles cercanos.
        v = sum(sum(Ejs(filas,columnas,escalas),1),2)/length(filas)/length(columnas);
        v = v(:);
        v = log2(v);
        coef = Mat*v;
        Hurst(k_fil,k_col) = (-coef(2)-1)/2;
    end
end


