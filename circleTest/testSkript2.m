clear all;
close all;
clc;

disp('doing init java sleep');
java.lang.Thread.sleep(100);

% 12 milliseconds
cycleTime = 12;

disp('connecting to robot');
tic();
t=robotConnector('192.168.1.11',cycleTime);
t.connect();
t.getAktRobotInfo();
t.getAktCommandString();
toc();

setappdata(0,'robotConnection',t);

driveControlGui;
pause(2);

handles=getappdata(0,'handles');

disp('waiting for connection to robot...!');

while( t.getRobotConnectionState() ~= 1 )
  pause(0.01);
end

disp('matlabConnectorClass is up & connected... have fun!');

calcCircle;
endFor = size(counter);

RIst = zeros(endFor(2),6);
RSol = zeros(endFor(2),6);
AIst = zeros(endFor(2),6);
ASol = zeros(endFor(2),6);

aktRobotData = cell(endFor(2),1);

for i=1:1:endFor(2)
  tic();
  
  xStr = sprintf('%0.6f',xDiff(i));
  yStr = sprintf('%0.6f',yDiff(i));
  xStr = strrep( xStr, '.',',');
  yStr = strrep( yStr, '.',',');
 
  t.modifyRKorr('RKorrX',xStr);
  t.modifyRKorr('RKorrY',yStr);
  aktRobotData(i) = {t.getAktRobotInfo()};

  % set string to textbox
  set(handles.text_RobotInfo,'String',aktRobotData(i));
  
  java.lang.Thread.sleep(cycleTime);
  
  toc();
end

%t.closeConnection();

%while(1)
%  t.getAktCommandString();
%  
%  % set string to textbox
%  set(handles.text_RobotInfo,'String',t.getAktRobotInfo());
%  
%  pause(0.5);
%end

for i=1:1:endFor(2)

  % convert the bytes to string
  aktStr = convertByteToString( aktRobotData{i} );
    
  % get values out of string
  [RIst(i,:),RSol(i,:),AIst(i,:),ASol(i,:)] = decodeRobotInfoString(aktStr);  
  
end