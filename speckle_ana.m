%%
img = imread('/vmd/hossein_yazdi/Speckle Imaging/Mouse/2-20-2020/ActualData/Camera/SUM/CROPPED/CROPPED_SUM_S_15.08.24_215.tif');
img = double(img);

%%
figure; imagesc(img); colormap('gray'); axis image; colorbar

%% Low-pass filter to find background
f1 = fspecial('gaussian', 15, 8);
figure; imagesc(f1); axis image
img2 = imfilter(img, f1);

%%
img3 = img2 ./ img;
img3 = img3(10:end-10, 10:end-10);

%%
figure; imagesc(img3); colormap('gray'); axis image; colorbar

%% Speckle contrast
std2(img3) / mean2(img3)

%% Median filtering for denoising
img4 = medfilt2(img3, [4 4]);
clip_lo = quantile(img4(:), 0.01);
clip_hi = quantile(img4(:), 0.99);
figure; imagesc(img4, [clip_lo clip_hi]); colormap('gray'); axis image; colorbar

%%
std2(img4) / mean2(img4)

%%
img5 = imcrop(img4)

%%
std2(img4) / mean2(img4)


