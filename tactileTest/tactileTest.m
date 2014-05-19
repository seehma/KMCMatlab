
pause(5);

% maximum loopcount to observe the force

loopCount = 1300;
% initialize variables
RIst = zeros(loopCount,6);
RSol = zeros(loopCount,6);
AIst = zeros(loopCount,6);
ASol = zeros(loopCount,6);
MACur = zeros(loopCount,6);
FT = zeros(loopCount,6);

zKorr = '-0,2';

FT = zeros(loopCount,7);
% drive with 0.1mm per 12ms in negative z-direction
zKorr = '-0,1';
% send command to robot
conHandle.modifyRKorrVariable('RKorrZ',zKorr);
% start loop
for i=1:1:loopCount
  % start time measuring
  innerLoop=tic();
  % get actual values from robot
  [RIst(i,:),RSol(i,:),AIst(i,:),ASol(i,:), MACur(i,:), FT(i,:)] = conHandle.decodeRobotInfoString( conHandle.getAktRobotInfo() );
  % observe force value in z-direction
  if( FT(i,1) < 0.0150)
    % if bigger than limit, stop movement
   conHandle.modifyRKorrVariable('RKorrZ','0,0');
  end
  % one cycle duration is 12 ms
  while( toc(innerLoop) < 0.011 )
  end
end
% securely stop movement
conHandle.modifyRKorrVariable('RKorrZ','0,0');