function varargout = TestSpecs(varargin)
%
%   output variables:
%   1: test type:   'fixed' or 'adaptive'
%   2: feedback:    'Neutral' or 'Corrective' or 'None' or 'AlwaysGood'
%   3: Faces: e.g., 'Blondie')
%   4: LeadInTrialsFile: e.g., 'PI8SEP2.csv',
%   5: TrialsFile: e.g., 'TI8SEP4.csv'
%   6: Masker: e.g., 'SpchNz.wav'
%   7: starting SNR: e.g., -4,
%   8: Listener code: e.g., LGP01

% TESTSPECS M-file for TestSpecs.fig
%      TESTSPECS, by itself, creates a new TESTSPECS or raises the existing
%      singleton*.
%
%      H = TESTSPECS returns the handle to a new TESTSPECS or the handle to
%      the existing singleton*.
%
%      TESTSPECS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTSPECS.M with the given input arguments.
%
%      TESTSPECS('Property','Value',...) creates a new TESTSPECS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TestSpecs_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TestSpecs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TestSpecs

% Last Modified by GUIDE v2.5 11-Sep-2006 10:59:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TestSpecs_OpeningFcn, ...
                   'gui_OutputFcn',  @TestSpecs_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TestSpecs is made visible.
function TestSpecs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TestSpecs (see VARARGIN)

% Move the GUI to the center of the screen.
movegui(hObject,'center')

% Choose default command line output for TestSpecs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TestSpecs wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TestSpecs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.AorF;
varargout{2} = handles.F;
varargout{3} = handles.Faces;
varargout{4} = handles.LIT;
varargout{5} = handles.T;
varargout{6} = handles.M;
varargout{7} = handles.SNR;
varargout{8} = handles.L;

% The figure can be deleted now
delete(handles.figure1);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function StartLevel_Callback(hObject, eventdata, handles)
% hObject    handle to StartLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartLevel as text
%        str2double(get(hObject,'String')) returns contents of StartLevel as a double


% --- Executes during object creation, after setting all properties.
function StartLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LeadInTrials_Callback(hObject, eventdata, handles)
% hObject    handle to LeadInTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LeadInTrials as text
%        str2double(get(hObject,'String')) returns contents of LeadInTrials as a double


% --- Executes during object creation, after setting all properties.
function LeadInTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LeadInTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TestTrials_Callback(hObject, eventdata, handles)
% hObject    handle to TestTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TestTrials as text
%        str2double(get(hObject,'String')) returns contents of TestTrials as a double


% --- Executes during object creation, after setting all properties.
function TestTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TestTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaskerFile_Callback(hObject, eventdata, handles)
% hObject    handle to MaskerFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaskerFile as text
%        str2double(get(hObject,'String')) returns contents of MaskerFile as a double


% --- Executes during object creation, after setting all properties.
function MaskerFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskerFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ListenerCode_Callback(hObject, eventdata, handles)
% hObject    handle to ListenerCode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ListenerCode as text
%        str2double(get(hObject,'String')) returns contents of ListenerCode as a double


% --- Executes during object creation, after setting all properties.
function ListenerCode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListenerCode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.Adaptive,'Value')
    handles.AorF='adaptive';
else
    handles.AorF='fixed';
end
if get(handles.AlwaysGood,'Value')
    handles.F='AlwaysGood';
elseif get(handles.Neutral,'Value')
    handles.F='Neutral';
elseif get(handles.Corrective,'Value')
    handles.F='Corrective';
else
    handles.F='None';
end
if get(handles.Blondie,'Value')
    handles.Faces='Blondie';
elseif get(handles.Bears,'Value')
    handles.Faces='Bears';
elseif get(handles.Pinky,'Value')
    handles.Faces='Pinky';
else
    handles.Faces='Other';
end
handles.LIT=get(handles.LeadInTrials,'String');
handles.T=get(handles.TestTrials,'String');
handles.M=get(handles.MaskerFile,'String');
handles.SNR=str2num(get(handles.StartLevel,'String'));
handles.L=get(handles.ListenerCode,'String');

guidata(hObject, handles); % Save the updated structure
uiresume(handles.figure1);

% --------------------------------------------------------------------
function AdaptiveOrFixed_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to AdaptiveOrFixed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.AorF=lower(get(hObject,'Tag'))   % Get Tag of selected object

% --------------------------------------------------------------------
function Feedback_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to Feedback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Demo.
function Demo_Callback(hObject, eventdata, handles)
% hObject    handle to Demo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.LeadInTrials,'String','EI.csv');
set(handles.TestTrials,'String','EI.csv');
set(handles.StartLevel,'String','10');


