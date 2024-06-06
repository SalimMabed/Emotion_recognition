% Directory containing the images (same directory as the script)
directory = fileparts(mfilename('fullpath'));

% Dictionary mapping abbreviated emotion names to complete names
emotion_names = containers.Map({'NE', 'HA', 'SA', 'SU', 'AN', 'DI', 'FE'}, ...
                               {'Neutral', 'Happiness', 'Sadness', 'Surprise', 'Anger', 'Disgust', 'Fear'});

% Create directories for each emotion if they do not exist
emotion_keys = keys(emotion_names);
for i = 1:length(emotion_keys)
    emotion_full = emotion_names(emotion_keys{i});
    if ~exist(fullfile(directory, emotion_full), 'dir')
        mkdir(fullfile(directory, emotion_full));
    end
end

% Loop through all files in the directory
files = dir(fullfile(directory, '*.tiff'));
for i = 1:length(files)
    filename = files(i).name;

    % Extract emotion from the filename
    emotion_abbr = filename(4:5);
    if isKey(emotion_names, emotion_abbr)
        emotion_full = emotion_names(emotion_abbr);

        % Construct source and destination paths
        src_path = fullfile(directory, filename);
        dst_path = fullfile(directory, emotion_full, filename);

        % Copy the image to the corresponding emotion directory
        copyfile(src_path, dst_path);
    end
end
