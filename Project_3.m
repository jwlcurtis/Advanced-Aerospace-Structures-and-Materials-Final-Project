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
    0,0,Q66]
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