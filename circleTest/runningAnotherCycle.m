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
  %pause(0.012);
  
  toc();
end

for i=1:1:endFor(2)

  % convert the bytes to string
  aktStr = convertByteToString( aktRobotData{i} );
    
  % get values out of string
  [RIst(i,:),RSol(i,:),AIst(i,:),ASol(i,:)] = decodeRobotInfoString(aktStr);  
  
end