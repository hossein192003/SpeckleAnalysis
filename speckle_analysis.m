%% Access Raw image folder and crop individual frames

FolderPath  = '/vmd/hossein_yazdi/Speckle Imaging/Mouse/2-20-2020/ActualData/Camera/';
addpath(FolderPath)
ImageFiles = dir(fullfile(FolderPath,'*.tif')); 
ImageFiles = ImageFiles(arrayfun(@(x) ~endsWith(x.name, {'.', '..'}), ImageFiles));

[parentFolder, deepestFolder] = fileparts(FolderPath);
newSubFolder = sprintf('%sCROPPED', FolderPath);

if ~exist(newSubFolder, 'dir')
    mkdir(newSubFolder);
    addpath(newSubFolder)
else
    addpath(newSubFolder)
    newSubFolder_IN = sprintf('%s/', newSubFolder);
    dinfo = dir(newSubFolder_IN);
    filenames = fullfile(newSubFolder_IN, {dinfo.name});
    delete(filenames{:});
end

tic

parfor i = 1:length(ImageFiles)
    stem = ImageFiles(i).name ;
    if ~isdir(stem)
        InfoImage=imfinfo(stem);    % added to imread for faster read!
        numimgs = length(InfoImage);
        im_t=gpuArray(zeros(InfoImage(1).Height,InfoImage(1).Width));
        
        for j=1:numimgs
            img = imread(stem,'Index',j,'info', InfoImage);
            imG = gpuArray(double(img));
            sq_TL_x=20;
            sq_TL_y=20;
            I_crop=imG(sq_TL_x:sq_TL_x+399,sq_TL_y:sq_TL_y+399);
    % Uncomment to see how the crop look like        
%             figure;
%             subplot(1,2,1)
%             imagesc(imG)
%             axis image off
%             colormap gray
%             title('Image')
%             hold on
%             plot([sq_TL_y sq_TL_y sq_TL_y+399 sq_TL_y+399 sq_TL_y],[sq_TL_x sq_TL_x+399 sq_TL_x+399 sq_TL_x sq_TL_x],'r')
%             hold off
%             subplot(1,2,2)
%             imagesc(I_crop)
%             axis image off
%             colormap gray
%             title('Section')
            imwrite(uint16(gather(I_crop)),[newSubFolder '/' sprintf('CROPPED_%s',stem)],'tif','WriteMode', 'append');
              
        end      
    end
end
toc

%% Loop over # of integrated frames (10 frames increment) to calculate contrast
ImageFiles_cropped = dir(fullfile(newSubFolder,'*.tif')); 
ImageFiles_cropped = ImageFiles_cropped(arrayfun(@(x) ~endsWith(x.name, {'.', '..'}), ImageFiles_cropped));
tic
for ii = floor(linspace(1,300,31))
    sprintf('Adding random set of %d framout of total 300 frames', ii)
    t=1;
    
        while t<=10       % 10 random generation trials
            r(1:ii,t) = randperm(300,ii);        % Generate ii random frames to integrate.
            for kk=1:length(ImageFiles_cropped)
                stem = ImageFiles_cropped(kk).name ;
                InfoImage=imfinfo(stem);    % added to imread for faster read!
                im_t=gpuArray(zeros(InfoImage(1).Height,InfoImage(1).Width));
                
                % loop only over the ii number of frames 
                for jj = r(:,t)'
                    img = imread(stem,'Index',jj,'info', InfoImage);
                    imG = gpuArray(double(img));
                    im_t= im_t + imG;  
                end
                [ctrs, grain_size2] = speckle_ctrs(gather(im_t));
                ctrs1(kk,t) = ctrs(1);
                ctrs2(kk,t) = ctrs(2);
                grain_size(kk,t) = grain_size2;
              
            end
            t= t+1;
        end
        if ii==1
            CTRS1(:, ii:ii+t-2) = ctrs1;
            CTRS2(:, ii:ii+t-2) = ctrs2;
            GRAIN_SIZE(:, ii:ii+t-2) = grain_size;
        end
        CTRS1(:, ii+1:ii+t-1) = ctrs1;
        CTRS2(:, ii+1:ii+t-1) = ctrs2;
        GRAIN_SIZE(:, ii+1:ii+t-1) = grain_size;
end
toc