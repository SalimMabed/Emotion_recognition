% Charger le modèle depuis le fichier modele_emotions.mat
load('modele_emotions.mat');

% Sélectionner la couche de convolution que vous souhaitez visualiser
convLayer = net.Layers(2); % Remplacez par le numéro de la couche correspondante

% Obtenir les poids des filtres
filters = convLayer.Weights;
disp(filters);

% Afficher les filtres
figure;
for i = 1:size(filters, 4)
    subplot(4, 5, i);
    imshow(filters(:, :, 1, i), []);
    title(['Filtre ', num2str(i)]);
end
