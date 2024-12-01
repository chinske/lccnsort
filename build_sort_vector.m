function A = build_sort_vector(class_letters,class_numbers, ...
    cutter_1,cutter_2,cutter_3,date)
% BUILD_SORT_VECTOR Build Sort Vector for Library of Congress Call Number
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
% A = BUILD_SORT_VECTOR(CLASS_LETTERS, CLASS_NUMBERS, ...
% CUTTER_1, CUTTER_2, CUTTER_3, DATE) builds an 8-element vector A of real
% values that represent a parsed Library of Congress call number consisting
% of:
% 
%   CLASS_LETTERS
%   CLASS_NUMBERS
%   CUTTER_1
%   CUTTER_2
%   CUTTER_3
%   DATE
% 
% specified as character arrays.  The vector A can be used for sorting
% Library of Congress call numbers based on a numerical sorting algorithm.
% 

A = zeros(1,8);

% process class letters
if length(class_letters) == 1
    A(1) = lower(class_letters(1)) - 'a' + 1;
    A(2) = 0;
elseif length(class_letters) == 2
    A(1) = lower(class_letters(1)) - 'a' + 1;
    A(2) = lower(class_letters(2)) - 'a' + 1;
elseif length(class_letters) == 3
    A(1) = lower(class_letters(1)) - 'a' + 1;
    A(2) = lower(class_letters(2)) - 'a' + 1;
    A(3) = lower(class_letters(3)) - 'a' + 1;
else
    error('Invalid CLASS_LETTERS')
end

% process class numbers
A(4) = str2double(class_numbers);

% process Cutter 1
ipart = 0;
fpart = 0;
if ~isempty(cutter_1)
    ipart = lower(cutter_1(1)) - 'a' + 1;
end
if length(cutter_1) > 1
    fpart = str2double(cutter_1(2:length(cutter_1)));
end
while fpart > 1
    fpart = fpart./10;
end
A(5) = ipart+fpart;

% process Cutter 2
ipart = 0;
fpart = 0;
if ~isempty(cutter_2)
    ipart = lower(cutter_2(1)) - 'a' + 1;
end
if length(cutter_2) > 1
    fpart = str2double(cutter_2(2:length(cutter_2)));
end
while fpart > 1
    fpart = fpart./10;
end
A(6) = ipart+fpart;

% process Cutter 3
ipart = 0;
fpart = 0;
if ~isempty(cutter_3)
    ipart = lower(cutter_3(1)) - 'a' + 1;
end
if length(cutter_3) > 1
    fpart = str2double(cutter_3(2:length(cutter_3)));
end
while fpart > 1
    fpart = fpart./10;
end
A(7) = ipart+fpart;

% process date
A(8) = str2double(date);