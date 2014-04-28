classdef robotConnector < handle
  
  properties (GetAccess='private', SetAccess='private')
    
    ipAddress = '';
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
  end
  
  
  methods (Access = public)
    function obj = robotConnector( ipAddress, cycleTime, fullPathToWrapperDll )
      
      % save the given parameters in the local variables
      obj.cycleTime = cycleTime;
      obj.ipAddress = ipAddress;
      obj.fullPathToWrapperDll = fullPathToWrapperDll;
      
      % check if the right .NET version is installed
      %obj.kukaAssembly = NET.addAssembly('C:\Users\Matthias.SEESLENET\Dropbox\MCI\Master\thesis\myThesis\KMC\final\wrapper\KukaMatlabConnector\KukaMatlabConnector\bin\Release\KukaMatlabConnector.dll');
      obj.kukaAssembly = NET.addAssembly( obj.fullPathToWrapperDll );
      obj.connector = KukaMatlabConnector.ConnectorObject('commanddoc.xml',obj.ipAddress);
     
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
    function obj = connect(obj)
      
      obj.connector.initializeRobotListenThread();
      
    end
    
    function obj = closeConnection(obj)
      
      obj.connector.stopRobotConnChannel();
      
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
    
    function delayedInfo = getWrapperDelayInfo( obj )
     
      delayedInfo = char(obj.connector.getDelayedCommInfo());
      
    end
    
    function lockingState = isCorrectionCommandAllowed( obj )
      
      if( obj.connector.isCorrectionCommandAllowed() )
        lockingState = 'unlocked';
      else
        lockingState = 'locked';
      end
      
    end
    
    function sendPackages = getPackagesSendCounter( obj )
      
      sendPackages = obj.connector.getPackagesSendCounter();
      
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
    function startSynchronAKorr()
      
    end
    
    function endSynchronAKorr()
      
    end
    
    function modifyAKorrSynchron( command )
      
    end
    
    function startSynchronRKorr()
      
    end
    
    function endSynchronRKorr()
      
    end
    
    function modifyRKorrSynchron( command )
      
    end
    
    
  end
end      