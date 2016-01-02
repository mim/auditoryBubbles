function varargout = bubbleEditor(varargin)
% BUBBLEEDITOR MATLAB code for bubbleEditor.fig
%      BUBBLEEDITOR, by itself, creates a new BUBBLEEDITOR or raises the existing
%      singleton*.
%
%      H = BUBBLEEDITOR returns the handle to a new BUBBLEEDITOR or the handle to
%      the existing singleton*.
%
%      BUBBLEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BUBBLEEDITOR.M with the given input arguments.
%
%      BUBBLEEDITOR('Property','Value',...) creates a new BUBBLEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bubbleEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bubbleEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bubbleEditor

% Last Modified by GUIDE v2.5 01-Jan-2016 22:36:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bubbleEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @bubbleEditor_OutputFcn, ...
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


% --- Executes just before bubbleEditor is made visible.
function bubbleEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bubbleEditor (see VARARGIN)

% Process varargin. From:
% http://www.mathworks.com/help/matlab/creating_guis/initializing-a-guide-gui.html
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
            case {'wav', 'wavfilein'}
                handles.wavFileIn = varargin{index+1};
        end
    end
end

% CreateFcns should all have run by now
if isfield(handles, 'prefs')
    prefs = handles.prefs;
end

prefs.window_s = 0.064;
prefs.hopFrac = 0.25;
prefs.noiseShape = 0;

prefs.makeHoles = true;
prefs.normalizeClean = true;
%prefs.cx = [-80 30];
prefs.scale_db = 6;

prefs.maskEffect = 'attenuate';

handles.bubbleT_s = []; 
handles.bubbleF_erb = [];

% Choose default command line output for bubbleEditor
handles.output = hObject;

handles.prefs = prefs;

% If user supplies a wav file, start with it
if isfield(handles, 'wavFileIn') && ~isempty(handles.wavFileIn)
    handles = loadWav(handles);
    handles = plotAndPlay(handles);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bubbleEditor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bubbleEditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = plotAndPlay(handles);
guidata(hObject, handles);


% --- Executes on button press in undoButton.
function undoButton_Callback(hObject, eventdata, handles)
% hObject    handle to undoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.bubbleT_s = handles.bubbleT_s(1:end-1);
handles.bubbleF_erb = handles.bubbleF_erb(1:end-1);
handles = plotAndPlay(handles);
guidata(hObject, handles);


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles, 'wavFileOut') || isempty(handles.wavFileOut)
    handles = pickOutputFile(handles);
end
if isempty(handles.wavFileOut)
    return
end
if ~isfield(handles.data, 'mix')
    handles = plotAndPlay(handles);
end
if isfield(handles.data, 'mix')
    wavWriteBetter(handles.data.mix, handles.data.fs, handles.wavFileOut);
else
    warning('Mix does not exist when it should')
end
guidata(hObject, handles);


function maxFreq_hz_field_Callback(hObject, eventdata, handles)
% hObject    handle to maxFreq_hz_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.prefs.maxFreq_hz = str2num(get(hObject, 'String'));
handles = plotAndPlay(handles);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of maxFreq_hz_field as text
%        str2double(get(hObject,'String')) returns contents of maxFreq_hz_field as a double


% --- Executes during object creation, after setting all properties.
function maxFreq_hz_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxFreq_hz_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.prefs.maxFreq_hz = str2num(get(hObject, 'String'));
guidata(hObject, handles);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bubbleWidth_ms_field_Callback(hObject, eventdata, handles)
% hObject    handle to bubbleWidth_ms_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.prefs.bubbleWidth_ms = str2num(get(hObject, 'String'));
handles = plotAndPlay(handles);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of bubbleWidth_ms_field as text
%        str2double(get(hObject,'String')) returns contents of bubbleWidth_ms_field as a double


% --- Executes during object creation, after setting all properties.
function bubbleWidth_ms_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bubbleWidth_ms_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.prefs.bubbleWidth_ms = str2num(get(hObject, 'String'));
guidata(hObject, handles);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bubbleHeight_erb_field_Callback(hObject, eventdata, handles)
% hObject    handle to bubbleHeight_erb_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.prefs.bubbleHeight_erb = str2num(get(hObject, 'String'));
handles = plotAndPlay(handles);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of bubbleHeight_erb_field as text
%        str2double(get(hObject,'String')) returns contents of bubbleHeight_erb_field as a double


% --- Executes during object creation, after setting all properties.
function bubbleHeight_erb_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bubbleHeight_erb_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.prefs.bubbleHeight_erb = str2num(get(hObject, 'String'));
guidata(hObject, handles);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bubbleDepth_db_field_Callback(hObject, eventdata, handles)
% hObject    handle to bubbleDepth_db_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.prefs.bubbleDepth_db = str2num(get(hObject, 'String'));
handles = plotAndPlay(handles);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of bubbleDepth_db_field as text
%        str2double(get(hObject,'String')) returns contents of bubbleDepth_db_field as a double


% --- Executes during object creation, after setting all properties.
function bubbleDepth_db_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bubbleDepth_db_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.prefs.bubbleDepth_db = str2num(get(hObject, 'String'));
guidata(hObject, handles);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in inputFileButton.
function inputFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to inputFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles, 'wavFileIn'), handles.wavFileIn = ''; end
[inFile inDir] = uigetfile('*', 'Please select input file', handles.wavFileIn);
if (length(inFile) == 1) && (inFile == 0)
    handles.wavFileIn = '';
    return
else
    handles.wavFileIn = fullfile(inDir, inFile);
end

handles = loadWav(handles);
handles = plotAndPlay(handles);
% mask = ones(size(handles.data.X));
% showMaskedSpec(handles.data.X, mask, handles.sgInfo.timeVec_s, handles.sgInfo.freqVec_hz, handles.prefs.maxFreq_hz, handles.prefs.cx);

guidata(hObject, handles);



% --- Executes on button press in outputFileButton.
function outputFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to outputFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = pickOutputFile(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function inputFileField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bubbleDepth_db_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function outputFileField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bubbleDepth_db_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in amplifySelect.
function amplifySelect_Callback(hObject, eventdata, handles)
% hObject    handle to amplifySelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    handles.prefs.maskEffect = 'amplify';
end
handles = plotAndPlay(handles);
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of amplifySelect


% --- Executes on button press in attenuateSelect.
function attenuateSelect_Callback(hObject, eventdata, handles)
% hObject    handle to attenuateSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    handles.prefs.maskEffect = 'attenuate';
end
handles = plotAndPlay(handles);
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of attenuateSelect


% --- Executes on mouse press over axes background.
function mainAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to mainAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.bubbleT_s(end+1) = eventdata.IntersectionPoint(1);
handles.bubbleF_erb(end+1) = hz2erb(eventdata.IntersectionPoint(2));
handles = plotAndPlay(handles);
guidata(hObject, handles);


function minLevel_db_field_Callback(hObject, eventdata, handles)
% hObject    handle to minLevel_db_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.prefs.minLevel_db = str2num(get(hObject, 'String'));
handles = plotAndPlay(handles);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of minLevel_db_field as text
%        str2double(get(hObject,'String')) returns contents of minLevel_db_field as a double


% --- Executes during object creation, after setting all properties.
function minLevel_db_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minLevel_db_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.prefs.minLevel_db = str2num(get(hObject, 'String'));
guidata(hObject, handles);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxLevel_db_field_Callback(hObject, eventdata, handles)
% hObject    handle to maxLevel_db_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.prefs.maxLevel_db = str2num(get(hObject, 'String'));
handles = plotAndPlay(handles);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of maxLevel_db_field as text
%        str2double(get(hObject,'String')) returns contents of maxLevel_db_field as a double


% --- Executes during object creation, after setting all properties.
function maxLevel_db_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxLevel_db_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.prefs.maxLevel_db = str2num(get(hObject, 'String'));
guidata(hObject, handles);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%%%%%%%% non-gui functions %%%%%%%%%

function handles = loadWav(handles)

% Shorthand
prefs = handles.prefs;

[data.x data.fs data.dur_s] = loadCleanWav(handles.wavFileIn, '', prefs.normalizeClean, -1);

[sgInfo.nF, sgInfo.nT, sgInfo.nFft, sgInfo.nHop, sgInfo.freqVec_hz, sgInfo.freqVec_erb, sgInfo.timeVec_s] = ...
    specgramDims(data.dur_s, data.fs, prefs.window_s, prefs.hopFrac, prefs.bubbleHeight_erb);

% Make visualization
data.X = stft([data.x' zeros(size(data.x,2),sgInfo.nFft)], sgInfo.nFft, sgInfo.nFft, sgInfo.nHop);

% Save structures
handles.data = data;
handles.sgInfo = sgInfo;
handles.bubbleT_s = [];
handles.bubbleF_erb = [];

set(handles.inputFileField, 'String', handles.wavFileIn);


function handles = plotAndPlay(handles)

% Shortcuts
sg = handles.sgInfo;
d = handles.data;
p = handles.prefs;

% Update visualization
mask = genMaskFromBubbleLocs(sg.nF, sg.nT, sg.freqVec_erb, sg.timeVec_s, ...
    handles.bubbleF_erb, handles.bubbleT_s, ...
    p.bubbleWidth_ms/1000, p.bubbleHeight_erb, 0, p.bubbleDepth_db);
%showMaskedSpec(d.X, mask, sg.timeVec_s, sg.freqVec_hz, p.maxFreq_hz, p.cx)

if strcmp(p.maskEffect, 'attenuate')
    mask = lim(mask, 0, 1);
    d.mix = real(istft(d.X .* (1 - mask), sg.nFft, sg.nFft, sg.nHop));
elseif strcmp(p.maskEffect, 'amplify')
    d.mix = real(istft(d.X .* (1 + mask), sg.nFft, sg.nFft, sg.nHop));
else
    error('Unknown mask effect: %s', p.maskEffect);
end
    
mixX = stft(d.mix / sqrt(sg.nFft), sg.nFft, sg.nFft, sg.nHop);
%rescaledSpec = 256*lim((db(mixX) - p.cx(1)) /  (p.cx(2) - p.cx(1)), 0, 1);
rescaledSpec = 256*lim((db(mixX) - p.minLevel_db) /  (p.maxLevel_db - p.minLevel_db), 0, 1);
imageSaveBdf(sg.timeVec_s, sg.freqVec_hz, rescaledSpec);
axis xy; ylim([0 p.maxFreq_hz]);

sound(d.mix, d.fs);

handles.data = d;

% if strcmp(p.maskEffect, 'attenuate')
%     mix = real(istft(d.X .* mask, sg.nFft, sg.nFft, sg.nHop));
%     figure(2)
%     showMaskedSpec(stft(mix, sg.nFft, sg.nFft, sg.nHop), zeros(size(mask)), sg.timeVec_s, sg.freqVec_hz, p.maxFreq_hz, p.cx)
%     figure(1)
% end


function showMaskedSpec(X, mask, timeVec_s, freqVec_hz, maxFreq_hz, cx)
mask_db = db(mask);
maskLims = [-80 0];
rescaledMask = lim((mask_db - maskLims(1)) / (maskLims(2) - maskLims(1)), 0, 1);
rescaledSpec = lim((db(X) - cx(1)) /  (cx(2) - cx(1)), 0, 1);
h = zeros(size(mask));
s = 1 - rescaledSpec;
v = 1 - 0.5 * rescaledMask;
%v = ones(size(mask));
rgb = hsv2rgb(cat(3,h,s,v));
imageSaveBdf(timeVec_s, freqVec_hz, rgb);
axis xy; ylim([0 maxFreq_hz]);


function imageSaveBdf(xl, yl, img)
% Need to copy the listener to the image, which is in front of the axes
bdf = get(gca, 'ButtonDownFcn');
imHandle = image('XData', xl, 'YData', yl, 'CData', img);
set(imHandle, 'ButtonDownFcn', bdf);


function [mix clean noise] = generateSound(x, dur_s, fs, mask, snr_db, scale_db, window_s, hopFrac, noiseShape)
[~,~,noise] = genMaskedSsn(dur_s, fs, mask, window_s, hopFrac, noiseShape);
mix = 10^(scale_db/20) * (10^(snr_db/20) * x + noise);
clean = 10^(scale_db/20) * 10^(snr_db/20) * x;


function handles = pickOutputFile(handles)

if ~isfield(handles, 'wavFileOut')
    handles.wavFileOut = '';
    if isfield(handles, 'wavFileIn') && ~isempty(handles.wavFileIn)
        defaultFile = fileparts(handles.wavFileIn);
    else
        defaultFile = '';
    end
else    
    defaultFile = handles.wavFileOut;
end
[outFile outDir] = uiputfile('*', 'Please select output file', defaultFile);
if (length(outFile) == 1) && (outFile == 0)
    return
else
    handles.wavFileOut = fullfile(outDir, outFile);
end
set(handles.outputFileField, 'String', handles.wavFileOut);

