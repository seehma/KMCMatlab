%% --------------------------------------------------------------------------------
% initialize variables
% ---------------------------------------------------------------------------------
averageSize = 20;
searchSeconds = 5;
controlSeconds = 0.830;
kp = 1;
ki = 1;
dt = 0.1;
kd = 0.0;
smallestControlValue = 0.001;
t_ipo = 0.012;
ipolCyclesPerSecond = floor(1/0.012);

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
forceSearch = forceAveraged(1) + 0.1*forceAveraged(1);
forceToHave = forceSearch + 0.2*forceAveraged(1);

%% --------------------------------------------------------------------------------
% start movement in X axis and wait till average force +10% is reached
% ---------------------------------------------------------------------------------
maxSearchTime = floor((t_ipo * ipolCyclesPerSecond * searchSeconds)/t_ipo); 
conHandle.modifyRKorrVariable('RKorrX','0,05');
for i=1:1:maxSearchTime
  innerLoop=tic();
  
  [~,~,~,~,~,forceAct] = conHandle.decodeRobotInfoString( conHandle.getAktRobotInfo() );
  
  % stop when force is 10% bigger than averaged force
  if( forceAct(1) > forceSearch )
    conHandle.modifyRKorrVariable('RKorrX','0,0');
    break;
  end
  
  while( toc(innerLoop) < 0.011 )
  end
end

% stop movement for sure after looping
conHandle.modifyRKorrVariable('RKorrX','0,0');

%% --------------------------------------------------------------------------------
% now start movement (Y-direction) in other direction and try to control the force
% ---------------------------------------------------------------------------------
conHandle.modifyRKorrVariable('RKorrY','0,05');
maxControlTime = floor((t_ipo * ipolCyclesPerSecond * controlSeconds)/t_ipo);
systemDeviation = 0;

integral = 0;
derivative = 0;
prevSystemDeviation = 0;

for i=1:1:maxControlTime
  innerLoop=tic();
  
  [~,~,~,~,~,forceAct] = conHandle.decodeRobotInfoString( conHandle.getAktRobotInfo() );
  
  % calculate power part of PID
  systemDeviation = forceToHave - forceAct(1);
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
  
  % convert to string
  controlValueAsString = num2str(controlValue,'%5.6f');
  controlValueAsString = strrep(controlValueAsString, '.', ',')
  
  %conHandle.modifyRKorrVariable('RKorrX',controlValueAsString);
  
  prevSystemDeviation = systemDeviation;
  
  saveCV(i) = controlValue;
  
  while( toc(innerLoop) < 3*t_ipo )
  end  
end

% stop movement in all directions
conHandle.modifyRKorrVariable('RKorrX','0,0');
conHandle.modifyRKorrVariable('RKorrY','0,0');