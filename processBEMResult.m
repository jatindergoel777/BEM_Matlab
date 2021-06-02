bem.dTNdr =  bem.dT./(prop.B.*prop.dr);
bem.dQNdr = bem.dQ./(prop.B.*prop.dr);
bem.n = op.points(:,3); bem.J = op.points(:,2);
bem.Ct = bem.dTNdr./(air.rho.*bem.n.^2.*prop.Dia^3);
bem.Cp = (bem.dQNdr.*bem.n*2*pi)./(air.rho.*bem.n.^3.*prop.Dia^4);
bem.dPc = (bem.dQNdr.*bem.n*2*pi)./(air.rho.*bem.Uinf.^3.*prop.Dia);
bem.dTc = bem.dTNdr./(air.rho.*bem.Uinf.^2.*prop.Dia);
nanIdxT = isnan(bem.dTNdr) + isinf(bem.dTNdr); nanIdxQ = isnan(bem.dQNdr)+ isinf(bem.dTNdr);
%nanIdxCl = isnan(bem.Cl) + isinf(bem.Cl); nanIdxCd = isnan(bem.Cd) + isinf(bem.Cd);
for i = 1:op.sz(1)
bem.T(i,1) = prop.B*trapz([prop.r(~nanIdxT(i,:)),prop.R],[bem.dTNdr(i,~nanIdxT(i,:)),0]);
bem.Q(i,1) = prop.B*trapz([prop.r(~nanIdxQ(i,:)),prop.R],[bem.dQNdr(i,~nanIdxQ(i,:)),0]);
%bem.L(i,1) = prop.B*trapz([prop.hub_R*prop.R,prop.r(~nanIdxCl(i,:)),prop.R],[0,bem.Cl(i,~nanIdxCl(i,:)),0]);
%bem.D(i,1) = prop.B*trapz([prop.hub_R*prop.R,prop.r(~nanIdxCd(i,:)),prop.R],[0,bem.Cd(i,~nanIdxCd(i,:)),0]);
end
clear nanIdxQ nanIdxT nanIdxCl nanIdxCd
bem.CT = bem.T./(air.rho.*bem.n.^2.*prop.Dia.^4);
bem.CQ = bem.Q./(air.rho.*bem.n.^2.*prop.Dia.^5);
bem.P = bem.Q.*(bem.n*2*pi);
bem.CP = bem.P./(air.rho.*bem.n.^3.*prop.Dia.^5);
bem.eff = bem.J.*bem.CT./bem.CP;
bem.Cs = (air.rho.*bem.Uinf.^5./(bem.P.*bem.n.^2)).^(1/5);
bem.TC = bem.T./(air.rho.*bem.Uinf.^2.*prop.Dia.^2);
bem.PC = bem.P./(air.rho.*bem.Uinf.^3.*prop.Dia.^2);
bem.eff_regen = -8/pi*bem.PC;
