%{
Script for interpolation of polar data and extrapolation using viterna method.

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
function D3 = polarInterp4D_viterna(polarPath, r_R_given, Re_data, alpha_range)
st = 2:length(r_R_given);
[D3.rR,D3.Re,D3.alpha] = meshgrid(r_R_given(2:end),Re_data,alpha_range);
data.alpha = [];
data.cl = []; data.cd = [];
data.Re = [];
data.rR = [];
for i=1:length(st)
    for j=1:length(Re_data)
        filename = sprintf(polarPath,st(i),Re_data(j));
        polarData(i,j) = importfile(filename);
        ln = length(data.alpha); p_ln = length(polarData(i,j).alpha);
        data.alpha(ln+1:ln+p_ln ) = polarData(i,j).alpha;
        data.cl(ln+1:ln+p_ln) = polarData(i,j).cl;
        data.cd(ln+1:ln+p_ln) = polarData(i,j).cd;
        data.Re(ln+1:ln+p_ln) = Re_data(j)*ones(length(polarData(i,j).alpha),1);
        data.rR(ln+1:ln+p_ln) = r_R_given(st(i))*ones(length(polarData(i,j).alpha),1);
    end
end
D3.Fcl = scatteredInterpolant(data.rR',data.Re',data.alpha',data.cl','linear','none');
D3.Fcd = scatteredInterpolant(data.rR',data.Re',data.alpha',data.cd','linear','none');
D3.Cl = D3.Fcl(D3.rR,D3.Re,D3.alpha);
D3.Cd = D3.Fcd(D3.rR,D3.Re,D3.alpha);

Fcl_near = scatteredInterpolant(data.rR',data.Re',data.alpha',data.cl','linear','nearest');
Fcd_near = scatteredInterpolant(data.rR',data.Re',data.alpha',data.cd','linear','nearest');
Cl_near = Fcl_near(D3.rR,D3.Re,D3.alpha);
Cd_near = Fcd_near(D3.rR,D3.Re,D3.alpha);
%% Do extrapolation using viterna method
for i = 1:length(st)

    for j = 1: length(Re_data)
        extrap.alpha = D3.alpha(j,i,:);
        extrap.cl = D3.Cl(j,i,:);
        extrap.cd = D3.Cd(j,i,:);
        if sum(isnan(extrap.cl(:)))>0 || sum(isnan(extrap.cd(:)))>0
            if sum(isnan(extrap.cl(:))) == length(extrap.cl(:))
                D3.Cl(j,i,:) = Cl_near(j,i,:);
                D3.Cd(j,i,:) = Cd_near(j,i,:);
            else
                idx = find(~isnan(extrap.cl(:))& ~isnan(extrap.cd(:))); idxNan = find(isnan(extrap.cl(:)) | isnan(extrap.cd(:)));
                [vt.cl,vt.cd] = viternaExtrap(extrap.alpha(idx),extrap.cl(idx),extrap.cd(idx),extrap.alpha);
                Cl_out(idx) = extrap.cl(idx);
                Cl_out(idxNan) = vt.cl(idxNan);
                D3.Cl(j,i,:) = reshape(Cl_out,[1, 1,length(alpha_range)]);

                Cd_out(idx) = extrap.cd(idx);
                Cd_out(idxNan) = vt.cd(idxNan);
                D3.Cd(j,i,:) = reshape(Cd_out,[1, 1,length(alpha_range)]);
            end
            clear idx idxNan vt Cl_out Cd_out
        end
    end

end