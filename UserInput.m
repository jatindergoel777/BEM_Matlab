%% Freestream air Properties
%  Temperature can be varied for each operating point if desired
% In that case length(Tinf) should be equal to
% length(op.pitch)*length(V)*length(J or n)

%%% Define the range of any one of h,Tinf. Leave the second one as empty matrix
air.h = []; % altitude in meters
air.Tinf = 288.15;     % at atmospheric pressure = 1 bar
air.Tunit = 'K';    % K or C - temperature units 
air.gamma = 1.4;    % Specific Heat ratio of air
air.R = 8314.32;    %[J/kmol-K]
air.Mw = 28.9644;   %[kg/kmol]
%% Propeller Geometry
prop.file = './PropellerGeometry/Xprop_geometry.csv'; %Propeller geometry file
prop.scaleFactor = 1.0;     % Scaling factor for the propeller geometry [-]
prop.hub_R = 0.21;          % Hub radius/Radius of propeller [-]
prop.tip_R = 1;             % Tip radius/Radius of propeller [-]
prop.RefBeta_rR = 0.7;      % Referance location for pitch angle [-]
prop.method = 'cosine';     % Two options - 'linear' or 'cosine' for distribution of elements along blade span
prop.elem = 50;             % No. of elements in the radial direction [-]
prop.B = 3;                 % Number of propeller blades [-]

%% Analysis conditions
op.pitch = 15;  % Pitch angle of blade at reference location [deg]

%%% Define the range of any two of V,J, and n. Leave the third one as empty matrix
op.V = 30;      % Freestream air velocity [m/s]
op.M = [];     % Freestream Mach number [-]
op.J = 0.5:0.05:1.5;       % Advance ratio of analysis [-]
op.n = [];      % Rotational speed of propeller [1/s]

%% Convergence condition

cnvg.Hardtol = 1e-10;       % Desired tolerance for convergence of induction factors [-]
cnvg.Softtol = 1e-3;       % Minimum acceptable tolerance for convergence of induction factors [-]
cnvg.maxIter = 1000;    % Max number of iterations to converge to the tolerence level [-]
cnvg.f = 0.2;           % Fraction of change in the solution after each iteration [-]

%% BEM Corrections

%%% Correction for compressibility
PG.flag = true;
PG.Mcrit = 0.7;
PG.method = 'PG';   %Two choices - 'KT', 'PG'; KT stand for Karman-Tsien and PG stand for Prandtl-Glauert

%%% Root-tip correction
RT.flag = true;
RT.method = 'Prop'; %'Prop' or 'WT' - Two different root and tip corrections

%%% Glauert correction for heavily loaded rotors - for Regenerative regime
GC.flag = true;
GC.Ct1 = 1.816;

%% Polar data inputs - Read already calculated polars

pd.xtr = 1.00;                      % transition point - 0.05 or 1
pd.ReFolder = (0.1:0.2:9.9).*10^6;  % Re of folder conitaining data
pd.ReData = (0.1:0.2:9.9).*10^6;      % Range of Re to be used for analysis (preferably avoid very low Re)

%%% Rotation correction parameters for RFOIL
pd.RC.flag = 1;                     % Include rotational effects in polars? 
pd.RC.f = 1;                        % Rotational correction parameter
pd.RC.rf = [1 1 0];                 % Rotation correction parameters
pd.N = 4.5;                         % critical amplification exponent

%%%
pd.folderPath = './PolarData/';

%% File output
out.Mainfolder = './Analysis/';