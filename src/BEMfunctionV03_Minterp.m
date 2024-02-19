%{
Script for solving BEMT.

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
function bem = BEMfunctionV03_Minterp(air,prop,op,cnvg,D4,PG,RT,GC)

fprintf('Starting BEM Calculations \n')
GC.Ct2 = 2*sqrt(GC.Ct1) - GC.Ct1;
% prop.r = prop.rR.*prop.R;
% prop.dr = prop.drR.*prop.R;
for ii = 1:length(op.points(:,1))
    it.Uinf = op.points(ii,1);
    it.omega = op.points(ii,3)*2*pi;
    it.a = 0.1*ones(1,length(prop.rR));
    it.a1 = 0.01*ones(1,length(prop.rR));
    it.iter = 0;
    it.diff = ones(1,length(prop.rR)); it.diff1 = ones(1,length(prop.rR));
    a_calc = it.a;
    a1_calc = it.a1;
    f = cnvg.f;
%%
    while max(it.diff) >cnvg.Hardtol || max(it.diff1) >cnvg.Hardtol
        it.a = f.*a_calc + (1-f).*it.a;
        it.a1 = f.*a1_calc + (1-f).*it.a1;
        it.V_a= it.Uinf.*(1 + it.a);
        it.V_t = it.omega*prop.r.*(1 - it.a1);
        it.V_p = sqrt(it.V_a.^2 + it.V_t.^2);
        it.phi = atan2d(it.V_a,it.V_t);
        it.alpha = -it.phi + op.pointsTheta(ii,:);

        it.Re = it.V_p.*prop.b./air.nu(ii);
        it.M = it.V_p./PG.c(ii);
        for m = 1:length(D4.M)
            it.Re(it.Re>max(D4.data{m}.Re(:))) = max(D4.data{m}.Re(:));
            it.Re(it.Re<min(D4.data{m}.Re(:))) = min(D4.data{m}.Re(:));

            Cl_m(m,:) = interp3(D4.data{m}.rR,D4.data{m}.Re,D4.data{m}.alpha,D4.data{m}.Cl,prop.rR,it.Re,it.alpha,'linear');
            Cd_m(m,:) = interp3(D4.data{m}.rR,D4.data{m}.Re,D4.data{m}.alpha,D4.data{m}.Cd,prop.rR,it.Re,it.alpha,'linear');
        end
        
%         for rRidx = 1:length(prop.rR)
%         it.Cl(rRidx) = interp1(D4.M,Cl_m(:,rRidx),it.M(rRidx),'spline',);
%         it.Cd(rRidx) = interp1(D4.M,Cd_m(:,rRidx),it.M(rRidx));
%         end
        it.M(it.M>max(D4.M)) = max(D4.M);
        it.M(it.M<min(D4.M)) = min(D4.M);
        it.Cl = diag(interp1(D4.M',Cl_m,it.M))';
        it.Cd = diag(interp1(D4.M',Cd_m,it.M))';
        clear m Cl_m Cd_m
         %% Prandtl-Glauert Correction
%         if PG.flag
%             it.M = it.V_p./PG.c(ii);
%             idm = it.M>PG.Mcrit;
%             it.M(idm) = PG.Mcrit;
%             beta = sqrt(1-it.M.^2);
%             if strcmp(PG.method, 'KT')
%                 it.Cl = it.Cl./(beta - (it.M.^2./(1+beta).*abs(it.Cl)/2)); %Karman-Tsien Correction
%             elseif strcmp(PG.method, 'PG')
%                 it.Cl = it.Cl./beta; %Prandtl-Glauert Correction
%             else
%                 error('Please select correct correction method for compresibility in variable PG.method: KT or PG \n')
%             end
%         end

        %%
        it.dT = 0.5*prop.B*air.rho(ii)*it.V_p.^2.*(it.Cl.*cosd(it.phi) - it.Cd.*sind(it.phi)).*prop.b.*prop.dr;
        it.dQ = 0.5*prop.B*air.rho(ii)*it.V_p.^2.*(it.Cl.*sind(it.phi) + it.Cd.*cosd(it.phi)).*prop.b.*prop.r.*prop.dr;

        it.Ct = it.dT./(0.5*air.rho(ii)*it.Uinf^2*(2*pi*prop.r.*prop.dr));
    %% Glauert Correction  
        if GC.flag
            idx = (it.Ct >= -GC.Ct2);
            a_calc(idx) = it.dT(idx)./(4*pi*prop.r(idx)*air.rho(ii)*it.Uinf^2.*(1+it.a(idx)).*prop.dr(idx));
            idx2 = (it.Ct < -GC.Ct2);
            a_calc(idx2) = (((it.Ct(idx2) + GC.Ct1)/(4*sqrt(GC.Ct1)-4)) - 1);
        else
            a_calc = it.dT./(4*pi*prop.r*air.rho(ii)*it.Uinf^2.*(1+it.a).*prop.dr);
        end
    %% Prandtl root and tip loss correction
        if RT.flag
            if strcmp(RT.method,'Prop')
                f_tip = (prop.B/2)*(prop.tip_R - prop.rR )./(prop.rR.*sind(it.phi)) ;
                f_hub = (prop.B/2)*(prop.rR - prop.hub_R)./(prop.rR.*sind(it.phi)) ; 

            elseif strcmp(RT.method,'WT')
                tsr = it.omega*prop.R/it.Uinf;
                f_tip = (prop.B/2)*((prop.tip_R - prop.rR)./prop.rR).*sqrt(1+(tsr*prop.rR).^2./(1+it.a).^2);
                f_hub = (prop.B/2)*((prop.rR - prop.hub_R)./prop.rR).*sqrt(1+(tsr*prop.rR).^2./(1+it.a).^2);

            else
                error('Please select correct root and tip loss correction method for variable RT.method: Prop or WT \n')
            end
            F_tip = (2/pi)*acos(exp(-f_tip)) ;       
            F_hub = (2/pi)*acos(exp(-f_hub)) ;
            it.F = F_tip.*F_hub ;
        else
            it.F = ones(1,length(it.a));
        end
        a_calc = a_calc./it.F;
        a1_calc = it.dQ./(4*pi*prop.r.^3*air.rho(ii)*it.Uinf*it.omega.*(1+it.a).*it.F.*prop.dr);
    %%  Check convergence
        it.diff = abs(it.a - a_calc);
        it.diff1 = abs(it.a1 - a1_calc);

        it.iter = it.iter + 1;
        if it.iter == round(cnvg.maxIter/4,0)
            f = f/2;
        elseif it.iter == round(cnvg.maxIter/2,0)
            f = f/2;
        elseif it.iter == round(3*cnvg.maxIter/4,0)
            f = f/2;
        elseif it.iter == cnvg.maxIter
            fprintf('max diff = %d, not Converged at V = %.2f m/s, J = %.2f, n = %.0f rpm, and pitch = %.0f\n',...
                max(max(abs(it.diff),abs(it.diff1))),it.Uinf,op.points(ii,2),op.points(ii,3)*60,op.points(ii,4))
            %%%%%%%%%%%%%%%%%%%
            fN = fieldnames(it);
            idxNan = it.diff>cnvg.Softtol;
            for iN = 1: length(fN)
                if numel(it.(fN{iN})) == length(prop.rR)
                    varN = it.(fN{iN});
                    varN(idxNan) = nan;
                    it.(fN{iN}) = varN;
                    clear varN
                end
            end
            clear fN idxNan
            %%%%%%%%%%%%%%%%%%%%%%
            break;
        end
    end
    fprintf('Operating point %d of %d, iter = %d, progress = %.02f%% \n',ii,length(op.points(:,1)),it.iter, ii/length(op.points(:,1))*100)
    out{ii,1} = it;
    clear it a_calc a1_calc beta f_hub F_hub f_tip F_tip tsr idm idx idx2 f
end

%% convert cell array to struct format
sz = size(out);
for jj = 1:sz(1)
    bem.Uinf(jj,1) = out{jj,1}.Uinf;
    bem.omega(jj,1) = out{jj,1}.omega;
    bem.a(jj,:) = out{jj,1}.a;
    bem.a1(jj,:) = out{jj,1}.a1;
    bem.iter(jj,1) = out{jj,1}.iter;
    bem.diff(jj,:) = out{jj,1}.diff;
    bem.diff1(jj,:) = out{jj,1}.diff1;
    bem.V_a(jj,:) = out{jj,1}.V_a;
    bem.V_t(jj,:) = out{jj,1}.V_t;
    bem.V_p(jj,:) = out{jj,1}.V_p;
    bem.M(jj,:) = out{jj,1}.M;
    bem.phi(jj,:) = out{jj,1}.phi;
    bem.alpha(jj,:) = out{jj,1}.alpha;
    bem.Re(jj,:) = out{jj,1}.Re;
    bem.Cl(jj,:) = out{jj,1}.Cl;
    bem.Cd(jj,:) = out{jj,1}.Cd;
    bem.dT(jj,:) = out{jj,1}.dT;
    bem.dQ(jj,:) = out{jj,1}.dQ;
    bem.Ct(jj,:) = out{jj,1}.Ct;
    bem.F(jj,:) = out{jj,1}.F;
end
fprintf('BEM Calculations are done.\n')
