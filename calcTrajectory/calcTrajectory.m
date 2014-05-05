a_m = 0.200; % acceleration 200mm/s^2
d_m = 0.200; % deceleration 200mm/s^2
v_m = 0.1;  % speed 10mm/s
s_start = 0.100; % start position 100mm
s_end = 0.600; % end position 200mm
s_diff = s_end - s_start; % distance to drive
t_ipo = 0.012;

%t_a=round(2*v_m/(a_m*t_ipo))*t_ipo;
%t_d=round(s_diff/(v_m*t_ipo))*t_ipo;
%t_e = t_d + t_a;
t_a=2*v_m/a_m;
t_e=s_diff/v_m+t_a;
t_d=t_e-t_a;

v_m=s_diff/t_d;
a_m=v_m/t_a;
d_m = a_m;

% acceleration phase
t=0:t_ipo:t_a;
spp_a_t = a_m*sin(pi/t_a*t).^2; % acceleration for every time t
sp_a_t = a_m*(1/2*t-t_a/(4*pi)*sin(2*pi/t_a*t)); % speed for every time t
s_a_t = a_m*(1/4*t.^2+t_a.^2/(8*pi.^2)*(cos(2*pi/t_a*t)-1)); % position for every time t

% constant speed phase
t=t_a:t_ipo:t_d;
%s_c_t = s_a_t(end)+v_m*(t-t_a);
s_c_t = v_m*(t-1/2*t_a);

% deceleration phase
t=t_d:t_ipo:t_e;
spp_d_t = -d_m*sin(pi/t_a*(t-t_d)).^2;
sp_d_t = v_m-d_m*(1/2*(t-t_d)-t_a/(4*pi)*sin(2*pi/t_a*(t-t_d)));
s_d_t = a_m/2*(t_e*(t+t_a)-(t.^2+t_e.^2+2*t_a.^2)/2+t_a.^2/(4*pi.^2)*(1-cos(2*pi/t_a*(t-t_d))));

s_ges_t = [s_a_t s_c_t s_d_t];
t_ges = 0:0.012:t_e;

