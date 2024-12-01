function library = sort_by_lccn(library)
% SORT_BY_LCCN Sort by Library of Congress Call Number
% 
% Copyright 2024 Christopher Chinske
% 
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program. If not, see <https://www.gnu.org/licenses/>.
% 
% LIBRARY = SORT_BY_LCCN(LIBRARY) sorts a table LIBRARY that includes
% Library of Congress call numbers in a column-oriented variable
% LCClassification and years of publication in a column-oriented variable
% Date.
% 

sort_var = zeros(size(library,1),8);
library = [array2table(sort_var),library];

for i = 1:size(library,1)
    c = char(library.LCClassification(i));
    [f1,f2,f3,f4,f5,f6] = parse_lccn(c);
    A = build_sort_vector(f1,f2,f3,f4,f5,f6);
    library(i,1:8) = num2cell(A);
end

jdate = find(strcmp(library.Properties.VariableNames,'Date'));
library = sortrows(library,[1:8,jdate]);
library = library(:,9:size(library,2));