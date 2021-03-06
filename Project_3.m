clc
clear
%% Material Properties
% properties=[Volume Fraction Modulus Denisty Poisson Rato]
% units=[NA GPa g/cm^3 NA]
F=[0.7 250 1.8 0.2]; % Fiber properties
M=[0.3 3.5 1.2 0.35]; % Matrix properties
Al=[1 72 2.78 0.33]; % Aluminum properties

%% Composite Q matrix
% Convert GPa to Pa
F(2)=F(2)*10^9;
M(2)=M(2)*10^9;
Al(2)=Al(2)*10^9;

% Calculates 4+1 5 guys!
Gf=F(2)/(2*(1+F(4)));
Gm=M(2)/(2*(1+M(4)));

EL=F(1)*F(2)+M(1)*M(2);

ET=F(2)*M(2)/(M(1)*F(2)+M(2)*F(1));

GLT=Gf*Gm/(M(1)*Gf+Gm*F(1));

muLT=F(1)*F(4)+M(1)*M(4);

muTL=muLT/EL*ET;
% Creates the Q (theta=0) matrix of the composite
Q11=EL/(1-muLT*muTL);
Q22=ET/(1-muLT*muTL);
Q12=muTL*EL/(1-muLT*muTL);
Q66=GLT;

Q_C=[Q11,Q12,0;
    Q12,Q22,0;
    0,0,Q66];
%% Aluminum Q matrix

Gf=Al(2)/(2*(1+Al(4)));
Gm=Al(2)/(2*(1+Al(4)));

GLT=Al(2)/(2*(1+Al(4)));

Q11=Al(2)/(1-Al(4)*Al(4));
Q22=Al(2)/(1-Al(4)*Al(4));
Q12=Al(4)*Al(2)/(1-Al(4)*Al(4));
Q66=GLT;

Q_Al=[Q11,Q12,0;
    Q12,Q22,0;
    0,0,Q66];

%% Design Problem 1a
h_1a=[-2.5 -1.5 -0.5 0.5 1.5 2.5];
%h_1a=h_1a*10^-3
% baseline Al
Q_baseline={Q_Al Q_Al Q_Al Q_Al Q_Al};
[A_Al,B_Al,D_Al]=ABD_Q1(Q_baseline,h_1a);

% theta=0
Q_theta_0={Q_Al Q_C Q_Al Q_C Q_Al};
[A_theta_0,B_theta_0,D_theta_0]=ABD_Q1(Q_theta_0,h_1a);

% theta=30
Q_theta_30={Q_Al transform(30,Q_C) Q_Al transform(30,Q_C) Q_Al};
[A_theta_30,B_theta_30,D_theta_30]=ABD_Q1(Q_theta_30,h_1a);

% theta=45
Q_theta_45={Q_Al transform(45,Q_C) Q_Al transform(45,Q_C) Q_Al};
[A_theta_45,B_theta_45,D_theta_45]=ABD_Q1(Q_theta_45,h_1a);

% theta=60
Q_theta_60={Q_Al transform(60,Q_C) Q_Al transform(60,Q_C) Q_Al};
[A_theta_60,B_theta_60,D_theta_60]=ABD_Q1(Q_theta_60,h_1a);

% theta=90
Q_theta_90={Q_Al transform(90,Q_C) Q_Al transform(90,Q_C) Q_Al};
[A_theta_90,B_theta_90,D_theta_90]=ABD_Q1(Q_theta_90,h_1a);

%% Design Problem 1b
N_1b=[1;1;1]; %[N/mm]
M_1b=[1;1;1];%[N-mm/mm]

NM_1b=[N_1b;M_1b];

% baseline Al
res_Al=midplate(A_Al,B_Al,D_Al,NM_1b);

% theta=0
res_theta_0=midplate(A_theta_0,B_theta_0,D_theta_0,NM_1b);

% theta=30
res_theta_30=midplate(A_theta_30,B_theta_30,D_theta_30,NM_1b);

% theta=45
res_theta_45=midplate(A_theta_45,B_theta_45,D_theta_45,NM_1b);

% theta=60
res_theta_60=midplate(A_theta_60,B_theta_60,D_theta_60,NM_1b);

% theta=90
res_theta_90=midplate(A_theta_90,B_theta_90,D_theta_90,NM_1b);

%% Design Problem 1c
rho_C=F(1)*F(3)+M(1)*M(3);
rho_Al=Al(3);

h_theta0=matching(0,Q_C,Q_Al,NM_1b,h_1a,0.01,100);

h_theta30=matching(30,Q_C,Q_Al,NM_1b,h_1a,0.01,100);

h_theta45=matching(45,Q_C,Q_Al,NM_1b,h_1a,0.01,100);

h_theta60=matching(60,Q_C,Q_Al,NM_1b,h_1a,0.01,100);

h_theta90=matching(90,Q_C,Q_Al,NM_1b,h_1a,0.01,100);

rho_theta0=(rho_C*h_theta0*2)+(rho_Al*3);
rho_theta30=(rho_C*h_theta30*2)+(rho_Al*3);
rho_theta45=(rho_C*h_theta45*2)+(rho_Al*3);
rho_theta60=(rho_C*h_theta60*2)+(rho_Al*3);
rho_theta90=(rho_C*h_theta90*2)+(rho_Al*3);
rho_baseline=(rho_Al*5);

% calculate weight savings

WS_theta0=(rho_theta0-rho_baseline)/rho_baseline;
WS_theta30=(rho_theta30-rho_baseline)/rho_baseline;
WS_theta45=(rho_theta45-rho_baseline)/rho_baseline;
WS_theta60=(rho_theta60-rho_baseline)/rho_baseline;
WS_theta90=(rho_theta90-rho_baseline)/rho_baseline;

%% Failure Analysis Problem 2
% Use maximum stress theory to predict Nx values to cause failure in 90 and
% 0 deg. ply
% 1a
% imput parameters
sigma_LU=2000; %Pa
sigma_TU_Sigma_LU=0.025; 
tau_LTU_sigma_LU=0.05;

% calculate needed values
sigma_TU=sigma_TU_Sigma_LU*sigma_LU;
tau_LTU=tau_LTU_sigma_LU*sigma_LU;

% Calculate N_x for theta =90
Q_3={transform(0,Q_C) transform(90,Q_C) transform(90,Q_C) transform(90,Q_C) Q_C};
A_3=ABD_Q1(Q_3,h_1a);
Q_C_90=transform(90,Q_C);
e_y_coeff_90=(-A_3(2,2))/(A_3(2,1));
e_y_90=(sigma_TU*10^-3)/(Q_C_90(1,2)+((Q_C_90(1,1))*e_y_coeff_90));
e_x_90=e_y_coeff_90*e_y_90;
Nx_90=(A_3(1,1)*e_x_90)+(A_3(1,2)*e_y_90)

% Calculate N_x for theta =0
e_y_coeff_0=(-A_3(2,2))/(A_3(2,1));
e_y_0=(sigma_LU*10^-3)/(Q_C(1,2)+((Q_C(1,1))*e_y_coeff_0));
e_x_0=e_y_coeff_0*e_y_0;
Nx_0=(A_3(1,1)*e_x_0)+(A_3(1,2)*e_y_0)

%% Design Problem 3
Q_3={transform(45,Q_C) transform(-45,Q_C) transform(45,Q_C)}
h_3=[-(2)^(1/3), -1, 1, (2)^(1/3)];
[A_3,B_3,D_3]=ABD_Q1(Q_3,h_3)


%% Functions
%% Transform Function
function[Q_t]=transform(theta,Q)
% theta is in degrees
T1_inverse=[cosd(theta)^2 sind(theta)^2 -2*sind(theta)*cosd(theta)
    sind(theta)^2 cosd(theta)^2 2*sind(theta)*cosd(theta)
    sind(theta)*cosd(theta) -sind(theta)*cosd(theta) cosd(theta)^2-sind(theta)^2 ];

T2=[cosd(theta)^2 sind(theta)^2 sind(theta)*cosd(theta)
    sind(theta)^2 cosd(theta)^2 -sind(theta)*cosd(theta)
    -2*sind(theta)*cosd(theta) 2*sind(theta)*cosd(theta) cosd(theta)^2-sind(theta)^2 ];
Q_t=T1_inverse*Q*T2;
end
%% A, B and D matrix for Q 1a
function [A,B,D]=ABD_Q1(Q,h)
% Q=cell array of all the Q matricies
% h=vector of all the ply thichnesses from top to bottom

% creates inital A B D matricies
A=zeros(3);
B=zeros(3);
D=zeros(3);

% Calculates A B D matricies
for i=1:length(Q)
  A=A+(Q{i}.*(h(i+1)-h(i)));
  B=B+(Q{i}.*(h(i+1)^2-h(i)^2));
  D=D+(Q{i}.*(h(i+1)^3-h(i)^3));
end
B=(1/2).*B;
D=(1/3).*D;
end
%% Midplate response Q 1b
function [res]=midplate(A,B,D,NM)
EE=[A,B;B,D];
res=inv(EE)*NM;
res=res';
end
%% Performace Matching  Q 1c
function [h,res]=matching(theta,Q_C,Q_Al,NM,h_b,h_low,h_high)
% Create baseline response
Q_baseline={Q_Al Q_Al Q_Al Q_Al Q_Al};
[A_Al,B_Al,D_Al]=ABD_Q1(Q_baseline,h_b);
res_Al=midplate(A_Al,B_Al,D_Al,NM).';

t_range=h_low:0.001:h_high; % composite thickness

for i=1:length(t_range)
    h_vector=[-1.5-t_range(i) -0.5-t_range(i) -0.5 0.5 0.5+t_range(i) 1.5+t_range(i)] ; % creates the all the height to calculate then A B D matrix 
    Q_theta_test={Q_Al transform(theta,Q_C) Q_Al transform(theta,Q_C) Q_Al};
    [A_theta_test,B_theta_test,D_theta_test]=ABD_Q1(Q_theta_test,h_vector);
    res_theta_test=midplate(A_theta_test,B_theta_test,D_theta_test,NM).';
    
    if (res_theta_test(1)<res_Al(1)) && (res_theta_test(2)<res_Al(2)) && (res_theta_test(3)<res_Al(3)) && (res_theta_test(4)<res_Al(4)) && (res_theta_test(5)<res_Al(5)) && (res_theta_test(6)<res_Al(6))
        h=t_range(i);
        res=res_theta_test;
        break
    end


end
end
