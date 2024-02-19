%{
Script for processing user inputs.

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
%% Input parameters for BEM model

%% Discretization
if strcmp(prop.method,'cosine')
    prop.rRNodes = cosspace(prop.hub_R,prop.tip_R,prop.elem+1);
elseif strcmp(prop.method,'linear')
    prop.rRNodes = linspace(prop.hub_R,prop.tip_R,prop.elem+1);
else
    warning('Wrong Input! Calculations will continue with <strong>linear</strong> method')
    prop.rRNodes = linspace(prop.hub_R,prop.tip_R,prop.elem+1);
end
prop.rR = (prop.rRNodes(1:end-1)+prop.rRNodes(2:end))/2;
prop.drR = diff(prop.rRNodes);
%% Blade properties
prop.geom = importdata(prop.file);
prop.geom.data = prop.geom.data';
prop.geom.textdata = prop.geom.textdata';
prop.geom.rR = prop.geom.data(1,:);
prop.R = prop.geom.data(2,end)/1000*prop.scaleFactor; % in meters
prop.Dia = 2*prop.R;
prop.b = interp1(prop.geom.rR, prop.geom.data(4,:), prop.rR,'spline','extrap')./(1000)*prop.scaleFactor; %in meters
prop.twist = interp1(prop.geom.rR, prop.geom.data(3,:), prop.rR,'spline','extrap'); %degrees
prop.twist0 = interp1(prop.rR,prop.twist,prop.RefBeta_rR);
prop.twist = prop.twist - prop.twist0;
prop.br = prop.b./(prop.rR*prop.R);

prop.r = prop.rR*prop.R;
prop.dr = prop.drR*prop.R;
%% Operating points
%%% calulate the operation conditions using user inputs and update op
airP = airProp(air);
if strcmp(air.Tunit,'K')
    airP.c = sqrt(air.gamma*(air.R/air.Mw).*airP.T); % speed of sound for PG correction [m/s]
elseif strcmp(air.Tunit,'C')
    airP.c = sqrt(air.gamma*(air.R/air.Mw).*(airP.T+273.15)); % speed of sound for PG correction [m/s
else
    error('Error. Please input temperature units: K - Kelvin (K) or C- Celsius.')
end

if isempty(op.V) && ~isempty(op.M)
    op.V = op.M(:)'.*airP.c(:)';
elseif ~isempty(op.V) && isempty(op.M)
    op.M = op.V(:)'./airP.c(:)';
elseif ~isempty(op.V) && ~isempty(op.M)
    error('Either provide velocity or freestream Mach number')
end

op = opPoint(op,prop.Dia); %[V J n]
op.theta = prop.twist + op.pitch;

var.sz = size(op.points);
var.points = repmat(op.points,length(op.pitch),1);
var.pitch = repmat(op.pitch',var.sz(1),1);
var.points(:,4) = var.pitch(:);

op.points = var.points; % [V J n pitch]
op.pointsTheta = prop.twist + op.points(:,4);
op.sz = size(op.points);
%% air properties

if length(air.Tinf) == 1 || length(air.h) == 1
    air.Tinf = airP.T*ones(op.sz(1),1);
    air.rho = airP.rho*ones(op.sz(1),1);
    air.mu = airP.mu*ones(op.sz(1),1);
    air.nu = airP.nu*ones(op.sz(1),1);
elseif length(air.Tinf) == op.sz(1) || length(air.h) == op.sz(1)
    air.rho = airP.rho;
    air.mu = airP.mu;
    air.nu = airP.nu;
elseif length(air.Tinf) == length(op.V) || length(air.h) == length(op.V)
    air.rho = zeros(op.sz(1),1); air.mu = zeros(op.sz(1),1);
    air.nu = zeros(op.sz(1),1); air.Tinf = zeros(op.sz(1),1);
    for ia = 1:length(op.V)
        idxa = find(op.points(:,1) == op.V(ia));
        air.rho(idxa) = airP.rho(ia);
        air.mu(idxa) = airP.mu(ia);
        air.nu(idxa) = airP.nu(ia);
        air.Tinf(idxa) = airP.T(ia);
    end
else
    error('Error. Either define constant temperature/height for analysis or temperature/height should be defined for every operating condition to be analysed');
end

if strcmp(air.Tunit,'K')
    PG.c = sqrt(air.gamma*(air.R/air.Mw).*air.Tinf); % speed of sound for PG correction [m/s]
elseif strcmp(air.Tunit,'C')
    PG.c = sqrt(air.gamma*(air.R/air.Mw).*(air.Tinf+273.15)); % speed of sound for PG correction [m/s
else
    error('Error. Please input temperature units: K - Kelvin (K) or C- Celsius.')
end
%% output
out.subFolder = sprintf('pitch%.0f-%.0f_V%.0f-%.0f_J%.2f-%.2f_n%.0f-%.0f_B%.0f_SF%d',...
    min(op.pitch(:)),max(op.pitch(:)),min(op.V(:)),max(op.V(:)),min(op.J(:)),...
    max(op.J(:)),min(op.n(:))*60,max(op.n(:))*60,prop.B,prop.scaleFactor);
if not(isfolder([out.Mainfolder,out.subFolder,out.subFolderString]))
    mkdir([out.Mainfolder,out.subFolder,out.subFolderString])
end
out.matFile1 = [out.Mainfolder,out.subFolder,out.subFolderString,'/',sprintf('D4_BemResults_N%03d_xtr%.2f.mat',pd.N*100,pd.xtr)]; %% polar data used for the run
out.matFile2 = [out.Mainfolder,out.subFolder,out.subFolderString,'/',sprintf('BemResults_N%03d_xtr%.2f.mat',pd.N*100,pd.xtr)]; %% bem output
%%
clear t airP var