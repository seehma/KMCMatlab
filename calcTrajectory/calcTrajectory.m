% calculation of a symmetric sinoidprofile
% author: Matthias Seehauser
% date: 05.05.2014

a_m = 128; % acceleration 0.200 m/s^2
v_m = 512; % speed 0.25m/s
s_start = 0; % start position
s_end = 40; % end position
s_diff = s_end - s_start; % distance to drive
t_ipo = 0.012; % ipo cycletime

% calculate driven distance after acceleration phase
t_a_check = v_m/a_m;
s_a_check = a_m*t_a_check^2/2;

% check if it is greater than the half of the full distance
if( s_a_check > s_diff/2)
  % calculate new ramptime and new max speed
  t_a=sqrt(4*(s_diff/2)/a_m);
  t_a=floor(t_a/t_ipo)*t_ipo;
  v_m=a_m*t_a/2;
  t_const_v = 0;
else
  % calculate normalized ramptime and speed for constant phase
  t_a=floor(v_m/(a_m*t_ipo))*t_ipo;
  s_a=a_m*t_a^2/2;
  s_const_v = s_diff - 2*s_a;
  t_const_v = s_const_v / v_m;
  t_const_v=floor(t_const_v/t_ipo)*t_ipo;
  v_m=s_const_v/t_const_v;
end

% calculate whole ramptimes
t_d = t_a+t_const_v;
t_e = t_d + t_a;

% recalculate new acceleration with normed speed
a_m=2*v_m/t_a;

% acceleration phase
t=0:t_ipo:(t_a-t_ipo);
spp_a_t = a_m*sin(pi/t_a*t).^2; 
sp_a_t = a_m*(1/2*t-t_a/(4*pi)*sin(2*pi/t_a*t));
s_a_t = a_m*(1/4*t.^2+t_a.^2/(8*pi.^2)*(cos(2*pi/t_a*t)-1));

% constant speed phase
t=t_a:t_ipo:(t_d-t_ipo);
size_t = size(t);
spp_c_t = zeros(size_t(2),1)';
sp_c_t = zeros(size_t(2),1)';
sp_c_t(:) = v_m;
s_c_t = v_m*(t-1/2*t_a);

% deceleration phase
t=t_d:t_ipo:t_e;
spp_d_t = -a_m*sin(pi/t_a*(t-t_d)).^2;
sp_d_t = v_m-a_m*(1/2*(t-t_d)-t_a/(4*pi)*sin(2*pi/t_a*(t-t_d)));
s_d_t = a_m/2*(t_e*(t+t_a)-(t.^2+t_e.^2+2*t_a.^2)/2+t_a.^2/(4*pi.^2)*(1-cos(2*pi/t_a*(t-t_d))));

% concat all single phases to one
s_ges_t = [s_a_t s_c_t s_d_t];
sp_ges_t = [sp_a_t sp_c_t sp_d_t];
spp_ges_t = [spp_a_t spp_c_t spp_d_t];

% generate a timeline
t_ges = 0:0.012:t_e;

figure
plot(s_ges_t)


% -------------------------------------------------------------------------------------------------
% trajectory generated! now do the cool robot stuff
% -------------------------------------------------------------------------------------------------

% check if it is connected
if( conHandle.isConnected() ~= 1 )
  error('KMC is not connected');
end

% create the differences of the position
length = size(s_ges_t);
s_differences = zeros(length);
for i=1:1:(length(2)-1)
  s_differences(i) = s_ges_t(i+1) - s_ges_t(i);
end
s_differences(length(2)) = 0;

for i=1:1:length(2)
  tic();
  numberAsString = num2str(s_differences(i),'%5.6f');
  numberAsString = strrep(numberAsString, '.', ',');
  conHandle.modifyAKorrVariable('AKorr1',numberAsString); 
  
  while( ~conHandle.isNextCycleStarted() )
  end
  
  toc()
end


