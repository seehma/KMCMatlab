clear all;
close all;
clc;

addpath('circleTest');
addpath('rotateAxis4');
addpath('tactileTest');

disp('doing init java sleep...');
java.lang.Thread.sleep(100);

% 12 milliseconds
cycleTime = 12;

disp('starting wrapper...');
t=robotConnector('192.168.1.11',cycleTime,'C:\Users\Matthias.SEESLENET\Documents\GitHub\KMC\bin\Release\KukaMatlabConnector.dll');

disp('starting connection to robot...');
t.connect();

setappdata(0,'robotConnection',t);

disp('starting gui...');
driveControlGui;
pause(2);

handles=getappdata(0,'handles');

disp('waiting for connection to robot...!');
while( (t.isConnected() ~= 1) )
  pause(0.01);
end

disp('matlabConnectorClass is up & connected... have fun!');