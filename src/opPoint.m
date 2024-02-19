%{
Script for calculating all the operating condition points.

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
function op = opPoint(op,D)
%%% convert inputs to column vector
op.V = op.V(:);             %reshape(op.V,length(op.V),1);
op.J = op.J(:);             %reshape(op.J,length(op.J),1);
op.n = op.n(:);             %reshape(op.n,length(op.n),1);
op.pitch = op.pitch(:);     %reshape(op.pitch,length(op.pitch),1);

if isempty(op.V)
    if length(op.J) == length(op.n)
        if length(op.J) ~= 1
            fprintf(['NOTE: ','Length of advance ratio and rps is same. ',...
                'Therefore, assuming ordered pair input.\n',...
                'For sweep of one parameter while keeping other constant either input ordered pairs,\n',...
                'or the length of the two variables should not be same.\n'])
        end
        op.V = op.J.*op.n.*D;
        op.points = [op.V, op.J, op.n];
    else
        op.V = op.J'.*op.n.*D;
        n = ones(size(op.J')).*op.n;
        J = op.J'.*ones(size(op.n));
        op.points = [op.V(:), J(:), n(:)];
    end
elseif isempty(op.J)
    if length(op.V) == length(op.n)
        if length(op.V) ~= 1
            fprintf(['NOTE: ','Length of Velocity and rps is same. ',...
                'Therefore, assuming ordered pair input.\n',...
                'For sweep of one parameter while keeping other constant either input ordered pairs,\n',...
                'or the length of the two variables should not be same.\n'])
        end
        op.J = op.V./(op.n.*D);
        op.points = [op.V, op.J, op.n];
    else
        op.J = op.V'./(op.n.*D);
        n = ones(size(op.V')).*op.n;
        V = op.V'.*ones(size(op.n));
        op.points = [V(:), op.J(:), n(:)];
    end

elseif isempty(op.n)
    if length(op.V) == length(op.J)
        if length(op.V) ~= 1
            fprintf(['NOTE: ','Length of Velocity and advance ratio is same. ',...
                'Therefore, assuming ordered pair input.\n',...
                'For sweep of one parameter while keeping other constant either input ordered pairs,\n',...
                'or the length of the two variables should not be same.\n'])
        end
        op.n = op.V./(op.J.*D);
        op.points = [op.V, op.J, op.n];
    else
        op.n = op.V'./(op.J.*D);
        J = ones(size(op.V')).*op.J;
        V = op.V'.*ones(size(op.J));
        op.points = [V(:), J(:), op.n(:)];
    end
end