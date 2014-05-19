%% --------------------------------------------------------------------------------
% initialize variables
% ---------------------------------------------------------------------------------
averageSize = 20;
searchSeconds = 20;
controlSeconds = 18;
kp = 2;
ki = 12;
dt = 0.008;
kd = 0.0;
smallestControlValue = 0.001;
t_ipo = 0.012;
ipolCyclesPerSecond = floor(1/0.012);
pause(7);


%% --------------------------------------------------------------------------------
% first find the force without contact
% ---------------------------------------------------------------------------------
forceAveraged = zeros(averageSize,6);
for i=1:1:averageSize
  innerLoop=tic();
  
  [~,~,~,~,~,forceAveraged(i,:)] = conHandle.decodeRobotInfoString( conHandle.getAktRobotInfo() );
  
  while( toc(innerLoop) < 0.011 )
  end
end
% calculate average of every force
forceAveraged = mean(forceAveraged);

% for move in X-Direction
%forceSearch = forceAveraged(1) - 0.1*forceAveraged(1);
%forceToHave = forceSearch - 0.0*forceAveraged(1);
% for move in Z-Direction
forceSearch = forceAveraged(3) - 0.4*forceAveraged(3);
forceToHave = forceSearch - 0.0*forceAveraged(3);

%% --------------------------------------------------------------------------------
% start movement in X axis and wait till average force +10% is reached
% ---------------------------------------------------------------------------------
maxSearchTime = floor((t_ipo * ipolCyclesPerSecond * searchSeconds)/t_ipo); 
conHandle.modifyRKorrVariable('RKorrZ','-0,02');

RIstSearch = zeros(maxSearchTime,6);
RSolSearch = zeros(maxSearchTime,6);
AIstSearch = zeros(maxSearchTime,6);
ASolSearch = zeros(maxSearchTime,6);
MACurSearch = zeros(maxSearchTime,6);

objectFound = 0;

for i=1:1:maxSearchTime
  innerLoop=tic();
  
  [RIstSearch(i,:),RSolSearch(i,:),AIstSearch(i,:),ASolSearch(i,:),MACurSearch(i,:),forceAct] = conHandle.decodeRobotInfoString( conHandle.getAktRobotInfo() );
  
  % stop when force is 10% bigger than averaged force (X-Dir)
  %if( forceAct(1) < forceSearch )
  %  conHandle.modifyRKorrVariable('RKorrZ','0,0');
  %  objectFound = 1;
  %  break;
  %end
  
  % stop when force is 10% bigger than averaged force (Z-Dir)
  if( forceAct(3) > forceSearch )
    conHandle.modifyRKorrVariable('RKorrZ','0,0');
    objectFound = 1;
    %break;
  end
  
  while( toc(innerLoop) < 0.011 )
  end
end

% stop movement for sure after looping
conHandle.modifyRKorrVariable('RKorrZ','0,0');  

%% --------------------------------------------------------------------------------
% now start movement (Y-direction) in other direction and try to control the force
% ---------------------------------------------------------------------------------
conHandle.modifyRKorrVariable('RKorrX','0,05');
conHandle.modifyRKorrVariable('RKorrZ','0,0');

maxControlTime = floor((t_ipo * ipolCyclesPerSecond * controlSeconds)/t_ipo);
systemDeviation = 0;

RIstCtrl = zeros(maxControlTime,6);
RSolCtrl = zeros(maxControlTime,6);
AIstCtrl = zeros(maxControlTime,6);
ASolCtrl = zeros(maxControlTime,6);
MACurCtrl = zeros(maxControlTime,6);
forceAct = zeros(maxControlTime,6);

integral = 0;
derivative = 0;
prevSystemDeviation = 0;

for i=1:1:maxControlTime
  innerLoop=tic();
  
  [RIstCtrl(i,:),RSolCtrl(i,:),AIstCtrl(i,:),ASolCtrl(i,:),MACurCtrl(i,:),forceAct(i,:)] = conHandle.decodeRobotInfoString( conHandle.getAktRobotInfo() );
  
  % calculate power part of PID (X-Dir)
  %systemDeviation = forceToHave - forceAct(i,1);
  % calculate power part of PID (Z-Dir)
  systemDeviation = forceAct(i,3)-forceToHave;
  
  controlValueKP = kp*systemDeviation;
  % calculate integral part of PID
  integral = integral + systemDeviation*dt;
  controlValueKI = ki*integral;
  % calculate derivative part of PID
  derivative = (systemDeviation-prevSystemDeviation)/dt;
  controlValueKD = derivative*kd;
  
  % sum up all parts
  controlValue = controlValueKP + controlValueKI + controlValueKD;
  
  % realize an anti windup
  if( controlValue > 0.05 )
    controlValue = 0.05;
  end
  if( controlValue < -0.05)
    controlValue = -0.05;
  end
  
  % convert to string
  controlValueAsString = num2str(controlValue,'%5.6f');
  controlValueAsString = strrep(controlValueAsString, '.', ',')
  
  conHandle.modifyRKorrVariable('RKorrZ',controlValueAsString);
  
  prevSystemDeviation = systemDeviation;
  
  saveCV(i) = controlValue;
  
  while( toc(innerLoop) < 3*t_ipo )
  end  
end

% stop movement in all directions
conHandle.modifyRKorrVariable('RKorrX','0,0');
conHandle.modifyRKorrVariable('RKorrY','0,0');
conHandle.modifyRKorrVariable('RKorrZ','0,0');