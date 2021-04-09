function D3 = polarInterp4D(polarPath, r_R_given, Re_data, alpha_range)
st = 2:length(r_R_given);
[D3.rR,D3.Re,D3.alpha] = meshgrid(r_R_given(2:end),Re_data,alpha_range);
% span = 50;
data.alpha = [];
data.cl = []; data.cd = [];
data.Re = [];
data.rR = [];
for i=1:length(st)
    for j=1:length(Re_data)
        filename = sprintf(polarPath,st(i),Re_data(j));
%         polarData(i,j) = load(filename);
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
% D3.SI.Cl = D3.Cl;
% D3.SI.Cd = D3.Cd;
%% Do extrapolation radial station wise
span = 50;
for i = 1:length(st)
    
    for j = 1: length(Re_data)
    extrap.alpha = D3.alpha(j,i,:);
    extrap.cl = D3.Cl(j,i,:);
    extrap.cd = D3.Cd(j,i,:);
    if sum(isnan(extrap.cl(:)))>0 || sum(isnan(extrap.cd(:)))>0
        idx = find(~isnan(extrap.cl(:))); idxNan = find(isnan(extrap.cl(:)));
        Fcl =  smooth(extrap.alpha,extrap.cl,span);%scatteredInterpolant(extrap.Re(idx),extrap.alpha(idx),extrap.cl(idx),'natural','linear');
        Cl_out(idx) = extrap.cl(idx);
        Cl_out(idxNan) = Fcl(idxNan);
        D3.Cl(j,i,:) = reshape(Cl_out,[1, 1,length(alpha_range)]);
        
        clear idx idxNan Fcl
        idx = find(~isnan(extrap.cd(:))); idxNan = find(isnan(extrap.cd(:)));
        Fcd =  smooth(extrap.alpha,extrap.cd,span);%scatteredInterpolant(extrap.Re(idx),extrap.alpha(idx),extrap.cd(idx),'natural','linear');
        Cd_out(idx) = extrap.cd(idx);
        Cd_out(idxNan) = Fcd(idxNan);
        D3.Cd(j,i,:) = reshape(Cd_out,[1, 1,length(alpha_range)]);
        clear idx idxNan Fcd
    end
    end

end
% %% Do extrapolation radial station wise
% 
% for i = 1:length(st)
%     extrap.alpha = D3.alpha(:,i,:);
%     extrap.Re = D3.Re(:,i,:);
%     extrap.cl = D3.Cl(:,i,:);
%     extrap.cd = D3.Cd(:,i,:);
%     if sum(isnan(extrap.cl(:)))>0 || sum(isnan(extrap.cd(:)))>0
%         idx = find(~isnan(extrap.cl(:))); idxNan = find(isnan(extrap.cl(:)));
%         extrap.Fcl{i} =  scatteredInterpolant(extrap.Re(idx),extrap.alpha(idx),extrap.cl(idx),'natural','linear');
%         Cl_out(idx) = extrap.cl(idx);
%         Cl_out(idxNan) = extrap.Fcl{i}(extrap.Re(idxNan),extrap.alpha(idxNan));
%         D3.Cl(:,i,:) = reshape(Cl_out,[length(Re_data), 1,length(alpha_range)]);
%         
%         clear idx idxNan
%         idx = find(~isnan(extrap.cd(:))); idxNan = find(isnan(extrap.cd(:)));
%         extrap.Fcd{i} =  scatteredInterpolant(extrap.Re(idx),extrap.alpha(idx),extrap.cd(idx),'natural','linear');
%         Cd_out(idx) = extrap.cd(idx);
%         Cd_out(idxNan) = extrap.Fcd{i}(extrap.Re(idxNan),extrap.alpha(idxNan));
%         D3.Cd(:,i,:) = reshape(Cd_out,[length(Re_data), 1,length(alpha_range)]);
%         clear idx idxNan
%     end
% 
% end
% 
