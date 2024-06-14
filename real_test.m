function emotion_recognition_gui
    % Créer la fenêtre de l'interface utilisateur
    fig = uifigure('Name', 'Reconnaissance des Émotions', 'Position', [100 100 900 600]);

    % Créer une grille pour l'interface
    gl = uigridlayout(fig, [2, 2]);
    gl.RowHeight = {'1x', 50};
    gl.ColumnWidth = {'4x', '1x'};

    % Zone d'affichage de l'image à gauche
    ax = uiaxes(gl, 'Position', [50 100 400 400]);
    ax.Layout.Row = 1;
    ax.Layout.Column = 1;

    % Créer une zone de texte pour afficher les émotions détectées à droite de l'image
    emotionText = uitextarea(gl, 'Position', [500 100 400 400]); % Modification de la largeur de la zone de texte
    emotionText.Layout.Row = [1 2]; % Utiliser les deux rangées disponibles
    emotionText.Layout.Column = 2;
    emotionText.FontSize = 12;
    emotionText.Editable = false;


    % Créer une sous-grille pour les boutons en bas à gauche
    buttonGrid = uigridlayout(gl, [1, 3]);
    buttonGrid.Layout.Row = 2;
    buttonGrid.Layout.Column = 1;
    buttonGrid.ColumnWidth = {'1x', '1x', '1x'};

    % Bouton pour importer une image
    btnImport = uibutton(buttonGrid, 'push', 'Text', 'Importer une image', ...
        'ButtonPushedFcn', @(btn,event) importImageCallback());
    btnImport.Layout.Row = 1;
    btnImport.Layout.Column = 1;

    % Bouton pour détecter l'émotion
    btnDetect = uibutton(buttonGrid, 'push', 'Text', 'Détecter l''émotion', ...
        'ButtonPushedFcn', @(btn,event) detectEmotionCallback());
    btnDetect.Layout.Row = 1;
    btnDetect.Layout.Column = 2;

    % Bouton pour arrêter l'exécution
    btnStop = uibutton(buttonGrid, 'push', 'Text', 'Stop', ...
        'ButtonPushedFcn', @(btn,event) stopCallback());
    btnStop.Layout.Row = 1;
    btnStop.Layout.Column = 3;

    % Variables globales
    global img;
    global img_resized;
    global net;
    global running;

    % Charger le modèle pré-entraîné
    load('modele_emotions_jaffe.mat');

    % Drapeau pour indiquer si l'application est en cours d'exécution
    running = true;

    function importImageCallback()
        [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.tiff', 'Images (*.jpg, *.jpeg, *.png, *.tiff)'});
        if isequal(file, 0)
            disp('Aucun fichier sélectionné');
        else
            imgPath = fullfile(path, file);
            img = imread(imgPath);
            imshow(img, 'Parent', ax);
            title(ax, 'Image importée');
        end
    end

    function detectEmotionCallback()
        if isempty(img)
            uialert(fig, 'Veuillez importer une image avant de détecter l''émotion.', 'Avertissement');
            return;
        end

        % Vérifier si l'image est déjà en niveaux de gris
        if size(img, 3) == 1
            img_gray = img; % L'image est déjà en niveaux de gris
        else
            % Convertir en niveaux de gris
            img_gray = rgb2gray(img);
        end

        % Redimensionner l'image
        imageSize = [256 256];
        img_resized = resizeImageWithAspect(img_gray, imageSize);

        % Normaliser l'image
        img_normalized = double(img_resized) / 255;

        % Adapter la taille de l'image pour le réseau
        img_normalized = reshape(img_normalized, [256 256 1]);

        % Classification de l'image et obtention des probabilités
        [YPred, scores] = classify(net, img_normalized);

        % Afficher les pourcentages d'appartenance à chaque classe
        classes = net.Layers(end).Classes; % Obtenir les classes
        resultStr = '';
        for i = 1:numel(classes)
            resultStr = [resultStr, sprintf(' %s: %.2f%%\n', classes(i), scores(i) * 100)];
        end

        % Afficher le résultat dans la zone de texte à droite de l'image
        resultStr = [resultStr, sprintf('\n \n \n ---Emotion prédite : %s---', char(YPred))];


        emotionText.Value = resultStr;
        
        % Changer la couleur du texte en fonction de l'émotion prédite
        switch char(YPred)
            case 'Disgust'
                emotionText.FontColor = [0.1, 0.5, 0.5]; 
            case 'Sadness'
                emotionText.FontColor = [0, 0, 1]; 
            case 'Anger'
                emotionText.FontColor = [1, 0, 0]; 
            case 'Happiness'
                emotionText.FontColor = [0, 1, 0];
            case 'Neutral'
                emotionText.FontColor = [0, 0, 0]; 
            case 'Fear'
                emotionText.FontColor = [0, 0, 0]; 
            otherwise
                emotionText.FontColor = [1, 0.5, 0]; 
        end

        % Afficher l'image
        imshow(img_resized, 'Parent', ax);
        title(ax, 'Image redimensionnée et recadrée');
    end

    function stopCallback()
        running = false;
        delete(fig);
    end

    function img_resized = resizeImageWithAspect(img, targetSize)
        % Calculer le rapport de l'image
        [h, w] = size(img);
        targetAspect = targetSize(2) / targetSize(1);
        imgAspect = w / h;

        if imgAspect > targetAspect
            % Image plus large que la cible
            newWidth = round(targetAspect * h);
            xStart = floor((w - newWidth) / 2) + 1;
            imgCropped = img(:, xStart:xStart+newWidth-1);
        else
            % Image plus étroite que la cible
            newHeight = round(w / targetAspect);
            yStart = floor((h - newHeight) / 2) + 1;
            imgCropped = img(yStart:yStart+newHeight-1, :);
        end

        % Redimensionner l'image
        img_resized = imresize(imgCropped, targetSize);
    end
end
