% Lire une image depuis un fichier
img = imread('C:\Users\pc\Desktop\Emotion_recognition\Anger\KA.AN1.39.tiff'); % Chemin de l'image passé en argument

% Obtenir les dimensions de l'image
[height, width, numChannels] = size(img);

% Afficher les dimensions
fprintf('Dimensions de l''image :\n');
fprintf('Largeur : %d pixels\n', width);
fprintf('Hauteur : %d pixels\n', height);
fprintf('Nombre de canaux : %d\n', numChannels);
