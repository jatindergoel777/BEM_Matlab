function [clExtrap, cdExtrap] = viternaExtrap(alpha_known,cl_known,cd_known,alpha_range)

AR = 10; %aspect ratio (doesn't have much impact) according to the reference
Cdmax = 1.11 + 0.018*AR; % from reference in the folder

A1 = Cdmax/2;
B1 = Cdmax;

[~,idxMax] = max(cl_known);
[~,idxMin] = min(cl_known);
% idxMax = length(cl_known);
% idxMin = 1;

alpha_PosStall = alpha_known(idxMax);
alpha_NegStall = alpha_known(idxMin);
Cl_PosStall = cl_known(idxMax);
Cl_NegStall = cl_known(idxMin);
Cd_PosStall = cd_known(idxMax);
Cd_NegStall = cd_known(idxMin);

A2_Pos = (Cl_PosStall - Cdmax*sind(alpha_PosStall)*cosd(alpha_PosStall))*sind(alpha_PosStall)/cosd(alpha_PosStall)^2;
A2_Neg = (Cl_NegStall - Cdmax*sind(alpha_NegStall)*cosd(alpha_NegStall))*sind(alpha_NegStall)/cosd(alpha_NegStall)^2;

B2_Pos = (Cd_PosStall - Cdmax*sind(alpha_PosStall)^2)/cosd(alpha_PosStall);
B2_Neg = (Cd_NegStall - Cdmax*sind(alpha_NegStall)^2)/cosd(alpha_NegStall);

idx0 = find(alpha_range>=0,1);

clExtrap(1:(idx0-1)) = A1*sind(2*alpha_range(1:(idx0-1))) + A2_Neg*(cosd(alpha_range(1:(idx0-1))).^2./sind(alpha_range(1:(idx0-1))));
clExtrap(idx0:length(alpha_range)) = A1*sind(2*alpha_range(idx0:end)) + A2_Pos*(cosd(alpha_range(idx0:end)).^2./sind(alpha_range(idx0:end)));

cdExtrap(1:(idx0-1)) = B1*sind(alpha_range(1:(idx0-1))).^2 + B2_Neg*cosd(alpha_range(1:(idx0-1)));
cdExtrap(idx0:length(alpha_range)) = B1*sind(alpha_range(idx0:end)).^2 + B2_Pos*cosd(alpha_range(idx0:end));