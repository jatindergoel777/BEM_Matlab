%% Polar Data
if ~pd.RC.flag
pd.N_xtr = sprintf('st1-25_Re%.0f-%.0f_N%03d_xTRU%.2f_xTRL%.2f',min(pd.ReFolder),max(pd.ReFolder),pd.N*100,pd.xtr,pd.xtr);
else
pd.N_xtr = sprintf('st1-25_Re%.0f-%.0f_N%03d_xTRU%.2f_xTRL%.2f_f%.2f_cr2by3_1.00-0.07_rf123_%.2f_%.2f_%.2f',min(pd.ReFolder),max(pd.ReFolder),pd.N*100,pd.xtr,pd.xtr,pd.RC.f,pd.RC.rf);
% pd.N_xtr = sprintf('st1-25_Re%.0f-%.0f_N%03d_xTRU%.2f_xTRL%.2f_f%.2f_cr1by3_1.00-0.07_rf123_%.2f_%.2f_%.2f',min(pd.ReFolder),max(pd.ReFolder),pd.N*100,pd.xtr,pd.xtr,pd.RC.f,pd.RC.rf);

end

pd.xtr_str = sprintf('_xTRU%.2f_xTRL%.2f',pd.xtr,pd.xtr);
if ~pd.RC.flag
pd.polarPath = [pd.folderPath,pd.N_xtr,'/st%d_Re%.0f_',sprintf('N%03d',pd.N*100),pd.xtr_str,'.txt'];
else
pd.polarPath = [pd.folderPath,pd.N_xtr,'/st%d_Re%.0f_',sprintf('N%03d',pd.N*100),pd.xtr_str,sprintf('_f%.2f_rf123_%.2f_%.2f_%.2f',pd.RC.f,pd.RC.rf),'.txt'];
end
pd.alpha_range = -50:0.1:50;
pd.file = [pd.folderPath,pd.N_xtr,sprintf('/InterpolatedData_Re%.0f-%.0f_alpha%.0f-%.0f_viterna.mat',...
    min(pd.ReData),max(pd.ReData),min(pd.alpha_range),max(pd.alpha_range))];
if isfile(pd.file)
    fprintf('Previously interpolated data exists for this case. Loading data...\n')
    tic
    load(pd.file)
    t = toc;
    fprintf('Loading of polar data took %.0f seconds\n',t)
else
    fprintf('Previously interpolated data does not exist for this case. Interpolating data...\n')
    tic
%     D4 = polarInterp4D(pd.polarPath, prop.geom.rR, pd.ReData, pd.alpha_range);
    D4 = polarInterp4D_viterna(pd.polarPath, prop.geom.rR, pd.ReData, pd.alpha_range);
%     D4 = polarInterp3D(pd.polarPath, prop.geom.rR', pd.ReData, pd.alpha_range);
    t = toc;
    fprintf('Interpolation of Polar data took %.0f seconds\n',t)
    save(pd.file,'D4')
end
clear t