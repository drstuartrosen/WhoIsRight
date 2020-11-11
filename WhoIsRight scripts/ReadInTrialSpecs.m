function [TargetPic,TargetWord,Foil1,Foil2,Foil3,CorrectResponse,SNRcorrection,TrialsOrder]...
    =ReadInTrialSpecs(TrialsSpecFile)
% Get all the relevant information from text files
% The file format here specifies the foils and targets, but their order
% is determined randomly. In contrast to ReadInTrialInfo() in which every 
% aspect of the trial is specified.
TrialsFid = fopen(TrialsSpecFile);
% read in and discard header
z=textscan(TrialsFid, '%s %s %s %s', 1, 'delimiter', ',');
% get the structure of all possible trials
z=textscan(TrialsFid, '%q %q %q %f','delimiter', ',');
fclose(TrialsFid);

TargetWord=z{1};
SNRcorrection=z{4};
TargetPic=strtok(z{1},'O');

%%  create a matrix of random orders
%   ensuring the target appears equally in all positions
TrialMatrix=mod([1:length(z{1})]-1,3)';
TrialMatrix=[TrialMatrix mod(TrialMatrix+1,3)];
TrialMatrix=[TrialMatrix mod(TrialMatrix(:,2)+1,3)]+1;
% randomise the order by permuting in groups of 6
for i=1:floor(length(z{1})/6)
    TrialMatrix(((i-1)*6+1):i*6,:)=TrialMatrix(randperm(6)+(i-1)*6,:);
end
% randomly switch order of 2nd and 3rd items
for i=1:length(z{1})
    if rand(1)>0.5
        TrialMatrix(i,[2 3]) = TrialMatrix(i,[3 2]);
    end
end
for i=1:length(z{1})
    TargetPic{i}=[TargetPic{i} '.jpg'];
end

CorrectResponse=TrialMatrix(:,1);
% set the information for each trial
for i=1:length(TargetWord)
    for j=1:3
        switch TrialMatrix(i,j)
            case 1
                Foil1{i}= z{j}{i};
            case 2
                Foil2{i}= z{j}{i};
            case 3
                Foil3{i}= z{j}{i};
        end
    end
end
    
% permute the order
TrialsOrder = randperm(length(TargetPic));
clear z;
