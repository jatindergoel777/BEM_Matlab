function data = importfile(filename)

dataArray = importdata(filename);
%% Allocate imported array to column variable names
sz = size(dataArray.data);
if sz(2)<5
    data.alpha = [];
    data.cl = [];
    data.cd = [];
    data.cdp = [];
    data.cm = [];
else
    data.alpha = dataArray.data(:, 1);
    data.cl = dataArray.data(:, 2);
    data.cd = dataArray.data(:, 3);
    data.cdp = dataArray.data(:, 4);
    data.cm = dataArray.data(:, 5);
end


