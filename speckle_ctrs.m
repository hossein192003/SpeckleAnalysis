function [ctrs, grain_size2] = speckle_ctrs(img)
%%
% img = imread('/vmd/hossein_yazdi/Speckle Imaging/Mouse/2-20-2020/ActualData/Camera/SUM/CROPPED/CROPPED_SUM_S_15.08.24_215.tif');
% img = double(img);

%%
%  figure; imagesc(img); colormap('gray'); axis image; colorbar

%% Low-pass filter to find background
f1 = fspecial('gaussian', 15,8);
% figure; imagesc(f1); axis image
img2 = imfilter(img, f1);

%%
img3 = img ./ img2;
img3 = img3(10:end-10, 10:end-10); % Bright boundry removal

%%
% figure; imagesc(img3); colormap('gray'); axis image; colorbar

%% Speckle contrast
ctrs1 = std2(img3) / mean2(img3);

%% Median filtering for denoising
% img4 = medfilt2(img3, [4 4]);
% clip_lo = quantile(img4(:), 0.01);
% clip_hi = quantile(img4(:), 0.99);
% figure; imagesc(img4, [clip_lo clip_hi]); colormap('gray'); axis image; colorbar
% 
%%
% std2(img4) / mean2(img4)

%%
% img5 = imcrop(img4)

%%
% std2(img4) / mean2(img4)

%% Sliding Filtering (compared to previouus filtering yields )
% Method one
% kernel=ones(8,8);
% Nk=sum(kernel(:));
% M=filter2(kernel,img); % mean
% I2=filter2(kernel,img.^2);
% sigma2=(I2-M.^2/Nk)/(Nk-1)^2; % Standard deviation
% out=M.^2./sigma2/Nk^2;
% figure; imagesc(out); colormap('gray'); axis image; colorbar

% Using FFT

[N,M]=size(img);
[X,Y]=meshgrid(-N/2:N/2-1,-M/2:M/2-1);
sigma=3;
kernel=exp(-(X.^2+Y.^2)/(2*sigma^2))/(2*pi*sigma^2);

Fkernel=fft2(kernel);
M=fftshift(ifft2(fft2(img).*Fkernel));
D2=(img-M).^2;
sigma2=fftshift(ifft2(fft2(D2).*Fkernel));
out=M.^2./sigma2;
% figure; imagesc(out); colormap('gray'); axis image; colorbar

out = out(10:end-10, 10:end-10); % Bright boundry removal
ctrs2 = std2(out) / mean2(out);
% clip_lo = quantile(out2(:), 0.01);
% clip_hi = quantile(out2(:), 0.99);
% figure; imagesc(out2, [clip_lo clip_hi]); colormap('gray'); axis image; colorbar


% % Single row (120) profile 
% figure; 
% yyaxis left
% plot(img(120,:)); hold on
% plot(img2(120,:));  
% plot(out(120,:))
%  
% yyaxis right
% hold on;
% plot(img4(120,:));
% plot(out2(120,:));

%% Speckle Grain size through autocorrelation 
% [n m]=size(img3);
% % Divide by the size for normalization
% B=abs(fftshift(ifft2(fft2(img3).*conj(fft2(img3)))))./(n*m);
% 
% figure; imagesc(B); colormap('gray'); axis image; colorbar
% 
% B = B - min(B(:));
% B = B ./ max(B(:));
% figure; imagesc(B); colormap('gray'); axis image; colorbar
% p = find(B == max(B(:)))
% pp = p;
% while B(pp) >= (1/exp(1)^2)
%     grain_size1 = pp - p; 
%     pp = pp + 1; 
% end

B = normxcorr2(out, out);
% figure; imagesc(B); colormap('gray'); axis image; colorbar
p = find(B == max(B(:)));
pp = p;
while B(pp) >= (1/exp(1)^2)
    grain_size2 = pp - p; 
    pp = pp + 1; 
end

ctrs = [ctrs1 ctrs2];



