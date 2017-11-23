clear; clc
% You need to download the WARD dataset to current folder.
% 
folder = './WARD1.0/';
addpath('./natsortfiles/')

if ~(7==exist(folder,'dir'))
    url = 'https://people.eecs.berkeley.edu/~yang/software/WAR/WARD1.zip';
    filename = 'WARD1.zip';
    disp('Downloading database...')
    websave(filename,url);
    disp('Extracting files...')
    try
        unzip(filename, '.');
    catch err
        disp('Unable to upzip, you may need to download/unzip the database to currently folder manually via link:')
        disp(url)
        return
    end
    disp('Extracted.')
end

if (7==exist(folder,'dir'))
    disp('Data Conversion...')
else
    return
end

files = dir(folder);
fileIndex = find([files.isdir]);
fileIndex = fileIndex(3:end); 
files = files(fileIndex);
data={};

files = natsortfiles({files(:).name});

for i = 1:length(files)
    subfolder = files(i); 
    matfolders = dir(strcat(folder,subfolder{1}));
    matIndex = find(~[matfolders.isdir]);
    matfolders = matfolders(matIndex);
    matfolder_files = natsortfiles({matfolders(:).name});
     
    for j = 1:length(matfolder_files) 
        matfiles = matfolder_files(j);
        filename = strcat(folder, subfolder,'/',matfiles{1});
        wd = load(filename{1});
        reading=[];
        for k=1:5
            col = wd.WearableData.Reading{k};
            col(isinf (col))=0;
            col(isnan (col))=0;
            tran = col-mean(col);
            reading = [reading, tran./2./max(abs(tran))+0.5];
            reading(isnan(reading))=0;
        end
        number = sscanf(filename{1},'./WARD1.0/Subject%d/a%dt%d.mat');
        data{number(1),number(2), number(3)} = reading;
%         data{i,j}.name = filename; 
    end
end 

save('data.mat', 'data');
disp('Done. Saved to data.mat')
clear
