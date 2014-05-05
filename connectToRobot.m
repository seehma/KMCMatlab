clear all;
close all;
clc;

addpath('circleTest');
addpath('rotateAxis4');
addpath('tactileTest');
addpath('calcTrajectory');

disp('doing init java sleep...');
java.lang.Thread.sleep(100);

% 12 milliseconds
cycleTime = 12;

disp('starting wrapper...');
<<<<<<< HEAD
t=robotConnector('192.168.1.11',cycleTime,'C:\Users\Matthias.SEESLENET\Documents\GitHub\KMC\bin\Release\KukaMatlabConnector.dll');

=======
t=robotConnector('192.168.1.11',6008,cycleTime,'C:\Users\Matthias.SEESLENET\Documents\GitHub\KMC\bin\Release\KukaMatlabConnector.dll');
>>>>>>> 597da25aebb27a399ff403fb1caae8482d5b6273
disp('starting connection to robot...');
t.connect();
disp('starting gui...');
t.initGUI();
disp('waiting for connection attempt from robot...');
while( (t.isConnected() ~= 1) )
  pause(0.01);
end

disp('Matlab is now connected to robot... have fun!');
