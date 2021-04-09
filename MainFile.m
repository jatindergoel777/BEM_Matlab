clearvars
clc
%% User inputs
% UserInputValidation;
UserInput;
preProcessBEM;
%% Interpolate polar data of blade sections
polarProcess;
%% BEM Calculations
bem = BEMfunctionV03(air,prop,op,cnvg,D4,PG,RT,GC);
%%
processBEMResult;

%% save mat file
out.str = '';
save([out.matFile1,out.str],'D4');
clearvars D4
save([out.matFile2,out.str]);
