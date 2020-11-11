function AllFilesPresentAndAccountedFor = CheckFileExists(FileDir, FileList)

%
%  Returns the number of files that are found to be missing plus a list of missing files to stderr
%  So a return of zero means everything is OK!
%
%  Based on CheckWavExists -- don't assume it's a wav file
%  August 2006
%  Stuart Rosen
%  stuart@phon.ucl.ac.uk
%  9 May 2003
%

AllFilesPresentAndAccountedFor=0;
for i=1:length(FileList)
    if ~(exist([FileDir '\' char(FileList(i))])) 
        fprintf('Warning!! %s does not exist\n.', [FileDir '\' char(FileList(i))]);
        AllFilesPresentAndAccountedFor=AllFilesPresentAndAccountedFor+1;
    end
end
