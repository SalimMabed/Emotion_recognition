

% Définir le répertoire contenant les dossiers de classe
dataDir = 'C:\Users\pc\Desktop\Emotion_recognition';

% Créer un datastore pour les images
imds = imageDatastore(dataDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% Compter le nombre d'images par classe
labelCount = countEachLabel(imds);
disp(labelCount);

% Nombre d'images à conserver par classe
numImagesPerClass = 25; % Choisissez le nombre d'images par classe que vous souhaitez garder

% Diviser les données en ensembles d'entraînement (80%) et de validation (20%) avec le même nombre d'images par classe
[imdsTrain, imdsValidation] = splitEachLabel(imds, numImagesPerClass, 'randomized');

% Redimensionner et normaliser les images
imageSize = [256 256 1]; 
imdsTrain.ReadFcn = @(filename)imresize(imread(filename), imageSize(1:2))/255;
imdsValidation.ReadFcn = @(filename)imresize(imread(filename), imageSize(1:2))/255;

% Définir l'architecture du CNN
layers = [
    imageInputLayer(imageSize)
    
    convolution2dLayer(3, 8, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2, 'Stride', 2)
    
    convolution2dLayer(3, 16, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2, 'Stride', 2)
    
    convolution2dLayer(3, 32, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2, 'Stride', 2)
    
    dropoutLayer(0.5) % Ajout de dropout
    
    fullyConnectedLayer(numel(unique(imds.Labels))) % Nombre de classes d'émotions
    softmaxLayer
    classificationLayer
    ];

% Spécifier les options d'entraînement
options = trainingOptions('adam', ...
    'InitialLearnRate', 0.001, ...
    'MaxEpochs', 2, ...
    'MiniBatchSize', 64, ...
    'ValidationData', imdsValidation, ...
    'ValidationFrequency', 30, ...
    'Verbose', false, ...
    'Plots', 'training-progress', ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.5, ...
    'LearnRateDropPeriod', 5);

% Entraîner le réseau
net = trainNetwork(imdsTrain, layers, options);

% Évaluer le modèle
YPred = classify(net, imdsValidation);
YValidation = imdsValidation.Labels;
accuracy = sum(YPred == YValidation) / numel(YValidation); % Calculer l'exactitude
disp(['Validation accuracy: ', num2str(accuracy)]);

% Afficher la matrice de confusion avec des détails
confMat = confusionmat(YValidation, YPred);
confusionChart = confusionchart(YValidation, YPred, 'Title', 'Confusion Matrix', ...
    'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');
disp('Confusion Matrix:');
disp(confMat);

% Enregistrer le modèle
save('modele_emotions_jaffe.mat', 'net');
