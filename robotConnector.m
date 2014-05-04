classdef robotConnector < handle
  
  properties (GetAccess='private', SetAccess='private')
    
    ipAddress = '';
    port = 0;
    cycleTime = 0;
    fullPathToWrapperDll = '';
    
    % objects to connect to kuka robot
    kukaAssembly = 0;
    connector = 0;
    
    aktRobotData = 0;
    
    RKorrX_ = '0';
    RKorrY_ = '0';
    RKorrZ_ = '0';
    RKorrA_ = '0';
    RKorrB_ = '0';
    RKorrC_ = '0';
    
    AKorr1_ = '0';
    AKorr2_ = '0';
    AKorr3_ = '0';
    AKorr4_ = '0';
    AKorr5_ = '0';
    AKorr6_ = '0';
    
    guiHandle;
    guiTimer;
    guiButtonLength = 140;
    guiButtonHeight = 30;
    guiRightFrame = 590;
    guiLeftFrameBottomColumn = 230;
    guiRightFrameBottomColumn = 100;
    guiBorder = 10;
  end
  
  
  methods (Access = public)
    function obj = robotConnector( ipAddress, port, cycleTime, fullPathToWrapperDll )
      
      % save the given parameters in the local variables
      obj.cycleTime = cycleTime;
      obj.ipAddress = ipAddress;
      obj.port = port;
      obj.fullPathToWrapperDll = fullPathToWrapperDll;
      
      obj.kukaAssembly = NET.addAssembly( obj.fullPathToWrapperDll );
      obj.connector = KukaMatlabConnector.ConnectorObject('commanddoc.xml', obj.ipAddress, port);
     
    end
    
    function delete(obj)
      
      obj.connector.stopRobotConnChannel();
      
    end
    
    % ----------------------------------------------------------------------------------------------------------------------------
    %
    %  Connection Handling Functions
    %
    %
    % ----------------------------------------------------------------------------------------------------------------------------    
    function returnal = connect(obj)
      
      returnal = obj.connector.initializeRobotListenThread();
      
    end
    
    function returnal = closeConnection(obj)
      
      returnal = obj.connector.stopRobotConnChannel();
      
    end
    
    % ----------------------------------------------------------------------------------------------------------------------------
    %
    %  Utility Functions
    %
    %
    % ----------------------------------------------------------------------------------------------------------------------------    
    function aktRobotInfoString = getAktRobotInfo(obj)
      
      tempAktRobotInfoString = obj.connector.getRobotInfoString();
      
      aktRobotInfoString = char(tempAktRobotInfoString);
      
    end
    
    function aktCommandString = getAktCommandString(obj)
      
      tempAktCommandString = obj.connector.getCommandString();
      
      aktCommandString = char(tempAktCommandString);
      
    end
    
    function connected = isConnected( obj )
      
      localConnectionState = obj.connector.getRobotConnectionState();
      if( localConnectionState == KukaMatlabConnector.ConnectionState.running )
        connected = 1;
      else
        connected = 0;
      end
      
    end
    
    function connectionState = getConnectionState( obj )
      
      if( isa( obj.connector, 'KukaMatlabConnector.ConnectorObject') )
        localConnectionState = obj.connector.getRobotConnectionState();
        switch localConnectionState
          case KukaMatlabConnector.ConnectionState.running
            connectionState = 'running'; 
          case KukaMatlabConnector.ConnectionState.init
            connectionState = 'init';
          case KukaMatlabConnector.ConnectionState.starting
            connectionState = 'starting';
          case KukaMatlabConnector.ConnectionState.listening
            connectionState = 'listening';
          case KukaMatlabConnector.ConnectionState.connecting
            connectionState = 'connecting';
          case KukaMatlabConnector.ConnectionState.closeRequest
            connectionState = 'closeRequest';
          case KukaMatlabConnector.ConnectionState.closing
            connectionState = 'closing';
          otherwise
            connectionState = 'undefined';
        end
      end
      
    end
    
    function debugInfo = getWrapperDebugCommInfo( obj )
     
      debugInfo = char(obj.connector.getDebugCommInfo());
      
    end
    
    function lockingState = isCorrectionCommandAllowed( obj )
      
      if( obj.connector.isCorrectionCommandAllowed() )
        lockingState = 'unlocked';
      else
        lockingState = 'locked';
      end
      
    end
    
    function sendPackages = getPackagesSentCounter( obj )
      
      sendPackages = obj.connector.getPackagesSentCounter();
      
    end
    
    function receivedPackages = getPackagesReceivedCounter( obj )
    
      receivedPackages = obj.connector.getPackagesReceivedCounter();
      
    end
    
    function communicationTimeMilliseconds = getCommunicationTimeMilliSeconds( obj )
     
      communicationTimeMilliseconds = obj.connector.getCommunicationTimeMilliSeconds();
      
    end
    
    
    function communicationTimeTicks = getCommunicationTimeTicks( obj )
      
      communicationTimeTicks = obj.connector.getCommunicationTimeTicks();
      
    end
    
    
    function communicationTimeMicroSeconds = getCommunicationTimeMicroSeconds( obj )
      
      communicationTimeMicroSeconds = obj.connector.getCommunicationTimeMicroSeconds();  
      
    end
    
    function obj = resetStatistics( obj )
      
      obj.connector.resetStatistics();
      
    end
    
    
    function obj = lockCorrectionCommands( obj )
      
      obj.connector.lockCorrectionCommands();
      
    end
    
    
    function obj = unlockCorrectionCommands( obj )
      
      obj.connector.unlockCorrectionCommands();
      
    end
    
    
    function stringVar = convertByteToString( obj, byteAy )
      
      aktCell = cellstr(char(byteAy));
      aySize = size(aktCell);
    
      for i=1:1:aySize(1,1)
        if( isempty(aktCell{i,1}) )
          aktCell{i,1} = ' ';
        end
      end
    
      stringVar = [aktCell{:}];      
      
    end
    
    function [values] = getValuesOutOfLine( obj, line )
      
      values=zeros(1,6);

      localString = strrep(line,'/','');
      attributes = regexp(localString,' ','split');
      count = 1;
      attributeCount = size(attributes);
    
      for i=1:1:attributeCount(1,2)
        attributeString = attributes{i};
     
        if( strfind(attributeString,'=') )
          attributeSplit = regexp(attributeString,'=','split');
          value = attributeSplit{2};
          value = strtok(value,'""');
          value = strrep(value,',','.');
          value = str2double(value);
          values(count) = value;
          count=count+1;
        end
      end      
      
    end
    
    function [RIst] = decodeRobotInfoStringRIst( obj, byteAy )
      
      aktStr = obj.convertByteToString( byteAy );
      
      RIst = zeros(1,6);
 
      str = textscan( aktStr, '%s','delimiter', '<>');
      if( isempty(str) )
        %break; 
      else
        strSize = size(str{1});
        for i=1:1:strSize(1)
          if( strfind(str{1}{i},'RIst') )
            RIst = obj.getValuesOutOfLine( str{1}{i} ); 
            continue;
          end
        end
      end
      
    end
    
    function [AIst] = decodeRobotInfoStringAIst( obj, byteAy )

      aktStr = obj.convertByteToString( byteAy );
      
      RIst = zeros(1,6);
      RSol = zeros(1,6);
      AIst = zeros(1,6);
      ASol = zeros(1,6);
      MACur = zeros(1,6);
      FT = zeros(1,7);
 
      str = textscan( aktStr, '%s','delimiter', '<>');
      if( isempty(str) )
        %break; 
      else
        strSize = size(str{1});
        for i=1:1:strSize(1)
          if( strfind(str{1}{i},'AIPos') ) 
            AIst = obj.getValuesOutOfLine( str{1}{i} ); 
            continue;
          end
        end
      end            
      
    end
    
    function [RIst, RSol, AIst, ASol, MACur, FT] = decodeRobotInfoString( obj, byteAy )
    
      aktStr = obj.convertByteToString( byteAy );
      
      RIst = zeros(1,6);
      RSol = zeros(1,6);
      AIst = zeros(1,6);
      ASol = zeros(1,6);
      MACur = zeros(1,6);
      FT = zeros(1,7);
 
      str = textscan( aktStr, '%s','delimiter', '<>');
      if( isempty(str) )
        %break; 
      else
        strSize = size(str{1});
        for i=1:1:strSize(1)
          if( strfind(str{1}{i},'RIst') )
            RIst = obj.getValuesOutOfLine( str{1}{i} ); 
            continue;
          end
    
          if( strfind(str{1}{i},'RSol') ) 
            RSol = obj.getValuesOutOfLine( str{1}{i} ); 
            continue;
          end
    
          if( strfind(str{1}{i},'AIPos') ) 
            AIst = obj.getValuesOutOfLine( str{1}{i} ); 
            continue;
          end
    
          if( strfind(str{1}{i},'ASPos') ) 
            ASol = obj.getValuesOutOfLine( str{1}{i} ); 
            continue;
          end
    
          if( strfind(str{1}{i}, 'MACur') )
            MACur = obj.getValuesOutOfLine( str{1}{i} );
            continue;
          end
    
          if( strfind(str{1}{i}, 'FT') )
            FT = obj.getValuesOutOfLine( str{1}{i} );
            continue;
          end
        end
      end      
      
    end
      
    % ----------------------------------------------------------------------------------------------------------------------------
    %
    %  Correction Functions
    %
    %
    % ----------------------------------------------------------------------------------------------------------------------------
    function returnVal = modifyRKorrVariable(obj, variable, value )
      
      if( strcmp(variable,'RKorrX') || strcmp(variable,'RKorrY') || ...
          strcmp(variable,'RKorrZ') || strcmp(variable,'RKorrA') || ...
          strcmp(variable,'RKorrB') || strcmp(variable,'RKorrC') )
        returnVal = obj.connector.modifyRKorrVariable(variable, value);
      else
        disp('wrong RKorr chosen, please take ''RKorrX'', ''RKorrY'', ''RKorrZ'', ''RKorrA'', ''RKorrB'', ''RKorrC'' as possible values');
      end
      
    end
    
    function returnVal = modifyAKorrVariable(obj, variable, value )
      
      if( strcmp(variable,'AKorr1') || strcmp(variable,'AKorr2') || ...
          strcmp(variable,'AKorr3') || strcmp(variable,'AKorr4') || ...
          strcmp(variable,'AKorr5') || strcmp(variable,'AKorr6') )
        returnVal = obj.connector.modifyAKorrVariable(variable, value);
      else
        disp('wrong RKorr chosen, please take ''AKorr1'', ''AKorr2'', ''AKorr3'', ''AKorr4'', ''AKorr5'', ''AKorr6'' as possible values');
      end
      
    end
    
    function returnVal = modifyRKorr( obj, command )
      
      returnVal = obj.connector.modifyRKorr( command );
      
    end
    
    function returnVal = modifyAKorr( obj, command )
      
      returnVal = obj.connector.modifyAKorr( command );
      
    end

    % ----------------------------------------------------------------------------------------------------------------------------
    %
    %  Synchron Mode Functions
    %
    %
    % ----------------------------------------------------------------------------------------------------------------------------
    function startSynchronAKorr( obj )
      
    end
    
    function endSynchronAKorr( obj )
      
    end
    
    function modifyAKorrSynchron( obj, command )
      
    end
    
    function startSynchronRKorr( obj )
      
    end
    
    function endSynchronRKorr( obj )
      
    end
    
    function modifyRKorrSynchron( obj, command )
      
    end
    
    % ----------------------------------------------------------------------------------------------------------------------------
    %
    %  GUI functions
    %
    %
    %
    % ----------------------------------------------------------------------------------------------------------------------------
    function initGUI( obj )
      
      % -----------------------------------------------------------------------------------------------------------------------
      % Create the gui
      % -----------------------------------------------------------------------------------------------------------------------
      % create guiHandle
      obj.guiHandle.figure = figure('Visible','off','Menu','none','Resize','off','Units','pixels','Position',[100 100 920 700]);
      movegui(obj.guiHandle.figure,'center');
      % create first buttons
      obj.guiHandle.buttonGroupProgrammHandling = uibuttongroup('Units','pixels','Position',[obj.guiRightFrame+obj.guiBorder obj.guiBorder 310 50]);
      obj.guiHandle.buttonInfo = uicontrol('parent',obj.guiHandle.buttonGroupProgrammHandling,'style','pushbutton','Units','pixels','position',[(obj.guiBorder) obj.guiBorder obj.guiButtonLength obj.guiButtonHeight],'string','Info');
      obj.guiHandle.buttonClose = uicontrol('parent',obj.guiHandle.buttonGroupProgrammHandling,'style','pushbutton','Units','pixels','position',[(obj.guiBorder+obj.guiButtonLength+obj.guiBorder) obj.guiBorder obj.guiButtonLength obj.guiButtonHeight],'string','Close');
      % Button Group Jogging
      obj.guiHandle.buttonGroupJogging = uibuttongroup('Units','pixels','position',[(obj.guiRightFrame+obj.guiBorder) obj.guiBorder+90+obj.guiBorder+90+obj.guiBorder 310 390]);
      obj.guiHandle.buttonStopJogging = uicontrol('style','pushbutton','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[(obj.guiBorder+obj.guiButtonLength+obj.guiBorder) obj.guiBorder obj.guiButtonLength obj.guiButtonHeight],'string','STOP');
      obj.guiHandle.buttonStartJogging = uicontrol('style','pushbutton','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[obj.guiBorder obj.guiBorder obj.guiButtonLength obj.guiButtonHeight],'string','Unlock STOP');
      obj.guiHandle.buttonResetStatistics = uicontrol('Parent',obj.guiHandle.buttonGroupJogging,'Style','pushbutton','HandleVisibility','off','Units','pixels','Position',[obj.guiBorder (obj.guiBorder+obj.guiButtonHeight+obj.guiBorder) obj.guiButtonLength obj.guiButtonHeight],'string','Reset Statistics');
      obj.guiHandle.buttonResetCommandData = uicontrol('style','pushbutton','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[(obj.guiBorder+obj.guiButtonLength+obj.guiBorder) (obj.guiBorder+obj.guiButtonHeight+obj.guiBorder) obj.guiButtonLength obj.guiButtonHeight],'string','Reset Command Data');
      obj.guiHandle.buttonKorr1Minus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[100 (100+5*45) 40 40],'string','-');
      obj.guiHandle.buttonKorr2Minus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[100 (100+4*45) 40 40],'string','-');
      obj.guiHandle.buttonKorr3Minus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[100 (100+3*45) 40 40],'string','-');
      obj.guiHandle.buttonKorr4Minus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[100 (100+2*45) 40 40],'string','-');
      obj.guiHandle.buttonKorr5Minus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[100 (100+1*45) 40 40],'string','-');
      obj.guiHandle.buttonKorr6Minus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[100 (100+0*45) 40 40],'string','-');
      obj.guiHandle.buttonKorr1Plus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[200 (100+5*45) 40 40],'string','+');
      obj.guiHandle.buttonKorr2Plus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[200 (100+4*45) 40 40],'string','+');
      obj.guiHandle.buttonKorr3Plus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[200 (100+3*45) 40 40],'string','+');
      obj.guiHandle.buttonKorr4Plus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[200 (100+2*45) 40 40],'string','+');
      obj.guiHandle.buttonKorr5Plus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[200 (100+1*45) 40 40],'string','+');
      obj.guiHandle.buttonKorr6Plus = uicontrol('style','pushbutton','enable','inactive','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[200 (100+0*45)  40 40],'string','+');
      obj.guiHandle.editTextKorr1 = uicontrol('style','edit','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[150 (110+5*45) 40 20],'string','');
      obj.guiHandle.editTextKorr2 = uicontrol('style','edit','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[150 (110+4*45) 40 20],'string','');
      obj.guiHandle.editTextKorr3 = uicontrol('style','edit','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[150 (110+3*45) 40 20],'string','');
      obj.guiHandle.editTextKorr4 = uicontrol('style','edit','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[150 (110+2*45) 40 20],'string','');
      obj.guiHandle.editTextKorr5 = uicontrol('style','edit','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[150 (110+1*45) 40 20],'string','');
      obj.guiHandle.editTextKorr6 = uicontrol('style','edit','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[150 (110+0*45) 40 20],'string','');
      obj.guiHandle.staticTextKorr1 = uicontrol('style','text','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[30 (110+5*45) 60 20],'string','Korr1');
      obj.guiHandle.staticTextKorr2 = uicontrol('style','text','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[30 (110+4*45) 60 20],'string','Korr2');
      obj.guiHandle.staticTextKorr3 = uicontrol('style','text','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[30 (110+3*45) 60 20],'string','Korr3');
      obj.guiHandle.staticTextKorr4 = uicontrol('style','text','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[30 (110+2*45) 60 20],'string','Korr4');
      obj.guiHandle.staticTextKorr5 = uicontrol('style','text','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[30 (110+1*45) 60 20],'string','Korr5');
      obj.guiHandle.staticTextKorr6 = uicontrol('style','text','parent',obj.guiHandle.buttonGroupJogging,'Units','pixels','position',[30 (110+0*45) 60 20],'string','Korr6');
      % Jogging Selector
      obj.guiHandle.buttonGroupJoggingSel = uibuttongroup('Units','pixels','position',[(obj.guiRightFrame+obj.guiBorder) obj.guiBorder+90+obj.guiBorder+90+obj.guiBorder+390+obj.guiBorder 310 90]);
      obj.guiHandle.radioButtonAKorrCorrection = uicontrol('style','radiobutton','parent',obj.guiHandle.buttonGroupJoggingSel,'Units','pixels','position',[20 15 160 20],'string','AKorr Correction');
      obj.guiHandle.radioButtonRKorrCorrection = uicontrol('style','radiobutton','parent',obj.guiHandle.buttonGroupJoggingSel,'Units','pixels','position',[20 40 160 20],'string','RKorr Correction');
      obj.guiHandle.buttonOpenConnection = uicontrol('Parent',obj.guiHandle.buttonGroupJoggingSel,'Style','pushbutton','HandleVisibility','off','Units','pixels','Position', [obj.guiBorder+obj.guiButtonLength+obj.guiBorder obj.guiBorder+obj.guiButtonHeight+obj.guiBorder obj.guiButtonLength obj.guiButtonHeight],'string','Open Connection'); 
      obj.guiHandle.buttonCloseConnection = uicontrol('Parent',obj.guiHandle.buttonGroupJoggingSel,'Style','pushbutton','HandleVisibility','off','Units','pixels','Position',[obj.guiBorder+obj.guiButtonLength+obj.guiBorder obj.guiBorder obj.guiButtonLength obj.guiButtonHeight],'string','Close Connection');
      % Communication Data
      obj.guiHandle.uipanelRobotInfoData = uipanel('Units','pixels','Position',[obj.guiBorder obj.guiBorder+90+obj.guiBorder+250+obj.guiBorder 570 330]);
      obj.guiHandle.staticTextRobotInfo = uicontrol('style','text','parent',obj.guiHandle.uipanelRobotInfoData,'Units','pixels','position',[obj.guiBorder obj.guiBorder 550 310],'string','Robot_Info');
      obj.guiHandle.uipanelCommandData = uipanel('Units','pixels','position',[obj.guiBorder obj.guiBorder+90+obj.guiBorder 570 250]);
      obj.guiHandle.staticTextCommandData = uicontrol('style','text','parent',obj.guiHandle.uipanelCommandData,'Units','pixels','position',[obj.guiBorder obj.guiBorder 550 230],'string','Command_Data');
      % Statistic and Info Data
      obj.guiHandle.uipanelStatisticsInfo = uipanel('Units','pixels','position',[obj.guiRightFrame+obj.guiBorder obj.guiBorder+50+obj.guiBorder 310 130]);
      obj.guiHandle.staticTextDescrConnectionState = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position', [obj.guiBorder     obj.guiBorder+18+18+18+18+18 120 15],'string','Connection State');
      obj.guiHandle.staticTextDescrLockingState = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position',    [obj.guiBorder     obj.guiBorder+18+18+18+18    120 15],'string','Locking State');
      obj.guiHandle.staticTextDescrCycleTime = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position',       [obj.guiBorder     obj.guiBorder+18+18+18       120 15],'string','Cycle Time [us]');
      obj.guiHandle.staticTextDescrSendPackages = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position',    [obj.guiBorder     obj.guiBorder+18+18          120 15],'string','Send Packages');
      obj.guiHandle.staticTextDescrReceivedPackages = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position',[obj.guiBorder     obj.guiBorder+18             120 15],'string','Received Packages');
      obj.guiHandle.staticTextDescrDebugInfo = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position',       [obj.guiBorder     obj.guiBorder                120 15],'string','Debug Info');      
      obj.guiHandle.staticTextConnectionState = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position',      [obj.guiBorder+120 obj.guiBorder+18+18+18+18+18 120 15],'string','closingRequest');
      obj.guiHandle.staticTextLockingState = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position',         [obj.guiBorder+120 obj.guiBorder+18+18+18+18    120 15],'string','unlocked');
      obj.guiHandle.staticTextCycleTime = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position',            [obj.guiBorder+120 obj.guiBorder+18+18+18       120 15],'string','12523');
      obj.guiHandle.staticTextSendPackages = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position',         [obj.guiBorder+120 obj.guiBorder+18+18          120 15],'string','12312312');
      obj.guiHandle.staticTextReceivedPackages = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position',     [obj.guiBorder+120 obj.guiBorder+18             120 15],'string','12312312');
      obj.guiHandle.staticTextDebugInfo = uicontrol('parent',obj.guiHandle.uipanelStatisticsInfo,'style','text','Units','pixels','HorizontalAlignment','left','position',            [obj.guiBorder+120 obj.guiBorder                160 15],'string','debugInfo');
      % set the callbacks
      set(obj.guiHandle.buttonGroupJoggingSel,'SelectionChange', {@obj.changedCorrectionSelection});
      set(obj.guiHandle.figure,'WindowButtonUp',{@obj.buttonUpOnFigure});
      set(obj.guiHandle.figure,'WindowButtonDown',{@obj.buttonDownOnFigure});
      set(obj.guiHandle.buttonOpenConnection,'callback',{@obj.btnOpenConnection});
      set(obj.guiHandle.buttonCloseConnection,'callback',{@obj.btnCloseConnection});
      set(obj.guiHandle.buttonClose,'callback',@obj.btnClose);
      set(obj.guiHandle.buttonResetStatistics,'callback',{@obj.btnResetStatistics});
      set(obj.guiHandle.buttonResetCommandData,'callback',{@obj.btnResetCommandData});
      set(obj.guiHandle.buttonStopJogging,'callback',{@obj.btnStopJogging});
      set(obj.guiHandle.buttonStartJogging,'callback',{@obj.btnStartJogging});
      % show the gui
      set(obj.guiHandle.figure,'Visible','on');
      
      % -----------------------------------------------------------------------------------------------------------------------
      % Initialize Timer
      % -----------------------------------------------------------------------------------------------------------------------
      obj.guiTimer = timer('TimerFcn', {@obj.updateGUIDisplay}, 'BusyMode','Queue','ExecutionMode','FixedRate','Period',0.05);
      start(obj.guiTimer);
      
      % -----------------------------------------------------------------------------------------------------------------------
      % initialize the values
      % -----------------------------------------------------------------------------------------------------------------------
      % set default handles
      set(obj.guiHandle.editTextKorr1, 'String', '0,1');
      set(obj.guiHandle.editTextKorr2, 'String', '0,2');
      set(obj.guiHandle.editTextKorr3, 'String', '0,3');
      set(obj.guiHandle.editTextKorr4, 'String', '0,11');
      set(obj.guiHandle.editTextKorr5, 'String', '0,12');
      set(obj.guiHandle.editTextKorr6, 'String', '0,13');
      % select base correction as default
      set(obj.guiHandle.buttonGroupJoggingSel, 'SelectedObject', obj.guiHandle.radioButtonRKorrCorrection);
      set(obj.guiHandle.staticTextKorr1, 'String', 'RKorr_X');
      set(obj.guiHandle.staticTextKorr2, 'String', 'RKorr_Y');
      set(obj.guiHandle.staticTextKorr3, 'String', 'RKorr_Z');
      set(obj.guiHandle.staticTextKorr4, 'String', 'RKorr_A');
      set(obj.guiHandle.staticTextKorr5, 'String', 'RKorr_B');
      set(obj.guiHandle.staticTextKorr6, 'String', 'RKorr_C'); 

      % get the actual button positions
      posButtonUIPanel = getpixelposition(obj.guiHandle.buttonGroupJogging);
      posKorr1Minus_temp = getpixelposition(obj.guiHandle.buttonKorr1Minus);
      posKorr2Minus_temp = getpixelposition(obj.guiHandle.buttonKorr2Minus);
      posKorr3Minus_temp = getpixelposition(obj.guiHandle.buttonKorr3Minus);
      posKorr4Minus_temp = getpixelposition(obj.guiHandle.buttonKorr4Minus);
      posKorr5Minus_temp = getpixelposition(obj.guiHandle.buttonKorr5Minus);
      posKorr6Minus_temp = getpixelposition(obj.guiHandle.buttonKorr6Minus);
      posKorr1Plus_temp = getpixelposition(obj.guiHandle.buttonKorr1Plus);
      posKorr2Plus_temp = getpixelposition(obj.guiHandle.buttonKorr2Plus);
      posKorr3Plus_temp = getpixelposition(obj.guiHandle.buttonKorr3Plus);
      posKorr4Plus_temp = getpixelposition(obj.guiHandle.buttonKorr4Plus);
      posKorr5Plus_temp = getpixelposition(obj.guiHandle.buttonKorr5Plus);
      posKorr6Plus_temp = getpixelposition(obj.guiHandle.buttonKorr6Plus);    
      % and calculate the marks for button mouse up event
      posKorr1Minus_temp(1,1:2) = posKorr1Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr1Minus = posKorr1Minus_temp;
      posKorr2Minus_temp(1,1:2) = posKorr2Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr2Minus = posKorr2Minus_temp;
      posKorr3Minus_temp(1,1:2) = posKorr3Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr3Minus = posKorr3Minus_temp;
      posKorr4Minus_temp(1,1:2) = posKorr4Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr4Minus = posKorr4Minus_temp;
      posKorr5Minus_temp(1,1:2) = posKorr5Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr5Minus = posKorr5Minus_temp;
      posKorr6Minus_temp(1,1:2) = posKorr6Minus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr6Minus = posKorr6Minus_temp;
      posKorr1Plus_temp(1,1:2) = posKorr1Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr1Plus = posKorr1Plus_temp;
      posKorr2Plus_temp(1,1:2) = posKorr2Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr2Plus = posKorr2Plus_temp;
      posKorr3Plus_temp(1,1:2) = posKorr3Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr3Plus = posKorr3Plus_temp;
      posKorr4Plus_temp(1,1:2) = posKorr4Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr4Plus = posKorr4Plus_temp;
      posKorr5Plus_temp(1,1:2) = posKorr5Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr5Plus = posKorr5Plus_temp;
      posKorr6Plus_temp(1,1:2) = posKorr6Plus_temp(1,1:2) + posButtonUIPanel(1,1:2);
      obj.guiHandle.posKorr6Plus = posKorr6Plus_temp;      
    end
    
    function obj = changedCorrectionSelection(obj,~,~)

      value = get(obj.guiHandle.radioButtonRKorrCorrection,'Value');
      
      if( value == 0 )
        set(obj.guiHandle.staticTextKorr1, 'String', 'AKorr_1');
        set(obj.guiHandle.staticTextKorr2, 'String', 'AKorr_2');
        set(obj.guiHandle.staticTextKorr3, 'String', 'AKorr_3');
        set(obj.guiHandle.staticTextKorr4, 'String', 'AKorr_4');
        set(obj.guiHandle.staticTextKorr5, 'String', 'AKorr_5');
        set(obj.guiHandle.staticTextKorr6, 'String', 'AKorr_6');
      else
        set(obj.guiHandle.staticTextKorr1, 'String', 'RKorr_X');
        set(obj.guiHandle.staticTextKorr2, 'String', 'RKorr_Y');
        set(obj.guiHandle.staticTextKorr3, 'String', 'RKorr_Z');
        set(obj.guiHandle.staticTextKorr4, 'String', 'RKorr_A');
        set(obj.guiHandle.staticTextKorr5, 'String', 'RKorr_B');
        set(obj.guiHandle.staticTextKorr6, 'String', 'RKorr_C');  
      end      
      
    end
    
    function obj = buttonUpOnFigure(obj,~,~)

      localHandle = obj.getButtonEventHandle();

      switch localHandle
  
        case obj.guiHandle.buttonKorr1Minus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr1', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrX', '0,0' );
          end
        case obj.guiHandle.buttonKorr2Minus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr2', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrY', '0,0' );
          end
        case obj.guiHandle.buttonKorr3Minus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr3', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrZ', '0,0' );
          end
        case obj.guiHandle.buttonKorr4Minus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr4', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrA', '0,0' );
          end
        case obj.guiHandle.buttonKorr5Minus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr5', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrB', '0,0' );
          end
        case obj.guiHandle.buttonKorr6Minus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr6', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrC', '0,0' );
          end   
        case obj.guiHandle.buttonKorr1Plus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr1', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrX', '0,0' );
          end              
        case obj.guiHandle.buttonKorr2Plus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr2', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrY', '0,0' );
          end                
        case obj.guiHandle.buttonKorr3Plus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr3', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrZ', '0,0' );
          end                 
        case obj.guiHandle.buttonKorr4Plus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr4', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrA', '0,0' );
          end                    
        case obj.guiHandle.buttonKorr5Plus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr5', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrB', '0,0' );
          end                     
        case obj.guiHandle.buttonKorr6Plus
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr6', '0,0' );
          else
            obj.modifyRKorrVariable( 'RKorrC', '0,0' );
          end    
        otherwise
      end
    end
    
    function obj = buttonDownOnFigure(obj,~,~)

      localHandle = obj.getButtonEventHandle();

      switch localHandle
  
        case obj.guiHandle.buttonKorr1Minus
          value = get(obj.guiHandle.editTextKorr1,'String');
          value = strcat('-',value);
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr1', value );
          else
            obj.modifyRKorrVariable( 'RKorrX', value );
          end
        case obj.guiHandle.buttonKorr2Minus
          value = get(obj.guiHandle.editTextKorr2,'String');
          value = strcat('-',value);
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr2', value );
          else
            obj.modifyRKorrVariable( 'RKorrY', value );
          end
        case obj.guiHandle.buttonKorr3Minus
          value = get(obj.guiHandle.editTextKorr3,'String');
          value = strcat('-',value);    
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr3', value );
          else
            obj.modifyRKorrVariable( 'RKorrZ', value );
          end
        case obj.guiHandle.buttonKorr4Minus
          value = get(obj.guiHandle.editTextKorr4,'String');
          value = strcat('-',value);    
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr4', value );
          else
            obj.modifyRKorrVariable( 'RKorrA', value );
          end
        case obj.guiHandle.buttonKorr5Minus
          value = get(obj.guiHandle.editTextKorr5,'String');
          value = strcat('-',value);    
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr5', value );
          else
            obj.modifyRKorrVariable( 'RKorrB', value );
          end
        case obj.guiHandle.buttonKorr6Minus
          value = get(obj.guiHandle.editTextKorr6,'String');
          value = strcat('-',value);    
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr6', value );
          else
            obj.modifyRKorrVariable( 'RKorrC', value );
          end           
        case obj.guiHandle.buttonKorr1Plus
          value = get(obj.guiHandle.editTextKorr1,'String');
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr1', value );
          else
            obj.modifyRKorrVariable( 'RKorrX', value );
          end                
        case obj.guiHandle.buttonKorr2Plus
          value = get(obj.guiHandle.editTextKorr2,'String');
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr2', value );
          else
            obj.modifyRKorrVariable( 'RKorrY', value );
          end                  
        case obj.guiHandle.buttonKorr3Plus
          value = get(obj.guiHandle.editTextKorr3,'String');
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr3', value );
          else
            obj.modifyRKorrVariable( 'RKorrZ', value );
          end                   
        case obj.guiHandle.buttonKorr4Plus
          value = get(obj.guiHandle.editTextKorr4,'String');
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr4', value );
          else
            obj.modifyRKorrVariable( 'RKorrA', value );
          end                       
        case obj.guiHandle.buttonKorr5Plus
          value = get(obj.guiHandle.editTextKorr5,'String');
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr5', value );
          else
            obj.modifyRKorrVariable( 'RKorrB', value );
          end                       
        case obj.guiHandle.buttonKorr6Plus
          value = get(obj.guiHandle.editTextKorr6,'String');
          corrType = get(obj.guiHandle.radioButtonAKorrCorrection,'Value');
          if( corrType == 1 )
            obj.modifyAKorrVariable( 'AKorr6', value );
          else
            obj.modifyRKorrVariable( 'RKorrC', value );
          end      
        otherwise
      end      
    end
    
    function buttonHandle = getButtonEventHandle( obj )

      mousePos=get(obj.guiHandle.figure,'CurrentPoint');

      if( (mousePos(1) > obj.guiHandle.posKorr1Minus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr1Minus(1,1)+obj.guiHandle.posKorr1Minus(1,3))) && ...
          (mousePos(2) > obj.guiHandle.posKorr1Minus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr1Minus(1,2)+obj.guiHandle.posKorr1Minus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr1Minus;
      elseif( (mousePos(1) > obj.guiHandle.posKorr2Minus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr2Minus(1,1)+obj.guiHandle.posKorr2Minus(1,3))) && ...
              (mousePos(2) > obj.guiHandle.posKorr2Minus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr2Minus(1,2)+obj.guiHandle.posKorr2Minus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr2Minus;
      elseif( (mousePos(1) > obj.guiHandle.posKorr3Minus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr3Minus(1,1)+obj.guiHandle.posKorr3Minus(1,3))) && ...
              (mousePos(2) > obj.guiHandle.posKorr3Minus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr3Minus(1,2)+obj.guiHandle.posKorr3Minus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr3Minus;  
      elseif( (mousePos(1) > obj.guiHandle.posKorr4Minus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr4Minus(1,1)+obj.guiHandle.posKorr4Minus(1,3))) && ...
              (mousePos(2) > obj.guiHandle.posKorr4Minus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr4Minus(1,2)+obj.guiHandle.posKorr4Minus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr4Minus;    
      elseif( (mousePos(1) > obj.guiHandle.posKorr5Minus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr5Minus(1,1)+obj.guiHandle.posKorr5Minus(1,3))) && ...
              (mousePos(2) > obj.guiHandle.posKorr5Minus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr5Minus(1,2)+obj.guiHandle.posKorr5Minus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr5Minus;  
      elseif( (mousePos(1) > obj.guiHandle.posKorr6Minus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr6Minus(1,1)+obj.guiHandle.posKorr6Minus(1,3))) && ...
              (mousePos(2) > obj.guiHandle.posKorr6Minus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr6Minus(1,2)+obj.guiHandle.posKorr6Minus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr6Minus;    
      elseif( (mousePos(1) > obj.guiHandle.posKorr1Plus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr1Plus(1,1)+obj.guiHandle.posKorr1Plus(1,3))) && ...
              (mousePos(2) > obj.guiHandle.posKorr1Plus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr1Plus(1,2)+obj.guiHandle.posKorr1Plus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr1Plus;      
      elseif( (mousePos(1) > obj.guiHandle.posKorr2Plus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr2Plus(1,1)+obj.guiHandle.posKorr2Plus(1,3))) && ...
              (mousePos(2) > obj.guiHandle.posKorr2Plus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr2Plus(1,2)+obj.guiHandle.posKorr2Plus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr2Plus;        
      elseif( (mousePos(1) > obj.guiHandle.posKorr3Plus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr3Plus(1,1)+obj.guiHandle.posKorr3Plus(1,3))) && ...
              (mousePos(2) > obj.guiHandle.posKorr3Plus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr3Plus(1,2)+obj.guiHandle.posKorr3Plus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr3Plus;          
      elseif( (mousePos(1) > obj.guiHandle.posKorr4Plus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr4Plus(1,1)+obj.guiHandle.posKorr4Plus(1,3))) && ...
              (mousePos(2) > obj.guiHandle.posKorr4Plus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr4Plus(1,2)+obj.guiHandle.posKorr4Plus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr4Plus;          
      elseif( (mousePos(1) > obj.guiHandle.posKorr5Plus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr5Plus(1,1)+obj.guiHandle.posKorr5Plus(1,3))) && ...
              (mousePos(2) > obj.guiHandle.posKorr5Plus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr5Plus(1,2)+obj.guiHandle.posKorr5Plus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr5Plus;          
      elseif( (mousePos(1) > obj.guiHandle.posKorr6Plus(1,1)) && (mousePos(1) < (obj.guiHandle.posKorr6Plus(1,1)+obj.guiHandle.posKorr6Plus(1,3))) && ...
              (mousePos(2) > obj.guiHandle.posKorr6Plus(1,2)) && (mousePos(2) < (obj.guiHandle.posKorr6Plus(1,2)+obj.guiHandle.posKorr6Plus(1,4))) )
        buttonHandle = obj.guiHandle.buttonKorr6Plus;          
      else
        buttonHandle = 0;
      end    
    end
    
    function obj = btnCloseConnection(obj,~,~)
      
      obj.closeConnection();
      
    end
    
    function obj = btnOpenConnection(obj,~,~)
      
      obj.connect();
      
    end    
    
    function btnClose(obj,~,~)
      
      stop(obj.guiTimer);

      obj.closeConnection();

      allObjectHandles = findall(0);
      % ignore matlab console(root)
      allObjectHandles = allObjectHandles(2:end);
      % now delete all handles
      delete(allObjectHandles);
  
      delete(gcbf);      
      
    end
    
    function obj = updateGUIDisplay(obj,~,~)

      % set string to textbox
      set(obj.guiHandle.staticTextRobotInfo,'String',obj.getAktRobotInfo());
      set(obj.guiHandle.staticTextCommandData,'String',obj.getAktCommandString());
      set(obj.guiHandle.staticTextConnectionState,'String',obj.getConnectionState());
      set(obj.guiHandle.staticTextLockingState,'String',obj.isCorrectionCommandAllowed());
      set(obj.guiHandle.staticTextSendPackages,'String',obj.getPackagesSentCounter());
      set(obj.guiHandle.staticTextReceivedPackages,'String',obj.getPackagesReceivedCounter());
      set(obj.guiHandle.staticTextCycleTime,'String',obj.getCommunicationTimeMicroSeconds());
      set(obj.guiHandle.staticTextDebugInfo,'String',obj.getWrapperDebugCommInfo());
 
    end
    
    function obj = btnResetStatistics(obj,~,~)
      
      obj.resetStatistics();      
      
    end
    
    function obj = btnResetCommandData(obj,~,~)
      
      obj.modifyRKorrVariable( 'RKorrX', '0,0' );
      obj.modifyRKorrVariable( 'RKorrY', '0,0' );
      obj.modifyRKorrVariable( 'RKorrZ', '0,0' );
      obj.modifyRKorrVariable( 'RKorrA', '0,0' );
      obj.modifyRKorrVariable( 'RKorrB', '0,0' );
      obj.modifyRKorrVariable( 'RKorrC', '0,0' );
      
      obj.modifyAKorrVariable( 'AKorr1', '0,0' );
      obj.modifyAKorrVariable( 'AKorr2', '0,0' );
      obj.modifyAKorrVariable( 'AKorr3', '0,0' );
      obj.modifyAKorrVariable( 'AKorr4', '0,0' );
      obj.modifyAKorrVariable( 'AKorr5', '0,0' );
      obj.modifyAKorrVariable( 'AKorr6', '0,0' );

      set(obj.guiHandle.editTextKorr1,'String', '0,1');
      set(obj.guiHandle.editTextKorr2,'String', '0,1');
      set(obj.guiHandle.editTextKorr3,'String', '0,1');
      set(obj.guiHandle.editTextKorr4,'String', '0,1');
      set(obj.guiHandle.editTextKorr5,'String', '0,1');
      set(obj.guiHandle.editTextKorr6,'String', '0,1');      
      
    end
    
    function obj = btnStopJogging(obj,~,~)
      
      obj.lockCorrectionCommands();
      
    end
    
    function obj = btnStartJogging(obj,~,~)
      
      obj.unlockCorrectionCommands();
      
    end
    
  end
end      