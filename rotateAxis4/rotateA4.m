
loopCount = 4400;
%loopCount=100;
aktRobotData = cell(loopCount,1);

tic();
for i=1:1:loopCount
  a4Str = '0,0833';
 
  conHandle.modifyAKorrVariable('AKorr4',a4Str);
  aktRobotData(i) = {conHandle.getAktRobotInfo()};

  % set string to textbox
  set(handles.text_RobotInfo,'String',aktRobotData(i));
  
  java.lang.Thread.sleep(cycleTime);
  %pause(0.012);
end
toc();

conHandle.modifyAKorrVariable('AKorr4','0,0');

RIst = zeros(loopCount,6);
RSol = zeros(loopCount,6);
AIst = zeros(loopCount,6);
ASol = zeros(loopCount,6);
MACur = zeros(loopCount,6);
FT = zeros(loopCount,7);

for i=1:1:loopCount

  [RIst(i,:),RSol(i,:),AIst(i,:),ASol(i,:), MACur(i,:), FT(i,:)] = conHandle.decodeRobotInfoString( aktRobotData{i} );
  
end