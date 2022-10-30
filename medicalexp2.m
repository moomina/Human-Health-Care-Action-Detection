clear all;
close all;
clc;
 srcFiles = dir('D:\matlabproject\MEXP2\*.png'); % takes all jpg image from this location
j=length(srcFiles);% check the lenghth of total images    
D=cell(j,2);%  a cell array having one column and rows equal to number of images
T =  zeros(255,1);

k=3;
%  for training
for i=1:length(srcFiles)
    filename = strcat('D:\matlabproject\MEXP2\',srcFiles(i).name);%pick image one by one
    I = imread(filename);%read image
    numrows=256;
    numcols=256;
    I = imresize(I,[numrows numcols]);
    gsImg = rgb2gray(I);% convert it into gray
    points = detectSURFFeatures(gsImg);% use sift detector
 [features, valid_points] = extractFeatures(gsImg, points); % extract feature points
 [m,n]=size(features);% calculate the  m and n based on feature size
D(i)=mat2cell(zeros(m,n,j),m,n,j);
 D{i} = features;% one by one feature matrix are saving at this location 
 A={'Allergy-Reaction','Astma','Burn','Bleeding'};
 if(i<=524)
  D{i,2}= A{1};
 end
 if (i >= 527) && (i <= 1143)
  D{i,2}= A{2};
 end
  if (i >= 1145) && (i <=1643)
  D{i,2}= A{3};
  end
  if (i >=1645) && (i <=2717)
  D{i,2}= A{4};
  end
 
end
  
    figure; imshow(gsImg); hold on;
   plot(valid_points.selectStrongest(50),'showOrientation',true);
%       path=strcat('D:\matlabproject\TrainingGrayImage\',srcFiles(i).name);
%        imwrite(gsImg,path);
for i=1:2717
if(i<=524)
  T(i)= 1;
 end
 if (i >=527) && (i <=1143)
  T(i)= 2;
 end
  if (i >=1145) && (i <=1643)
   T(i)= 3;
  end
  if (i >=1645) && (i <=2717)
  T(i)= 4;
  end
end
G = cell(j,1);
  for s = 1 : length(D)
    Y = D{s}; % Extract double array from cell.
     yourvector = Y(:); %convert single feature as a  vector 
    yourvector =transpose(yourvector);%by taking transpose we convert it row vector  
    G{s} =  yourvector;
  end
  
 M = max(cellfun(@numel, G));
 Q_Vic1_out = cellfun(@(x) [x zeros(1, M - numel(x))], G, 'un', 0);
  H = [];
 for s = 1 : length( Q_Vic1_out)-1
      V1=  Q_Vic1_out{s};
      V2= Q_Vic1_out{s+1};
      Distanvce  = sqrt(sum((V1 - V2) .^ 2));
       H = [H   Distanvce];
  end
 out =cell2mat(Q_Vic1_out);
 out=double(out);
  H=transpose(H);
    options = [NaN 25 0.001 0];
    K=4;
%   idx = kmedoids(H,K);
%  silhouette(H,idx);
% [Acc,rand_index,match]=AccMeasure(T,idx);
center=[15.991372;2.5764086;7.5149083;11.378063];
%    [idx,C]= kmeans(H,K);
 idx = kmeans(H,K,'Start',center);
  len=length(idx);% check the lenghth of total images 
 label=cell(len,2);
 A={'Allergy-Reaction','Astma','Burn','Bleeding'};
for i=1:2712  
  f=idx(i, 1);
  label{i} = f;
  if(label{i}== 1)
  label{i,2}= A{1};
  end
  if (label{i} == 2)
  label{i,2}= A{2};
 end
  if (label{i} == 3)
  label{i,2}= A{3};
  end
  if (label{i} == 4)
  label{i,2}= A{4};
  end
end
 movieFullFileName = 'C:\Users\hp\Pictures\Writeimage\(output013)14-PEDS_Poisoning(0).avi';
promptMessage = sprintf('Do you want to save the individual frames out to individual disk files?');
	button = questdlg(promptMessage, 'Save individual frames?', 'Yes', 'No', 'Yes');
	if strcmp(button, 'Yes')
		writeToDisk = true;
		
		% Extract out the various parts of the filename.
		[folder, baseFileName, extentions] = fileparts(movieFullFileName);
		% Make up a special new output subfolder for all the separate
		% movie frames that we're going to extract and save to disk.
		% (Don't worry - windows can handle forward slashes in the folder name.)
		folder = pwd;   % Make it a subfolder of the folder where this m-file lives.
		outputFolder = sprintf('%s/Movie Frames from %s', folder, baseFileName);
		% Create the folder if it doesn't exist already.
		if ~exist(outputFolder, 'dir')
			mkdir(outputFolder);
		end
	else
		writeToDisk = false;
    end
srcFiles = dir('D:\matlabproject\MEXP2\*.png'); % takes all jpg image from this location
j=length(srcFiles);% check the lenghth of total images  
for i=1:2717                             
    filename = strcat('D:\matlabproject\MEXP2\',srcFiles(i).name);%pick image one by one
    I = imread(filename);%read image
    imshow (I);
    assignlabel = label{i,2}; 
    s1=num2str(i);
    assignedlabelstoframes=strcat(s1,assignlabel);
%     	outputBaseFileName = sprintf('Frame %4.4d.png', i);
     outputBaseFileName = sprintf(assignedlabelstoframes);
    outputFullFileName = fullfile(outputFolder, outputBaseFileName);
imwrite(I,outputFullFileName, 'png');
end

%   len=length(idx);% check the lenghth of total images 
%  label=cell(len,2); 
%   label = idx;% one by one feature matrix are saving at this location 
%   A={'Golf-Swing-Back','Diving-side','Kicking-Front','Riding-Horse','Skate-boarding','walking','Lifting','Run-Side'};
%  for i=1:385
%   if(i<=60)
%   D{i,2}= A{1};
%  end    
%  end
  
  [Acc,rand_index,match]=AccMeasure(T,idx);
 silhouette(H,idx);
 

%   Z = linkage(H,'average','chebychev');
% c = cluster(Z,'maxclust',8);
% silhouette(H,c);
%  [Acc,rand_index,match]=AccMeasure(T,c);
% cutoff = median([Z(end-2,3) Z(end-1,3)]);
% dendrogram(Z,'ColorThreshold',cutoff)
%  K=8;
%  [center,U,obj_fcn] = fcm(H,K,options);
% [~,clustering_solution]=max(U);
% idx1=transpose(clustering_solution);
% silhouette(H,idx1);
% [Acc,rand_index,match]=AccMeasure(T,idx1);
% mac=[7,4,6,8,5,2,1,3];
% bar(mac);