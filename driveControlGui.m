function varargout = driveControlGui(varargin)
% DRIVECONTROLGUI MATLAB code for driveControlGui.fig
%      DRIVECONTROLGUI, by itself, creates a new DRIVECONTROLGUI or raises the existing
%      singleton*.
%
%      H = DRIVECONTROLGUI returns the handle to a new DRIVECONTROLGUI or the handle to
%      the existing singleton*.
%
%      DRIVECONTROLGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRIVECONTROLGUI.M with the given input arguments.
%
%      DRIVECONTROLGUI('Property','Value',...) creates a new DRIVECONTROLGUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before driveControlGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to driveControlGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help driveControlGui

% Last Modified by GUIDE v2.5 15-Apr-2014 18:58:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @driveControlGui_OpeningFcn, ...
                   'gui_OutputFcn',  @driveControlGui_OutputFcn, ...
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

% --- Executes just before driveControlGui is made visible.
function driveControlGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to driveControlGui (see VARARGIN)

% Choose default command line output for driveControlGui
handles.output = hObject;

handles.guifig = gcf;
guidata(handles.guifig,handles);

handles.timer = timer('TimerFcn', {@update_display,handles.guifig}, 'BusyMode','Queue',...
                      'ExecutionMode','FixedRate','Period',0.05);
start(handles.timer);

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes driveControlGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = driveControlGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit_Korr1_Callback(hObject, eventdata, handles)
function edit_Korr1_CreateFcn(hObject, eventdata, handles)
function edit_Korr2_Callback(hObject, eventdata, handles)
function edit_Korr2_CreateFcn(hObject, eventdata, handles)
function edit_Korr3_Callback(hObject, eventdata, handles)
function edit_Korr3_CreateFcn(hObject, eventdata, handles)
function edit_Korr4_Callback(hObject, eventdata, handles)
function edit_Korr4_CreateFcn(hObject, eventdata, handles)
function edit_Korr5_Callback(hObject, eventdata, handles)
function edit_Korr5_CreateFcn(hObject, eventdata, handles)
function edit_Korr6_Callback(hObject, eventdata, handles)
function edit_Korr6_CreateFcn(hObject, eventdata, handles)

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end

% global variables to find the buttons for fancy drive correction :-)
global posKorr1Minus posKorr2Minus posKorr3Minus posKorr4Minus posKorr5Minus posKorr6Minus ...
       posKorr1Plus posKorr2Plus posKorr3Plus posKorr4Plus posKorr5Plus posKorr6Plus

% set default handles
set(handles.edit_Korr1, 'String', '0,1');
set(handles.edit_Korr2, 'String', '0,2');
set(handles.edit_Korr3, 'String', '0,3');
set(handles.edit_Korr4, 'String', '0,11');
set(handles.edit_Korr5, 'String', '0,12');
set(handles.edit_Korr6, 'String', '0,13');

% select base correction as default
set(handles.panel_DriveControl, 'SelectedObject', handles.radio_BaseCorrection);
set(handles.label_Korr1, 'String', 'RKorr_X');
set(handles.label_Korr2, 'String', 'RKorr_Y');
set(handles.label_Korr3, 'String', 'RKorr_Z');
set(handles.label_Korr4, 'String', 'RKorr_A');
set(handles.label_Korr5, 'String', 'RKorr_B');
set(handles.label_Korr6, 'String', 'RKorr_C'); 

% calculate the actual button positions
posButtonUIPanel = getpixelposition(handles.panel_DriveControl);
posKorr1Minus_temp = getpixelposition(handles.btn_Korr1_Minus);
posKorr2Minus_temp = getpixelposition(handles.btn_Korr2_Minus);
posKorr3Minus_temp = getpixelposition(handles.btn_Korr3_Minus);
posKorr4Minus_temp = getpixelposition(handles.btn_Korr4_Minus);
posKorr5Minus_temp = getpixelposition(handles.btn_Korr5_Minus);
posKorr6Minus_temp = getpixelposition(handles.btn_Korr6_Minus);
posKorr1Plus_temp = getpixelposition(handles.btn_Korr1_Plus);
posKorr2Plus_temp = getpixelposition(handles.btn_Korr2_Plus);
posKorr3Plus_temp = getpixelposition(handles.btn_Korr3_Plus);
posKorr4Plus_temp = getpixelposition(handles.btn_Korr4_Plus);
posKorr5Plus_temp = getpixelposition(handles.btn_Korr5_Plus);
posKorr6Plus_temp = getpixelposition(handles.btn_Korr6_Plus);

posKorr1Minus_temp(1,1:2) = posKorr1Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr1Minus = posKorr1Minus_temp;
posKorr2Minus_temp(1,1:2) = posKorr2Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr2Minus = posKorr2Minus_temp;
posKorr3Minus_temp(1,1:2) = posKorr3Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr3Minus = posKorr3Minus_temp;
posKorr4Minus_temp(1,1:2) = posKorr4Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr4Minus = posKorr4Minus_temp;
posKorr5Minus_temp(1,1:2) = posKorr5Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr5Minus = posKorr5Minus_temp;
posKorr6Minus_temp(1,1:2) = posKorr6Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr6Minus = posKorr6Minus_temp;
posKorr1Plus_temp(1,1:2) = posKorr1Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr1Plus = posKorr1Plus_temp;
posKorr2Plus_temp(1,1:2) = posKorr2Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr2Plus = posKorr2Plus_temp;
posKorr3Plus_temp(1,1:2) = posKorr3Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr3Plus = posKorr3Plus_temp;
posKorr4Plus_temp(1,1:2) = posKorr4Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr4Plus = posKorr4Plus_temp;
posKorr5Plus_temp(1,1:2) = posKorr5Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr5Plus = posKorr5Plus_temp;
posKorr6Plus_temp(1,1:2) = posKorr6Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
posKorr6Plus = posKorr6Plus_temp;

% Update handles structure
guidata(handles.figure1, handles);

setappdata(0,'handles',handles);


% --- Executes when selected object is changed in uipanel_CorrectionSelector.
function uipanel_CorrectionSelector_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_CorrectionSelector 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if( hObject == handles.radio_AxisCorrection )
  set(handles.label_Korr1, 'String', 'AKorr_1');
  set(handles.label_Korr2, 'String', 'AKorr_2');
  set(handles.label_Korr3, 'String', 'AKorr_3');
  set(handles.label_Korr4, 'String', 'AKorr_4');
  set(handles.label_Korr5, 'String', 'AKorr_5');
  set(handles.label_Korr6, 'String', 'AKorr_6');
else
  set(handles.label_Korr1, 'String', 'RKorr_X');
  set(handles.label_Korr2, 'String', 'RKorr_Y');
  set(handles.label_Korr3, 'String', 'RKorr_Z');
  set(handles.label_Korr4, 'String', 'RKorr_A');
  set(handles.label_Korr5, 'String', 'RKorr_B');
  set(handles.label_Korr6, 'String', 'RKorr_C');  
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tic();

robotConnection = getappdata(0,'robotConnection');

localHandle = getButtonEventHandle( hObject, handles );

switch localHandle
  
  case handles.btn_Korr1_Minus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr1', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrX', '0,0' );
    end
  case handles.btn_Korr2_Minus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr2', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrY', '0,0' );
    end
  case handles.btn_Korr3_Minus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr3', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrZ', '0,0' );
    end
  case handles.btn_Korr4_Minus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr4', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrA', '0,0' );
    end
  case handles.btn_Korr5_Minus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr5', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrB', '0,0' );
    end
  case handles.btn_Korr6_Minus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr6', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrC', '0,0' );
    end   
  case handles.btn_Korr1_Plus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr1', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrX', '0,0' );
    end              
  case handles.btn_Korr2_Plus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr2', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrY', '0,0' );
    end                
  case handles.btn_Korr3_Plus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr3', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrZ', '0,0' );
    end                 
  case handles.btn_Korr4_Plus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr4', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrA', '0,0' );
    end                    
  case handles.btn_Korr5_Plus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr5', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrB', '0,0' );
    end                     
  case handles.btn_Korr6_Plus
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr6', '0,0' );
    else
      robotConnection.modifyRKorrVariable( 'RKorrC', '0,0' );
    end    
  otherwise
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tic();

robotConnection = getappdata(0,'robotConnection');

localHandle = getButtonEventHandle( hObject, handles );

switch localHandle
  
  case handles.btn_Korr1_Minus
    value = get(handles.edit_Korr1,'String');
    value = strcat('-',value);
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr1', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrX', value );
    end
  case handles.btn_Korr2_Minus
    value = get(handles.edit_Korr2,'String');
    value = strcat('-',value);
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr2', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrY', value );
    end
  case handles.btn_Korr3_Minus
    value = get(handles.edit_Korr3,'String');
    value = strcat('-',value);    
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr3', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrZ', value );
    end
  case handles.btn_Korr4_Minus
    value = get(handles.edit_Korr4,'String');
    value = strcat('-',value);    
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr4', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrA', value );
    end
  case handles.btn_Korr5_Minus
    value = get(handles.edit_Korr5,'String');
    value = strcat('-',value);    
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr5', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrB', value );
    end
  case handles.btn_Korr6_Minus
    value = get(handles.edit_Korr6,'String');
    value = strcat('-',value);    
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr6', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrC', value );
    end           
  case handles.btn_Korr1_Plus
    value = get(handles.edit_Korr1,'String');
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr1', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrX', value );
    end                
  case handles.btn_Korr2_Plus
    value = get(handles.edit_Korr2,'String');
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr2', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrY', value );
    end                  
  case handles.btn_Korr3_Plus
    value = get(handles.edit_Korr3,'String');
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr3', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrZ', value );
    end                   
  case handles.btn_Korr4_Plus
    value = get(handles.edit_Korr4,'String');
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr4', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrA', value );
    end                      
  case handles.btn_Korr5_Plus
    value = get(handles.edit_Korr5,'String');
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr5', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrB', value );
    end                       
  case handles.btn_Korr6_Plus
    value = get(handles.edit_Korr6,'String');
    corrType = get(handles.radio_AxisCorrection,'Value');
    if( corrType == 1 )
      robotConnection.modifyAKorrVariable( 'AKorr6', value );
    else
      robotConnection.modifyRKorrVariable( 'RKorrC', value );
    end      
  otherwise
end

function buttonHandle = getButtonEventHandle( hObject, handles )

global posKorr1Minus posKorr2Minus posKorr3Minus posKorr4Minus posKorr5Minus posKorr6Minus ...
       posKorr1Plus posKorr2Plus posKorr3Plus posKorr4Plus posKorr5Plus posKorr6Plus

mousePos=get(hObject,'CurrentPoint');

if( (mousePos(1) > posKorr1Minus(1,1)) && (mousePos(1) < (posKorr1Minus(1,1)+posKorr1Minus(1,3))) && ...
    (mousePos(2) > posKorr1Minus(1,2)) && (mousePos(2) < (posKorr1Minus(1,2)+posKorr1Minus(1,4))) )
  buttonHandle = handles.btn_Korr1_Minus;
elseif( (mousePos(1) > posKorr2Minus(1,1)) && (mousePos(1) < (posKorr2Minus(1,1)+posKorr2Minus(1,3))) && ...
        (mousePos(2) > posKorr2Minus(1,2)) && (mousePos(2) < (posKorr2Minus(1,2)+posKorr2Minus(1,4))) )
  buttonHandle = handles.btn_Korr2_Minus;
elseif( (mousePos(1) > posKorr3Minus(1,1)) && (mousePos(1) < (posKorr3Minus(1,1)+posKorr3Minus(1,3))) && ...
        (mousePos(2) > posKorr3Minus(1,2)) && (mousePos(2) < (posKorr3Minus(1,2)+posKorr3Minus(1,4))) )
  buttonHandle = handles.btn_Korr3_Minus;  
elseif( (mousePos(1) > posKorr4Minus(1,1)) && (mousePos(1) < (posKorr4Minus(1,1)+posKorr4Minus(1,3))) && ...
        (mousePos(2) > posKorr4Minus(1,2)) && (mousePos(2) < (posKorr4Minus(1,2)+posKorr4Minus(1,4))) )
  buttonHandle = handles.btn_Korr4_Minus;    
elseif( (mousePos(1) > posKorr5Minus(1,1)) && (mousePos(1) < (posKorr5Minus(1,1)+posKorr5Minus(1,3))) && ...
        (mousePos(2) > posKorr5Minus(1,2)) && (mousePos(2) < (posKorr5Minus(1,2)+posKorr5Minus(1,4))) )
  buttonHandle = handles.btn_Korr5_Minus;  
elseif( (mousePos(1) > posKorr6Minus(1,1)) && (mousePos(1) < (posKorr6Minus(1,1)+posKorr6Minus(1,3))) && ...
        (mousePos(2) > posKorr6Minus(1,2)) && (mousePos(2) < (posKorr6Minus(1,2)+posKorr6Minus(1,4))) )
  buttonHandle = handles.btn_Korr6_Minus;    
elseif( (mousePos(1) > posKorr1Plus(1,1)) && (mousePos(1) < (posKorr1Plus(1,1)+posKorr1Plus(1,3))) && ...
        (mousePos(2) > posKorr1Plus(1,2)) && (mousePos(2) < (posKorr1Plus(1,2)+posKorr1Plus(1,4))) )
  buttonHandle = handles.btn_Korr1_Plus;      
elseif( (mousePos(1) > posKorr2Plus(1,1)) && (mousePos(1) < (posKorr2Plus(1,1)+posKorr2Plus(1,3))) && ...
        (mousePos(2) > posKorr2Plus(1,2)) && (mousePos(2) < (posKorr2Plus(1,2)+posKorr2Plus(1,4))) )
  buttonHandle = handles.btn_Korr2_Plus;        
elseif( (mousePos(1) > posKorr3Plus(1,1)) && (mousePos(1) < (posKorr3Plus(1,1)+posKorr3Plus(1,3))) && ...
        (mousePos(2) > posKorr3Plus(1,2)) && (mousePos(2) < (posKorr3Plus(1,2)+posKorr3Plus(1,4))) )
  buttonHandle = handles.btn_Korr3_Plus;          
elseif( (mousePos(1) > posKorr4Plus(1,1)) && (mousePos(1) < (posKorr4Plus(1,1)+posKorr4Plus(1,3))) && ...
        (mousePos(2) > posKorr4Plus(1,2)) && (mousePos(2) < (posKorr4Plus(1,2)+posKorr4Plus(1,4))) )
  buttonHandle = handles.btn_Korr4_Plus;          
elseif( (mousePos(1) > posKorr5Plus(1,1)) && (mousePos(1) < (posKorr5Plus(1,1)+posKorr5Plus(1,3))) && ...
        (mousePos(2) > posKorr5Plus(1,2)) && (mousePos(2) < (posKorr5Plus(1,2)+posKorr5Plus(1,4))) )
  buttonHandle = handles.btn_Korr5_Plus;          
elseif( (mousePos(1) > posKorr6Plus(1,1)) && (mousePos(1) < (posKorr6Plus(1,1)+posKorr6Plus(1,3))) && ...
        (mousePos(2) > posKorr6Plus(1,2)) && (mousePos(2) < (posKorr6Plus(1,2)+posKorr6Plus(1,4))) )
  buttonHandle = handles.btn_Korr6_Plus;          
else
  buttonHandle = 0;
end


% --- Executes on button press in btn_CloseConnection.
function btn_CloseConnection_Callback(hObject, eventdata, handles)
% hObject    handle to btn_CloseConnection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
robotConnection = getappdata(0,'robotConnection');

robotConnection.closeConnection();

% --- Executes on button press in btn_OpenConnection.
function btn_OpenConnection_Callback(hObject, eventdata, handles)
% hObject    handle to btn_OpenConnection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
robotConnection = getappdata(0,'robotConnection');

robotConnection.connect();

% --- Executes on button press in btn_Close.
function btn_Close_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.timer);

robotConnection = getappdata(0,'robotConnection');

robotConnection.closeConnection();

allObjectHandles = findall(0);
% ignore matlab console(root)
allObjectHandles = allObjectHandles(2:end);
% now delete all handles
delete(allObjectHandles);

delete(gcbf);



function update_display(hObject,eventdata,handles)

if( ishandle(handles) )
  handles = guidata(handles);

  robotConnection = getappdata(0,'robotConnection');

  % set string to textbox
  set(handles.text_RobotInfo,'String',robotConnection.getAktRobotInfo());
  set(handles.text_CommandValues,'String',robotConnection.getAktCommandString());
  set(handles.text_ConnectionState,'String',robotConnection.getConnectionState());
  set(handles.text_LockingState,'String',robotConnection.isCorrectionCommandAllowed());
  set(handles.text_SendPackagesCounter,'String',robotConnection.getPackagesSendCounter());
  set(handles.text_ReceivedPackagesCounter,'String',robotConnection.getPackagesReceivedCounter());
  set(handles.text_CycleTimeUS,'String',robotConnection.getCommunicationTimeMicroSeconds());
  set(handles.text_DelayInfo,'String',robotConnection.getWrapperDelayInfo());

  guidata(handles.guifig, handles);
end


% --- Executes on button press in btn_Info.
function btn_Info_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btn_ResetStatistics.
function btn_ResetStatistics_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ResetStatistics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

robotConnection = getappdata(0,'robotConnection');

robotConnection.resetStatistics();



% --- Executes on button press in btnResetCommandData.
function btnResetCommandData_Callback(hObject, eventdata, handles)
% hObject    handle to btnResetCommandData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


robotConnection = getappdata(0,'robotConnection');

robotConnection.modifyRKorrVariable( 'RKorrX', '0,0' );
robotConnection.modifyRKorrVariable( 'RKorrY', '0,0' );
robotConnection.modifyRKorrVariable( 'RKorrZ', '0,0' );
robotConnection.modifyRKorrVariable( 'RKorrA', '0,0' );
robotConnection.modifyRKorrVariable( 'RKorrB', '0,0' );
robotConnection.modifyRKorrVariable( 'RKorrC', '0,0' );

robotConnection.modifyAKorrVariable( 'AKorr1', '0,0' );
robotConnection.modifyAKorrVariable( 'AKorr2', '0,0' );
robotConnection.modifyAKorrVariable( 'AKorr3', '0,0' );
robotConnection.modifyAKorrVariable( 'AKorr4', '0,0' );
robotConnection.modifyAKorrVariable( 'AKorr5', '0,0' );
robotConnection.modifyAKorrVariable( 'AKorr6', '0,0' );

set(handles.edit_Korr1,'String', '0,1');
set(handles.edit_Korr2,'String', '0,1');
set(handles.edit_Korr3,'String', '0,1');
set(handles.edit_Korr4,'String', '0,1');
set(handles.edit_Korr5,'String', '0,1');
set(handles.edit_Korr6,'String', '0,1');


% --- Executes on button press in btnSTOP.
function btnSTOP_Callback(hObject, eventdata, handles)
% hObject    handle to btnSTOP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

robotConnection = getappdata(0,'robotConnection');

robotConnection.lockCorrectionCommands();

% --- Executes on button press in btnUnlockSTOP.
function btnUnlockSTOP_Callback(hObject, eventdata, handles)
% hObject    handle to btnUnlockSTOP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

robotConnection = getappdata(0,'robotConnection');

robotConnection.unlockCorrectionCommands();
