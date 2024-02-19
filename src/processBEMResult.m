%{
Script for processing output of BEM function.

Copyright 2023 Jatinder Goyal

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
%}
%%
bem.dTNdr =  bem.dT./(prop.B.*prop.dr);
bem.dQNdr = bem.dQ./(prop.B.*prop.dr);
bem.n = op.points(:,3); bem.J = op.points(:,2);
bem.Ct = bem.dTNdr./(air.rho.*bem.n.^2.*prop.Dia^3);
bem.Cp = (bem.dQNdr.*bem.n*2*pi)./(air.rho.*bem.n.^3.*prop.Dia^4);
bem.dPc = (bem.dQNdr.*bem.n*2*pi)./(air.rho.*bem.Uinf.^3.*prop.Dia);
bem.dTc = bem.dTNdr./(air.rho.*bem.Uinf.^2.*prop.Dia);

nanIdxT = isnan(bem.dTNdr) + isinf(bem.dTNdr); nanIdxQ = isnan(bem.dQNdr)+ isinf(bem.dTNdr);
for i = 1:op.sz(1)
    bem.T(i,1) = prop.B*trapz([prop.r(~nanIdxT(i,:)),prop.R],[bem.dTNdr(i,~nanIdxT(i,:)),0]);
    bem.Q(i,1) = prop.B*trapz([prop.r(~nanIdxQ(i,:)),prop.R],[bem.dQNdr(i,~nanIdxQ(i,:)),0]);
end
clear nanIdxQ nanIdxT nanIdxCl nanIdxCd

bem.CT = bem.T./(air.rho.*bem.n.^2.*prop.Dia.^4);
bem.CQ = bem.Q./(air.rho.*bem.n.^2.*prop.Dia.^5);
bem.P = bem.Q.*(bem.n*2*pi);
bem.CP = bem.P./(air.rho.*bem.n.^3.*prop.Dia.^5);
bem.eff = bem.J.*bem.CT./bem.CP;
bem.TC = bem.T./(air.rho.*bem.Uinf.^2.*prop.Dia.^2);
bem.PC = bem.P./(air.rho.*bem.Uinf.^3.*prop.Dia.^2);
bem.eff_regen = -8/pi*bem.PC;
