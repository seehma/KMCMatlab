
loopCount = 1300;

RIst = zeros(loopCount,6);
RSol = zeros(loopCount,6);
AIst = zeros(loopCount,6);
ASol = zeros(loopCount,6);
MACur = zeros(loopCount,6);
FT = zeros(loopCount,7);

zKorr = '-0,1';
conHandle.modifyRKorrVariable('RKorrZ',zKorr);

wholeLoop=tic();
for i=1:1:loopCount
  innerLoop=tic();
  
  [RIst(i,:),RSol(i,:),AIst(i,:),ASol(i,:), MACur(i,:), FT(i,:)] = conHandle.decodeRobotInfoString( conHandle.getAktRobotInfo() );
  
  if( FT(i,1) < 0.0150)
    conHandle.modifyRKorrVariable('RKorrZ','0,0');
    %break;
  end

  while( toc(innerLoop) < 0.011 )
  end
end
toc(wholeLoop)
conHandle.modifyRKorrVariable('RKorrZ','0,0');