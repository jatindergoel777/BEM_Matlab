bem.dTNdr =  bem.dT./(prop.B.*prop.dr);
bem.dQNdr = bem.dQ./(prop.B.*prop.dr);
nanIdxT = isnan(bem.dTNdr) + isinf(bem.dTNdr); nanIdxQ = isnan(bem.dQNdr)+ isinf(bem.dTNdr);
for i = 1:op.sz(1)
bem.T(i,1) = prop.B*trapz(prop.r(~nanIdxT(i,:)),bem.dTNdr(i,~nanIdxT(i,:)));
bem.Q(i,1) = prop.B*trapz(prop.r(~nanIdxT(i,:)),bem.dQNdr(i,~nanIdxQ(i,:)));
end
clear nanIdxQ nanIdxT
bem.n = op.points(:,3); bem.J = op.points(:,2);
bem.CT = bem.T./(air.rho.*bem.n.^2.*prop.Dia.^4);
bem.CQ = bem.Q./(air.rho.*bem.n.^2.*prop.Dia.^5);
bem.P = bem.Q.*(bem.n*2*pi);
bem.CP = bem.P./(air.rho.*bem.n.^3.*prop.Dia.^5);
bem.eff = bem.J.*bem.CT./bem.CP;
bem.Cs = (air.rho.*bem.Uinf.^5./(bem.P.*bem.n.^2)).^(1/5);
bem.TC = bem.T./(air.rho.*bem.Uinf.^2.*prop.Dia.^2);
bem.PC = bem.P./(air.rho.*bem.Uinf.^3.*prop.Dia.^2);
bem.eff_regen = -8/pi*bem.PC;
