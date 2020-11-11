function AllFilesPresentAndAccountedFor = CheckWavExists(WavFileDir, FileList)

%
%  Returns the number of files that are found to be missing plus a list of missing files to stderr
%  So a return of zero means everything is OK!
%
%  Stuart Rosen
%  stuart@phon.ucl.ac.uk
%  9 May 2003
%

AllFilesPresentAndAccountedFor=0;
for i=1:length(FileList)
    if ~(exist([WavFileDir '\' char(FileList(i)) '.wav'])) 
        fprintf('Warning!! %s does not exist.\n', [WavFileDir '\' char(FileList(i)) '.wav']);
        AllFilesPresentAndAccountedFor=AllFilesPresentAndAccountedFor+1;
    end
end
