function varargout = MainGui(varargin)
% MAINGUI MATLAB code for MainGui.fig
%      MAINGUI, by itself, creates a new MAINGUI or raises the existing
%      singleton*.
%
%      H = MAINGUI returns the handle to a new MAINGUI or the handle to
%      the existing singleton*.
%
%      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINGUI.M with the given input arguments.
%
%      MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainGui

% Last Modified by GUIDE v2.5 15-May-2017 22:52:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainGui_OpeningFcn, ...
                   'gui_OutputFcn',  @MainGui_OutputFcn, ...
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


% --- Executes just before MainGui is made visible.
function MainGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainGui (see VARARGIN)

% Choose default command line output for MainGui
%run('/BMSS/');


addpath Common;
addpath RSSS;
addpath BMSS;

handles.output = hObject;
handles.started = false;
handles.work = [];

handles.sdiv = false;
handles.laser = false;
handles.path = false;
handles.isPause = false;


% Update handles structure
guidata(hObject, handles);


% UIWAIT makes MainGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MainGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function input_file_Callback(hObject, eventdata, handles)
% hObject    handle to input_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_file as text
%        str2double(get(hObject,'String')) returns contents of input_file as a double
    axes(handles.input_map);
    cla;
    fname = get(handles.input_file,'String');
    Environment(fname).showEnv();


% --- Executes during object creation, after setting all properties.
function input_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pause.
function pause_Callback(hObject, eventdata, handles)
% hObject    handle to pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pause
    if(get(hObject, 'Value'))
    set(handles.time,'Enable','off');
    set(handles.box_visited,'Enable','off');
    set(handles.pause,'String','Resume');
    waitfor(hObject, 'Value');

    else
    set(handles.time,'Enable','inactive');
    set(handles.box_visited,'Enable','inactive');
    set(handles.pause,'String','Pause');

    end
    guidata(handles.figure1,handles);
    


% --- Executes on selection change in algo.
function algo_Callback(hObject, eventdata, handles)
% hObject    handle to algo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns algo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from algo


% --- Executes during object creation, after setting all properties.
function algo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to algo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in show_path.
function show_path_Callback(hObject, eventdata, handles)
% hObject    handle to show_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_path
     if(get(hObject, 'Value'))
        set(handles.show_path,'String','Hide Path');
        handles.work.showPath = true;
        guidata(handles.figure1,handles);
        handles.work.displayEnv();
        handles.work.displayCurrPath();
     else
         set(handles.show_path,'String','Show Path');
         handles.work.showPath = false;
         guidata(handles.figure1,handles);
         cla;
         handles.work.displayEnv();
     end
     guidata(handles.figure1,handles);


% --- Executes on button press in show_laser.
function show_laser_Callback(hObject, eventdata, handles)
% hObject    handle to show_laser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_laser
    if(get(hObject, 'Value'))
        set(handles.show_laser,'String','Hide Laser Scan');
        handles.work.showLaser = true;
        guidata(handles.figure1,handles);
        
    else
        set(handles.show_laser,'String','Show Laser Scan');
        handles.work.showLaser = false;
        guidata(handles.figure1,handles);
        handles.work.displayEnv();
    end
     guidata(handles.figure1,handles);

% --- Executes on button press in show_sdiv.
function show_sdiv_Callback(hObject, eventdata, handles)
% hObject    handle to show_sdiv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_sdiv
    if(get(hObject, 'Value'))
        set(handles.show_sdiv,'String','Hide SubDiv');
        handles.work.showSubdiv = true;
        guidata(handles.figure1,handles);
        handles.work.displaySubDiv();
    else
        set(handles.show_sdiv,'String','Show SubDiv');
        handles.work.showSubdiv = false;
        guidata(handles.figure1,handles);
        handles.work.displayEnv();
    end
     guidata(handles.figure1,handles);


function time_Callback(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time as text
%        str2double(get(hObject,'String')) returns contents of time as a double



% --- Executes during object creation, after setting all properties.
function time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_visited_Callback(hObject, eventdata, handles)
% hObject    handle to box_visited (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_visited as text
%        str2double(get(hObject,'String')) returns contents of box_visited as a double


% --- Executes during object creation, after setting all properties.
function box_visited_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_visited (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function goal_sep_Callback(hObject, eventdata, handles)
% hObject    handle to goal_sep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of goal_sep as text
%        str2double(get(hObject,'String')) returns contents of goal_sep as a double


% --- Executes during object creation, after setting all properties.
function goal_sep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to goal_sep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(~handles.started)
        set(handles.show_sdiv,'Enable','on');
        set(handles.show_laser,'Enable','on');
        set(handles.show_path,'Enable','on');
        set(handles.latency,'Enable','on');
        set(handles.pause,'Enable','on');

        set(handles.time,'Enable','inactive');
        set(handles.box_visited,'Enable','inactive');
        set(handles.stop,'Enable','on');
        
        handles.started = true;
        guidata(handles.figure1,handles)
    else
        handles.work.isQuit = true;
        guidata(handles.figure1,handles)
    end
    
    reset(handles);
    %setup input axes
    axes(handles.input_map);
    cla;
    fname = get(handles.input_file,'String');
    range = str2double(get(handles.range,'String'));
    Environment(fname).showEnv();
    axis manual;
    
    %setup explored map
    axes(handles.explored_map);
    cla;
    
    %curr = handles.working;
    %clear curr;
    switch get(handles.algo,'Value')
        
        case 1
              handles.work = RSSS(handles,fname, range);
              guidata(handles.figure1,handles)
              handles.work.run();
%             
        case 2
              handles.work = BMSS(handles,fname, range);
              guidata(handles.figure1,handles)
              handles.work.findGoal();
             
    end
    guidata(hObject,handles);
  
    
    


% --- Executes on slider movement.
function latency_Callback(hObject, eventdata, handles)
% hObject    handle to latency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles.work.latency = get(handles.latency, 'Value');
    guidata(handles.figure1,handles);



% --- Executes during object creation, after setting all properties.
function latency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to latency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function range_Callback(hObject, eventdata, handles)
% hObject    handle to range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of range as text
%        str2double(get(hObject,'String')) returns contents of range as a double


% --- Executes during object creation, after setting all properties.
function range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
% hObject    handle to stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stop, 'Enable', 'off');
handles.work.isQuit = true;
guidata(handles.figure1,handles);
disp('Process Stoped');
reset(handles);

function reset(handles)
set(handles.show_sdiv,'Value',false);
set(handles.show_laser,'Value',false);
set(handles.show_path,'Value',false);
set(handles.latency,'Value',0);
set(handles.pause,'Value',false);

set(handles.time,'Value',0);
set(handles.box_visited,'Value',0);
set(handles.stop,'Enable','on');

 set(handles.show_sdiv,'String','Show SubDiv');
 handles.work.showSubdiv = false;
 
 set(handles.pause,'String','Pause');
 set(handles.show_path,'String','Show Path');
 handles.work.showPath = false;
 guidata(handles.figure1,handles);
 set(handles.show_laser,'String','Show Laser Scan');
 handles.work.showLaser = false;
 guidata(handles.figure1,handles);
 set(handles.time,'Enable','inactive');
 set(handles.box_visited,'Enable','inactive');

    



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
