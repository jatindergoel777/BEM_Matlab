clearvars
clc
%% User inputs
% UserInputValidation;
UserInput;
preProcessBEMV03;
%% Interpolate polar data of blade sections
polarProcess_viterna;
%% BEM Calculations
bem = BEMfunctionV03(air,prop,op,cnvg,D4,PG,RT,GC);
%%
processBEMResult;

%% save mat file
save(out.matFile1,'D4');
clearvars D4
save(out.matFile2);
