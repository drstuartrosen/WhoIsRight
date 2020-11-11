function varargout = ...
    WhoIsRightResponsePad(TargetPic,TargetWav,Foil1,Foil2,Foil3,...
    Nz,snr,rmsOut,SampFreq,CorrectResponse,FeedBack,TrialsLeft,PieSections,...
    SmileyFace,WinkingFace,FrownyFace,ClosedFace,OpenFace,BlankFace)

% Version 2.5
%   construct entire trial including ISIs so as to be able to add a
%   continuous noise, rather than hearing 3 separate bursts
%   allow specification of no feedback (FeedBack=0), corrective feedback
%       (FeedBack=1) or SLT feedback (FeedBack=2)
%   add information about number of trials left
% Version 2.6
%   add pie chart showing proportion done if desired
%       2 value vector trials_remaining trials_done
% Version 2.7
%   alter pie chart
%   allow selection of faces
%   modify various feedback options
% Version 3.0
%   have faces passed in
% Version 4.0
%   update to run in newer versions of Matlab
%   put initial silence on to target waves as well as to trial wave with
%   noise with new variable: InitialWindowsIdioticSilence

Talker=[];
WarningNoiseDuration = 200;
RiseFall = 50;
DEBUG=0; % output a bunch of waves to check things

DonePlaying=0;

PauseForFeedback=0.5;
InterStimulusInterval=0.8;
InitialWindowsIdioticSilence=0.2;
InitialAndFinalSilence=0.2;

numSamplesISI = round(InterStimulusInterval*SampFreq);
numSamplesInitialAndFinalSilence = round(InitialAndFinalSilence*SampFreq);
nInitialWindowsIdioticSilence=round(InitialAndFinalSilence*SampFreq);;

% construct observation intervals to play as one long file
AllChoicesWav = [zeros(1,numSamplesInitialAndFinalSilence) ... 
    Foil1' zeros(1,numSamplesISI) Foil2' zeros(1,numSamplesISI) ... 
    Foil3' zeros(1,numSamplesInitialAndFinalSilence)];
% calculate rms level of foils on their own!
FoilsOnlyWav = [Foil1' Foil2' Foil3'];
rmsSig = norm(FoilsOnlyWav)/sqrt(length(FoilsOnlyWav));
clear FoilsOnlyWav;

% function sig = AddNoise(     sig,    nz,rms_sig, Fs, snr, duration, fixed, in_rms, out_rms, warning_noise_duration,RiseFall)
AllChoicesWav = AddNoise(AllChoicesWav,Nz,rmsSig, SampFreq, snr, 0,  'noise', 0,     rmsOut, WarningNoiseDuration,   RiseFall);
AllChoicesWav = [zeros(nInitialWindowsIdioticSilence,1); AllChoicesWav];
if (DEBUG)
    audiowrite(sprintf('TripletWav-%02d.wav',43-TrialsLeft),AllChoicesWav, SampFreq)
end

% normalise the target wave to the same level as all the stimuli
% function sig = normaliseRMS(sig, out_rms)
TargetWav = normaliseRMS(TargetWav, rmsOut);
% and add on some initial silence
TargetWav = [zeros(1,numSamplesInitialAndFinalSilence) TargetWav']; 

%  Create and then hide the GUI as it is being constructed.
% original settings
% FigLeft=360; FigBottom=500; FigWidth=650; FigHeight=600;
% FigLeft=360; FigBottom=500; FigWidth=900; FigHeight=700;
FigLeft=360; FigBottom=500; FigWidth=800; FigHeight=730;
[FaceWidth,FaceHeight,tmp] = size(ClosedFace); 
% extra
FaceMultiplier = 1.0;
FaceWidth=FaceMultiplier*FaceWidth; FaceHeight=FaceMultiplier*FaceHeight;

[TargetPicWidth, TargetPicHeight, tmp] = size(TargetPic);
f = figure('Visible','off', 'MenuBar', 'none', ...
    'Toolbar', 'none','NumberTitle', 'off',...
    'Position',[FigLeft,FigBottom,FigWidth,FigHeight]);

Talker1 = uicontrol('Style','pushbutton', 'Position', [FaceWidth/4,180,FaceWidth,FaceHeight],...
      'Callback',{@Talker1_Callback}, 'CData', ClosedFace);
Talker2 = uicontrol('Style','pushbutton', 'Position', [FigWidth/2,180,FaceWidth,FaceHeight],...
      'Callback',{@Talker2_Callback}, 'CData', ClosedFace);
Talker3 = uicontrol('Style','pushbutton', 'Position', [FigWidth-(FaceWidth+FaceWidth/4),180,FaceWidth,FaceHeight],...
      'Callback',{@Talker3_Callback}, 'CData', ClosedFace);
align([Talker1, Talker2, Talker3],'Distribute','None');
Target = axes('Units','Pixels','Position',...
    [(FigWidth-TargetPicWidth)/2,FigHeight-(8/7)*TargetPicHeight,...
    TargetPicWidth, TargetPicHeight]);
image(TargetPic)
set(Target,'Visible','off');
if nargin>=13
    HowMuchLeft = axes('Units','Pixels','Position',...
        [FigWidth-1.2*(FaceWidth/2+FaceWidth/8),30,FaceWidth/2,FaceHeight/2]);
    if PieSections(1)==0, PieSections(1)=0.01, end;
    pie3(PieSections(1)/PieSections(2),{''})
    colormap gray
end
set(Target,'Visible','off');
   
  
% Assign the GUI a name to appear in the window title.
if nargin==11
    set(f,'Name','Who''s right?')
else
    set(f,'Name',sprintf('Who''s right?: Only %d to go.', TrialsLeft))
end
% Move the GUI to the center of the screen.
movegui(f,'center')
% modal
set(f,'WindowStyle','modal');
% Make the GUI visible.
set(f,'Visible','on');


pause(0.5)
playEm = audioplayer(TargetWav,SampFreq);
play(playEm);
% wavplay(TargetWav,SampFreq,'async');
pause(length(Foil1)/SampFreq)
pause(1)

playEm = audioplayer(AllChoicesWav,SampFreq);
play(playEm);
% wavplay(AllChoicesWav,SampFreq,'async');
pause(InitialAndFinalSilence+(WarningNoiseDuration+RiseFall)/1000)
set(Talker1, 'CData',OpenFace);
pause(length(Foil1)/SampFreq)
set(Talker1, 'CData',ClosedFace);
pause(InterStimulusInterval)
set(Talker2, 'CData',OpenFace);
pause(length(Foil2)/SampFreq)
set(Talker2, 'CData',ClosedFace);
pause(InterStimulusInterval)
set(Talker3, 'CData',OpenFace);
pause(length(Foil3)/SampFreq)
set(Talker3, 'CData',ClosedFace);
DonePlaying=1;

uiwait(f);
set(f,'WindowStyle','normal');
varargout(1)={Talker};

   function Talker1_Callback(source,eventdata)
       Talker = 1;
       if DonePlaying; ProvideFeedBack(Talker); end;
       uiresume(f);
       return
   end
   function Talker2_Callback(source,eventdata)
       Talker = 2;
       if DonePlaying; ProvideFeedBack(Talker); end;
       uiresume(f);
       return
   end
   function Talker3_Callback(source,eventdata)
       Talker = 3;
       if DonePlaying; ProvideFeedBack(Talker); end;
       uiresume(f);
       return
   end
   function ProvideFeedBack(Talker)
      if strcmp(FeedBack,'None')
          return;
      elseif strcmp(FeedBack,'Neutral')
          switch Talker
              case 1
                  set(Talker2, 'CData',BlankFace);
                  set(Talker3, 'CData',BlankFace);              
                  set(Talker1, 'CData',WinkingFace);               
              case 2
                  set(Talker1, 'CData',BlankFace);
                  set(Talker3, 'CData',BlankFace);  
                  set(Talker2, 'CData',WinkingFace);             
              case 3
                  set(Talker1, 'CData',BlankFace);
                  set(Talker2, 'CData',BlankFace);             
                  set(Talker3, 'CData',WinkingFace);
                  
          end          
      elseif (Talker==CorrectResponse & strcmp(FeedBack,'Corrective')) | strcmp(FeedBack,'AlwaysGood')
          switch Talker
              case 1
                  set(Talker2, 'CData',BlankFace);
                  set(Talker3, 'CData',BlankFace);              
                  set(Talker1, 'CData',SmileyFace);               
              case 2
                  set(Talker1, 'CData',BlankFace);
                  set(Talker3, 'CData',BlankFace);  
                  set(Talker2, 'CData',SmileyFace);             
              case 3
                  set(Talker1, 'CData',BlankFace);
                  set(Talker2, 'CData',BlankFace);             
                  set(Talker3, 'CData',SmileyFace);
                  
          end
      else switch Talker
              case 1
                  set(Talker2, 'CData',BlankFace);
                  set(Talker3, 'CData',BlankFace);
%                   set(Talker2, 'Visible','off');
%                   set(Talker3, 'Visible','off');                    
                  set(Talker1, 'CData',FrownyFace);
              case 2
                  set(Talker1, 'CData',BlankFace);
                  set(Talker3, 'CData',BlankFace);                  
%                   set(Talker1, 'Visible','off');
%                   set(Talker3, 'Visible','off');                  
                  set(Talker2, 'CData',FrownyFace);        
              case 3
                  set(Talker1, 'CData',BlankFace);
                  set(Talker2, 'CData',BlankFace);                  
%                   set(Talker1, 'Visible','off');
%                   set(Talker2, 'Visible','off');                    
                  set(Talker3, 'CData',FrownyFace);
          end          
      end
      pause(PauseForFeedback)
      set(Talker1, 'CData',ClosedFace);
      set(Talker2, 'CData',ClosedFace);      
      set(Talker3, 'CData',ClosedFace);
      set(Talker1, 'Visible','on');
      set(Talker2, 'Visible','on');
      set(Talker3, 'Visible','on');
   end



end