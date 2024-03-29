% 
% A feature extraction unsupervised neural network for an environmental
% data set.
% Neural Network of Units Sensitive to Data Density
% 
% N: cantidad de neuronas
% X: muestras columna

function I = NNUSD_CNN(X,Nnnusd,Ncnn,epocasNNUSD,inicioCNN)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constantes
% sigm: compresión de la función sigmoidea (Logistic)
sigm = 2;
% sigmac: umbral
sigmac = 0.1;
% beta1: factor lineal de la función que genera el factor local de update
beta1 = 0.01;
% taualpha: tau con que cae alpha en pasos
taualpha = 10000;

% M: Dimension de vectores de entrada y D: Cantidad de vectores de entrada
[M D] = size(X);
factoralpha = exp(-1/taualpha);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inicialización de:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NNUD
% pesos sinápticos
in = randperm(D);
W = X(:,in(1:Nnnusd));
% umbrales de distancia
sigma0 = 0.01;
sigmas = sigma0 * ones(1,Nnnusd);
% factor de aprendizaje
alpha = 0.1;
alphaCNN = alpha;
% salida
I = zeros(1,D);
% Cosas en cero
phi = zeros(1,Nnnusd);
inhib_links = zeros(1,Nnnusd-1);
inhib = zeros(1,Nnnusd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CNN
% pesos sinápticos
Wcnn = rand(Nnnusd,Ncnn);
% sesgos
sesgos = ones(1,Ncnn);
stepCNN = Ncnn;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Aprendizaje

paso = 1;
while paso < epocasNNUSD*D
   
    % Se toma una muestra al azar k
    k = ceil(rand * D);
    x = X(:,k);
    
    % Se calculan las distancias
    resta = W - repmat(x,[1 Nnnusd]);
    dist = sqrt(sum(resta.^2));
    
    % Se calculan las salidas de la red
    DeltaDist = sigmas - dist;
    y = 1./(1 + exp(- sigm * DeltaDist));
    
    % Factores de update locales
    phi = 1 - beta1 * (1 - y);
    
    % Cálculo de inhibiciones
    inhib_links = double(sigmas(1:end-1) < sigmac);
    inhib = [1 cumprod(inhib_links)];
    
    % Se calculan las actualizaciones
    DeltaW = alpha * repmat(phi .* inhib, [M,1]) .* resta;
    W = W - DeltaW;
    
    % Actualización de vecindarios (sigmas)
    DeltaSigmas = -alpha * phi .* DeltaDist;
    sigmas = sigmas + DeltaSigmas;
    
    % Actualización de alpha
    alpha = alpha * factoralpha;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CNN
    if paso > inicioCNN * D
        y = y';

        % Se calculan las distancias
        restacnn = Wcnn - repmat(y,[1 Ncnn]);
        dist = sqrt(sum(restacnn.^2));
        dist = sesgos.*dist/stepCNN;
        
        % Winner takes all
        [c I(k)] = min(dist);
        DeltaCNN = alphaCNN * restacnn(:,I(k));
        Wcnn(:,I(k)) = Wcnn(:,I(k)) - DeltaCNN;
        
        % Actualización del sesgo
        stepCNN = stepCNN + 1;
        sesgos(I(k)) = sesgos(I(k)) + 1;
        
        alphaCNN = alphaCNN * factoralpha;
        
    end
    
    paso = paso + 1;
    
end