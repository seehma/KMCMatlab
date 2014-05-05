a_m = 0.200; % acceleration 0.200m/s^2
d_m = 0.200; % deceleration 0.200m/s^2
v_m = 0.2;  % speed 0.1m/s
s_start = 0.100; % start position 100mm
s_end = 0.600; % end position 200mm
s_diff = s_end - s_start; % distance to drive
t_ipo = 0.012;

t_a_check = v_m/a_m;
s_a_check = a_m*t_a_check^2/2;
if( s_a_check > s_diff/2)
  t_a=sqrt(4*(s_diff/2)/a_m);
  t_a=floor(t_a/t_ipo)*t_ipo;
  v_m=a_m*t_a/2;
  s_a=a_m*t_a^2/2;
  t_const_v = 0;
else
  t_a=floor(v_m/(a_m*t_ipo))*t_ipo;
  
  s_a=a_m*t_a^2/2;
  s_const_v = s_diff - 2*s_a;
  t_const_v = s_const_v / v_m;
  v_m=s_const_v/t_const_v;
end

t_d = t_a+t_const_v;
t_e = t_d + t_a;

a_m=2*v_m/t_a;
d_m = a_m;

% acceleration phase
t=0:t_ipo:(t_a-t_ipo);
spp_a_t = a_m*sin(pi/t_a*t).^2; % acceleration for every time t
sp_a_t = a_m*(1/2*t-t_a/(4*pi)*sin(2*pi/t_a*t)); % speed for every time t
s_a_t = a_m*(1/4*t.^2+t_a.^2/(8*pi.^2)*(cos(2*pi/t_a*t)-1)); % position for every time t

% constant speed phase
t=t_a:t_ipo:(t_d-t_ipo);
s_c_t = v_m*(t-1/2*t_a);

% deceleration phase
t=t_d:t_ipo:t_e;
spp_d_t = -d_m*sin(pi/t_a*(t-t_d)).^2;
sp_d_t = v_m-d_m*(1/2*(t-t_d)-t_a/(4*pi)*sin(2*pi/t_a*(t-t_d)));
s_d_t = a_m/2*(t_e*(t+t_a)-(t.^2+t_e.^2+2*t_a.^2)/2+t_a.^2/(4*pi.^2)*(1-cos(2*pi/t_a*(t-t_d))));

s_ges_t = [s_a_t s_c_t s_d_t];
t_ges = 0:0.012:t_e;

