%{
Script for processing polar data inputs.

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
%% Polar Data
if ~pd.RC.flag
    pd.N_xtr = sprintf('st1-25_Re%.0f-%.0f_N%03d_xTRU%.2f_xTRL%.2f',min(pd.ReFolder),max(pd.ReFolder),pd.N*100,pd.xtr,pd.xtr);
else
    for m = 1:length(pd.M)
        pd.N_xtr{m} = sprintf('st2-25_Re%.0f-%.0f_N%03d_xTRU%.2f_xTRL%.2f_f%.2f_cr2by3_1.00-0.07_rf123_%.2f_%.2f_%.2f_M%.02f',min(pd.ReFolder),max(pd.ReFolder),pd.N*100,pd.xtr,pd.xtr,pd.RC.f,pd.RC.rf,pd.M(m));
    end
end

pd.xtr_str = sprintf('_xTRU%.2f_xTRL%.2f',pd.xtr,pd.xtr);
if ~pd.RC.flag
    pd.polarPath = [pd.folderPath,pd.N_xtr,'/st%d_Re%.0f_',sprintf('N%03d',pd.N*100),pd.xtr_str,'.txt'];
else
    for m = 1:length(pd.M)
        pd.polarPath{m} = [pd.folderPath,pd.N_xtr{m},'/st%d_Re%.0f_',sprintf('N%03d',pd.N*100),pd.xtr_str,sprintf('_f%.2f_rf123_%.2f_%.2f_%.2f',pd.RC.f,pd.RC.rf),'.txt'];
    end
end
pd.alpha_range = -50:0.1:50;
pd.file = [pd.folderPath,sprintf('/InterpolatedData_Re%.0f-%.0f_M%.02f-%.02f_alpha%.0f-%.0f_viterna.mat',...
    min(pd.ReData),max(pd.ReData),min(pd.M),max(pd.M),min(pd.alpha_range),max(pd.alpha_range))];

if isfile(pd.file)
    fprintf('Previously interpolated data exists for this case. Loading data...\n')
    tic
    load(pd.file);
    t = toc;
    fprintf('Loading of polar data took %.0f seconds\n',t)
else
    fprintf('Previously interpolated data does not exist for this case. Interpolating data...\n')
    for m = 1:length(pd.M)
        D4.M(m) = pd.M(m);
        tic
        D4.data{m} = polarInterp4D_viterna(pd.polarPath{m}, prop.geom.rR, pd.ReData, pd.alpha_range);
        t = toc;
        fprintf('Interpolation of Polar data for M = %.02f took %.0f seconds\n',pd.M(m),t)
        clear t
    end
    save(pd.file,'D4')
end

