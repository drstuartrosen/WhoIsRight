function WhoIsRight()
% Pick the correct pronunication of a word out of three
%
% method -- 'adaptive' or 'fixed'
%       if adaptive
% FeedBack --   'Neutral' ('wink') 
%               'None'
%               'Corrective' 
%               'AlwaysGood' 
% LeadInTrialsFile -- trial specification for initial part of test;
%       switched when initial adaptive trials run, or
%       when they are finished (fixed level testing).
% TrialsFile -- trial specification for the main part of the test
% If MaskerFile is text, use the files named as the maskers
%   If MaskerFile is a wave, use it directly
%
% Based on CCRMrun program used by Jude Barwell in 2006
% Version 2.1
%   Allow the specification of a fixed or adaptive method
%   Run a 2-stage procedure
%   Give an indication of number of trials left in final stage
% Version 2.2 - 13 August 2006
%   Ensure all practice trials are run
%   Extra column heading in output for reversals -- *'s
%   Modify summary file format for easier reading
%   Ensure CR/LF at end of output file
% Version 2.3 - 14 August 2006
%   Add progress indicator
% Version 2.4 - 07 September 2006
%   Choose faces and type of feedback from command line
% Version 2.5 - 10 September 2006
%   Add summary of performance to summary output file
% Version 3.0 - 11 September 2006
%   Use a single interface to control running of test -- no more arguments
%   passed through the command line.
% Version 4.0 - 06 December 2006
%   read in animated faces once only and pass to WhoIsRightResponsePad
% Version 4.1 - 29 January 2008
%   read in volume settings from a separate text file
% Version 4.2 - 04 February 2008
%   correct audio controls
% Version 5.0 - 06 September 2011
%   make audio settings work for XP & W7
% Version 6.0 - 26 October 2012
%   add seconds to file name to prevent overwriting
%   exclude Stage 1 reversals from sumary statistics
% Version 7.0 - 20 November 2015
%   update volume controls
% Version 8.0 - 11 November 2020
%   get working again in newer version of Matlab
%   
%-------------------
%   In versions<6.0, reversals began to be tallied when the
%   minimum step-size was reached. Also, only these reversals
%   were marked in the output .csv file
%   Therefore -- reversals could be counted even in Stage 1
%   (which seems a bad idea) and reversals not at the minimum
%   step-size would not count even if there were in Stage 2.
%   Maybe the latter is OK?
%   In this version -- exclude Stage 1 reversals from statistics
%-------------------


%% pre-set variables that the user may want to change
VERSION=8.0;

% If ~= 0, all trials will be run with a random response but no stimuli presented
DEBUG=0;

%% Settings for level
if ispc
    VolumeSettingsFile='VolumeSettings.txt';
    [~, OutRMS]=SetLevels(VolumeSettingsFile);
else ismac
    !osascript set_volume_applescript.scpt
    % VolumeSettingsFile='VolumeSettingsMac.txt';
end

%% get test specifications
[method,FeedBack,FacePixDir,LeadInTrialsFile,TrialsFile,MaskerFile,starting_SNR,OutFile]=TestSpecs;
SNR_dB = starting_SNR; % current level: will only apply for fixed level testing
% read in all the necessary faces
FacesDir = fullfile('Faces',FacePixDir,'');
SmileyFace = imread(fullfile(FacesDir,'smile24.bmp'),'bmp');
WinkingFace = imread(fullfile(FacesDir,'wink24.bmp'),'bmp');
FrownyFace = imread(fullfile(FacesDir,'frown24.bmp'),'bmp');
ClosedFace = imread(fullfile(FacesDir,'closed24.bmp'),'bmp');
OpenFace = imread(fullfile(FacesDir,'open24.bmp'),'bmp');
BlankFace = imread(fullfile(FacesDir,'blank24.bmp'),'bmp');

%% variables that need to change depending on method
if strcmp(method, 'adaptive')
    NumInitialTrialsToIgnore = 3;
    SNR_dB = 20;
    START_change_dB = 7.0;
    MIN_change_dB = 3.0;
    MAX_SNR_dB = 40;
    % prevent too rapid a descent just by chance
    MIN_SNR_dB_on_Initial_Descent = -15;
    InitialDescent = 1;
    INITIAL_TURNS = 3;
    FINAL_TURNS = 40;
    MAX_TRIALS = 50; % maximum number of trials per session
    Levitts = 2;
    LEVITTS_CONSTANT = [1 Levitts];
    OutFileMarker='A';
    change = START_change_dB;
    inc = (START_change_dB-MIN_change_dB)/INITIAL_TURNS;
elseif strcmp(method, 'fixed')
    MIN_change_dB = 0.0;
    MAX_SNR_dB = 0.0;
    INITIAL_TURNS = 20;
    FINAL_TURNS = 40;
    MAX_TRIALS = 500; % maximum number of trials per session
    LEVITTS_CONSTANT = [100 100];
    OutFileMarker='F';
else
    error('method must be one of fixed or adaptive, not %s', method);
end
    
%% pre-set variables best left to the programmer to change
levitts_index = 1;
SoundsDir = 'Sounds';
TargetWordsDir = 'SamWav';
FoilWordsDir = 'FionaWav';
OutputDir = 'results';
PixDir = 'Pix';

%% Initialisations
rand('state',sum(100*clock));

% read in final set of trials, just to check they are all available
[TargetPic,TargetWord,Foil1,Foil2,Foil3,CorrectResponse,SNRcorrection,TrialsOrder]...
     =ReadInTrialSpecs(TrialsFile);
% Check that all the WAV and picture files exist
if CheckWavExists([SoundsDir  '\'  FoilWordsDir], [Foil1 Foil2 Foil3])
   error('One or more WAV files missing from practice trials.')
end
if CheckFileExists(PixDir, TargetPic)
   error('One or more picture files missing from practice trials.')
end
% save number of items
nTargetWords=length(TargetPic);
 
% read in the initial set of trials
[TargetPic,TargetWord,Foil1,Foil2,Foil3,CorrectResponse,SNRcorrection,TrialsOrder]...
    =ReadInTrialSpecs(LeadInTrialsFile);
% Check that all the WAV and picture files exist
if CheckWavExists([SoundsDir  '\'  FoilWordsDir], [Foil1 Foil2 Foil3])
   error('One or more WAV files missing from test trials.')
end
if CheckFileExists(PixDir, TargetPic)
   error('One or more picture files missing from test trials.')
end
nPracticeWords=length(TargetPic);
MaxItems = nPracticeWords+nTargetWords;

[pathstr, name, ext] = fileparts(MaskerFile);
if strcmp(ext, '.wav')
   TestType = 'FixedMasker';
   [nz, nzFs]=audioread(fullfile(SoundsDir,MaskerFile));
else % assume the file contains a list
   TestType = 'VariableMasker';    
   maskers = textread(MaskerFile, '%s');
   % permute the order of the maskers/distractors
   MaskersOrder = randperm(length(maskers));
   iMaskers = 0;
end

%	setup a few starting values
previous_change = -1; % assume track is initially moving from easy to hard
num_turns = 0;
num_final_trials = 0;
limit = 0;
response_count = 0;
trial = 0;
iTargetPic = 0;
stage = 1;
% keep track of overall level of performance
rSuccesses=zeros(1,2);
nSuccesses=zeros(1,2);

[status,mess,messid] = mkdir(OutputDir);
if status==0 
  error('Cannot create new output directory for results: %s', OutputDir);
end
% get the starting date & time of the session
StartTime=fix(clock);
StartTimeString=sprintf('%02d:%02d:%02d',...
    StartTime(4),StartTime(5),StartTime(6));
FileNamingStartTime = sprintf('%02d-%02d-%02d',StartTime(4),StartTime(5), StartTime(6));
StartDate=date;
% construct the output data file name
[pathstr, ListenerName, ext] = fileparts(OutFile);
% put method, date and time on filenames so as to ensure a single file per test
FileListenerName=[OutFileMarker '_' ListenerName '_' StartDate '_' FileNamingStartTime];
OutFile = fullfile(OutputDir, [FileListenerName '.csv']);
SummaryOutFile = fullfile(OutputDir, [FileListenerName '_sum.csv']);

% write some headings and preliminary information to the output file
fout = fopen(OutFile, 'at');
fprintf(fout, 'listener,date,time,stage,trial,SNR,SNRmod,correct,target,masker,answer,response,rTime,TPic,Foil1,Foil2,Foil3,rev'); 
fclose(fout);

% wait to start
GoButton(FacesDir)

%	do adaptive tracking until stop criterion
%   iTargetPic counts around the particular stimuli (from two lists)
%   trial counts the actual number of trials in total
while (num_turns<FINAL_TURNS  & limit<=3 & trial<MAX_TRIALS & iTargetPic<length(TargetPic))
    num_correct = 0; num_wrong = 0;
    % present same level until change criterion reached */
	while ((num_correct < LEVITTS_CONSTANT(levitts_index)) & (num_wrong==0)& iTargetPic<length(TargetPic)) 
       trial=trial+1;
       iTargetPic = iTargetPic + 1;
       % get the required waves and picture
       [Foil1Wav, Fs1]=audioread(ensureWavExtension(fullfile(SoundsDir,FoilWordsDir,Foil1{TrialsOrder(iTargetPic)})));
       [Foil2Wav, Fs2]=audioread(ensureWavExtension(fullfile(SoundsDir,FoilWordsDir,Foil2{TrialsOrder(iTargetPic)})));
       [Foil3Wav, Fs3]=audioread(ensureWavExtension(fullfile(SoundsDir,FoilWordsDir,Foil3{TrialsOrder(iTargetPic)})));
       [TargetWav, FsT]=audioread(ensureWavExtension(fullfile(SoundsDir,TargetWordsDir,TargetWord{TrialsOrder(iTargetPic)}))); 
       TargetImage = imread(fullfile(PixDir,TargetPic{TrialsOrder(iTargetPic)}));
       if strcmp(TestType,'VariableMasker')
           error('Variable masker not yet implemented');
       else % fixed masker from which a section is taken
           % check that all sampling frequencies are equal
           if max([Fs1 Fs2 Fs3 FsT nzFs]) ~= min([Fs1 Fs2 Fs3 FsT nzFs])
               error('All wav file sampling frequencies must be equal')
           end
           % play it out and score it.
           % talker = WhoIsRightResponsePad(TargetPic, TargetWav, Foil1, Foil2, Foil3, Nz, snr, rmsOut, SampFreq, CorrectResponse, FeedBack)
           if ~DEBUG % allow an entire session to be run without listener responding, by random selection of response
               delete(gcf);
               response=WhoIsRightResponsePad(TargetImage, TargetWav, ...
                   Foil1Wav, Foil2Wav, Foil3Wav, nz, ...
                   SNR_dB+SNRcorrection(TrialsOrder(iTargetPic)), OutRMS, Fs1, ...
                   CorrectResponse(TrialsOrder(iTargetPic)), FeedBack, ...
                   MaxItems-trial+1,[trial, MaxItems], ...
                   SmileyFace, WinkingFace, FrownyFace, ClosedFace, OpenFace, BlankFace);
               % delete(gcf); % V 3
           else
               if (strcmp(method,'adaptive') && trial<=4) | rand<2/3
               % need to get a few right initially and then 2/3 correct overall
                   response=CorrectResponse(TrialsOrder(iTargetPic));
               else % 
                   tmp = randperm(3);
                   response = tmp(1);
               end
           end
           TimeOfResponse = clock;
           correct = CorrectResponse(TrialsOrder(iTargetPic))==response;
       end
       % keep running total of performance
       nSuccesses(stage)=nSuccesses(stage)+1;
       rSuccesses(stage)=rSuccesses(stage)+correct;
       
       % test for quitting
%        if strcmp(response,'quit') 
%           break
%        end

       fout = fopen(OutFile, 'at');
       % print out relevant information
       % fprintf(fout, '\nlistener,date,time,stage,trial,SNR,SNRmod,correct,target,masker,answer,response,rTime,TPic,Foil1,Foil2,Foil3'); 
       fprintf(fout, '\n%s,%s,%s,%1d,%3d,%+5.1f,%+5.1f,%d,%s,', ...
          ListenerName,StartDate,StartTimeString,stage,trial,SNR_dB,...
          SNRcorrection(TrialsOrder(iTargetPic)),correct, ...
          char(TargetWord(TrialsOrder(iTargetPic))));
       if strcmp(TestType,'VariableMasker')
           fprintf(fout, '%s,', char(maskers(MaskersOrder(iMaskers))));
       else
           fprintf(fout, '%s,', MaskerFile);
       end
       fprintf(fout, '%d,%d,', CorrectResponse(TrialsOrder(iTargetPic)), response);
       fprintf(fout, '%02d:%02d:%05.2f,%s,%s,%s,%s',...
          TimeOfResponse(4),TimeOfResponse(5),TimeOfResponse(6),...
          TargetPic{TrialsOrder(iTargetPic)},Foil1{TrialsOrder(iTargetPic)},...
          Foil2{TrialsOrder(iTargetPic)},Foil3{TrialsOrder(iTargetPic)});
      % close file for safety
      fclose(fout);
      % score the response as correct or wrong */
      if correct
          num_correct=num_correct+1;
      else
          InitialDescent = 0; % can no longer be on initial descent
          num_wrong=num_wrong+1;
      end

      if trial==length(TargetPic) && stage==1 % switch to new list
          % read in the final set of trials
          [TargetPic,TargetWord,Foil1,Foil2,Foil3,CorrectResponse,SNRcorrection,TrialsOrder]...
                =ReadInTrialSpecs(TrialsFile);
          iTargetPic = 0;
          stage = stage + 1;
      end             
      
      if strcmp(method,'adaptive') 
          % also keep track of levels visited: perhaps better
          % Modified October 2012 to include only Stage 2 trials
          if ((change-0.001) <= MIN_change_dB && stage==2) % allow for rounding error
              % we're in the final stretch
              num_final_trials = num_final_trials + 1;
              final_trials(num_final_trials) = SNR_dB;
          end
      elseif strcmp(method,'fixed')
          % bookkeeping for fixed level testing
          % keep the fixed method in this inner loop until done
          num_wrong = 0; num_correct = 0;       
      end
      
    end % end of inner Levitt 'while' loop

    if strcmp(method,'adaptive')
        % decide in which direction to change levels
        if (num_correct == LEVITTS_CONSTANT(levitts_index))
            current_change = -1;
        else
            if trial > NumInitialTrialsToIgnore
                current_change = 1;
            else
                continue
            end
        end
        % are we at a turnaround? (defined here as any change in direction) If so, do a few things
        if (previous_change ~= current_change)
            % move to next value of Levitt's constant if not already done
            if (levitts_index==1)
                levitts_index=2;
            end 
          % reduce step proportion if not minimum */
          if ((change-0.001) > MIN_change_dB) % allow for rounding error
            change = change-inc;
          elseif stage==2 % final turnarounds, so start keeping a tally, but
                          % exclude Stage 1 reversals 
            num_turns = num_turns + 1;
            reversals(num_turns)=SNR_dB;
            fout = fopen(OutFile, 'at');fprintf(fout,',*');fclose(fout);
            % move onto next stage of stimuli if not already in place
            % Modified 13 August 2006: play all practice items no matter what
%             if stage==1 % switch to new list
%                 % read in the final set of trials
%                 [TargetPic,TargetWord,Foil1,Foil2,Foil3,CorrectResponse,SNRcorrection,TrialsOrder]...
%                     =ReadInTrialSpecs(TrialsFile);
%                 iTargetPic = 0;
%                 stage = stage + 1;
%             end                 
          end
            % reset change indicator
            previous_change = current_change;
        end
       % change stimulus level, rounding to the nearest dB
       SNR_dB = round(SNR_dB +  change*current_change);
       % ensure that the current stimulus level is within the possible range
       % keep track of hitting the endpoints
       if (SNR_dB > MAX_SNR_dB) 
          SNR_dB = MAX_SNR_dB;
          limit = limit+1;
       elseif (SNR_dB<MIN_SNR_dB_on_Initial_Descent && InitialDescent) 
          SNR_dB = MIN_SNR_dB_on_Initial_Descent;
       end
    end % calculations only necessary for adaptive procedure

end  % end of a single run */

EndTime=fix(clock);
EndTimeString=sprintf('%02d:%02d:%02d',EndTime(4),EndTime(5),EndTime(6));
fout = fopen(SummaryOutFile, 'at');

%% output summary statistics for a fixed level procedure
if strcmp(method, 'fixed')
    fprintf(fout, 'listener,date,start,end,method,version,targetsL,targetsT,masker'); 
    fprintf(fout, ',rLeadIn,nLeadIn,rTest,nTest,pTest,rTotal,nTotal,pTotal');
    fprintf(fout, '\n%s,%s,%s,%s,%s,%+5.1f,%s,%s,%s', ...
              ListenerName,StartDate,StartTimeString,EndTimeString,...
              method,VERSION,LeadInTrialsFile,TrialsFile, MaskerFile);
    fprintf(fout, ',%d,%d,%d,%d,%4.2f,%d,%d,%4.2f',...
        rSuccesses(1),nSuccesses(1),...
        rSuccesses(2),nSuccesses(2),rSuccesses(2)/nSuccesses(2),...
        sum(rSuccesses),sum(nSuccesses),sum(rSuccesses)/sum(nSuccesses));
elseif strcmp(method, 'adaptive')
    %% output summary statistics for an adaptive procedure
    fprintf(fout, 'listener,date,start,end,method,version,targetsL,targetsT,masker');
    fprintf(fout, ',rLeadIn,nLeadIn,rTest,nTest,pTest,rTotal,nTotal,pTotal');
    fprintf(fout, ',finish,uRevs,sdRevs,nRevs,nTrials,uVisited,sdVisited,nVisited'); 
    fprintf(fout, '\n%s,%s,%s,%s,%s,%+5.1f,%s,%s,%s', ...
              ListenerName,StartDate,StartTimeString,EndTimeString,...
              method,VERSION,LeadInTrialsFile,TrialsFile, MaskerFile);
    fprintf(fout, ',%d,%d,%d,%d,%4.2f,%d,%d,%4.2f',...
        rSuccesses(1),nSuccesses(1),...
        rSuccesses(2),nSuccesses(2),rSuccesses(2)/nSuccesses(2),...
        sum(rSuccesses),sum(nSuccesses),sum(rSuccesses)/sum(nSuccesses));
    % print out summary statistics -- how did we get here?
    if (limit>=3) % bumped up against the limits
       fprintf(fout,',BUMPED');
    elseif strcmp(response,'quit')  % test for quitting
       fprintf(fout, ',QUIT');
    elseif (num_turns<FINAL_TURNS)
          fprintf(fout, ',RanOut');
    else
          fprintf(fout, ',OK');
    end
    if num_turns>1
      fprintf(fout, ',%5.2f,%5.2f', ...
         mean(reversals), std(reversals));
    else
      fprintf(fout, ',,');
    end
    fprintf(fout, ',%d,%d', num_turns, trial);       
    if num_final_trials>1
      fprintf(fout, ',%5.2f,%5.2f,%d', ...
         mean(final_trials), std(final_trials), num_final_trials);
    else
      fprintf(fout, ',,,%d', num_final_trials);
    end
end
fclose('all');

% ensure CR/LF at end of file
fout = fopen(SummaryOutFile, 'at');fprintf(fout,'\n');fclose(fout);
fout = fopen(OutFile, 'at');fprintf(fout,'\n');fclose(fout);

% final_trials
% reversals

%% clean up
set(0,'ShowHiddenHandles','on');
delete(findobj('Type','figure'));
finish; % indicate test is over

