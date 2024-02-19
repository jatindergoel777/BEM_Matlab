%{
Script for importing polar data from text files.

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


