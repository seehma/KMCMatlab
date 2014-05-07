
loopCount = 2000;

RIst = zeros(loopCount,6);
RSol = zeros(loopCount,6);
AIst = zeros(loopCount,6);
ASol = zeros(loopCount,6);
MACur = zeros(loopCount,6);
FT = zeros(loopCount,7);

wholeLoop=tic();
for i=1:1:loopCount
  innerLoop=tic();
  
  [RIst(i,:),RSol(i,:),AIst(i,:),ASol(i,:), MACur(i,:), FT(i,:)] = conHandle.decodeRobotInfoString( t.getAktRobotInfo() );

  while( toc(innerLoop) < 0.011 )
  end
end
toc(wholeLoop)