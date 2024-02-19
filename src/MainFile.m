%{
Main script for running the BEMT code.

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

clearvars
clc
%% User inputs
UserInput;
preProcessBEMV03;

%% call bem solver based on compressiblity correction
if strcmp(PG.method,'interp')
    polarProcess_Minterp; %% Interpolate polar data of blade sections
    bem = BEMfunctionV03_Minterp(air,prop,op,cnvg,D4,PG,RT,GC); %% BEM Calculations
else
    polarProcess_viterna; %% Interpolate polar data of blade sections
    bem = BEMfunctionV03(air,prop,op,cnvg,D4,PG,RT,GC); %% BEM Calculations
end
%%
processBEMResult;

%% save mat file
save(out.matFile1,'D4'); % save interpolated polar data
clearvars D4
save(out.matFile2); % save BEM outputs
