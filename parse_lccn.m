function [class_letters,class_numbers,cutter_1,cutter_2,cutter_3, ...
    date] = parse_lccn(c)
% PARSE_LCCN Parse Library of Congress Call Number
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
% [CLASS_LETTERS, CLASS_NUMBERS, CUTTER_1, CUTTER_2, CUTTER_3, ...
% DATE] = PARSE_LCCN(C) parses a Library of Congress call number input as a
% character array C.
% 

% preallocate outputs
class_letters = '';
class_numbers = '';
cutter_1 = '';
cutter_2 = '';
cutter_3 = '';
date = '';

% trim whitespace
c_new = '';
for i = 1:length(c)
    if isstrprop(c(i),'wspace')
        % check if this whitespace is followed by a four-digit year
        % if so, keep the whitespace (it is a delimiter)
        if (i+4) <= length(c)
            if sum(isstrprop(c(i+1:i+4),'digit')) == 4
                c_new(length(c_new)+1) = c(i);
            end
        end
    else
        c_new(length(c_new)+1) = c(i);
    end
end
c = c_new;

% check for invalid characters
result = (c == '.') + isstrprop(c,'alpha') + ...
                      isstrprop(c,'digit') + ...
                      isstrprop(c,'wspace');
if sum(result) ~= length(c)
    disp('Invalid characters detected.')
    return
end

% set position variables
pos = 1;
pos_last_saved = 0;

% stopping criteria flags
flag_end_of_file = 0;
flag_found_class_letters = 0;
flag_found_class_numbers = 0;
flag_found_date = 0;
flag_found_all_elements = 0;

if isempty(c)
    flag_end_of_file = 1;
end

% parse class letters
while ~flag_end_of_file && ~flag_found_class_letters
    if isstrprop(c(pos),'digit')
        class_letters = c(1:pos-1);
        pos_last_saved = pos-1;
        flag_found_class_letters = 1;
    else
        [pos,flag_end_of_file] = advance_pos(c,pos,1);
    end
end
if flag_end_of_file && ~flag_found_class_letters
    class_letters = c(1:pos-1);
    pos_last_saved = pos-1;
end

% parse class numbers
flag_decimals = 0;
while ~flag_end_of_file && ~flag_found_class_numbers
    if c(pos) == '.'
        if pos+1 > length(c)
            % there is nothing else after the period
            % assume class number is numerals only
            class_numbers = c(pos_last_saved+1:pos-1);
            pos_last_saved = pos-1;
            flag_found_class_numbers = 1;
        elseif isstrprop(c(pos+1),'wspace')
            % there is whitespace after the period
            % assume class number is numerals only
            class_numbers = c(pos_last_saved+1:pos-1);
            pos_last_saved = pos-1;
            flag_found_class_numbers = 1;
        elseif isstrprop(c(pos+1),'alpha')
            % period indicates Cutter
            class_numbers = c(pos_last_saved+1:pos-1);
            pos_last_saved = pos-1;
            flag_found_class_numbers = 1;
        elseif isstrprop(c(pos+1),'digit')
            % period indicates decimals
            flag_decimals = 1;
            flag_found_class_numbers = 1;
        else
            % malformed call number
            disp('Call number is malformed.')
            return
        end
    else
        [pos,flag_end_of_file] = advance_pos(c,pos,1);
    end
end
if flag_decimals == 1
    flag_found_class_numbers = 0;

    % advance position off the period
    [pos,flag_end_of_file] = advance_pos(c,pos,1);

    % look for next instance of a period or a letter, which indicates a
    % Cutter and the end of the class numbers
    while ~flag_end_of_file && ~flag_found_class_numbers
        if c(pos) == '.' || isstrprop(c(pos),'alpha')
            class_numbers = c(pos_last_saved+1:pos-1);
            pos_last_saved = pos-1;
            flag_found_class_numbers = 1;
        else
            [pos,flag_end_of_file] = advance_pos(c,pos,1);
        end
    end
end
if flag_end_of_file && ~flag_found_class_numbers
    class_numbers = c(pos_last_saved+1:pos-1);
    pos_last_saved = pos-1;
end

% parse the remainder of the call number
icutter = 1;
while ~flag_end_of_file && ~flag_found_all_elements

    if c(pos) == '.' || isstrprop(c(pos),'alpha') % process a Cutter

        % set position based on the initial character
        if c(pos) == '.'
            i1 = pos+1;
            [pos,flag_end_of_file] = advance_pos(c,pos,2);
        end
        if isstrprop(c(pos),'alpha')
            i1 = pos;
            [pos,flag_end_of_file] = advance_pos(c,pos,1);
        end

        flag_outside_cutter = 0;
        while ~flag_end_of_file && ~flag_outside_cutter
            if ~isstrprop(c(pos),'digit')
                % no longer inside the Cutter
                % save the Cutter to output
                i2 = pos-1;
                switch icutter
                    case 1
                        cutter_1 = c(i1:i2);
                    case 2
                        cutter_2 = c(i1:i2);
                    case 3
                        cutter_3 = c(i1:i2);
                end
                flag_outside_cutter = 1;
                icutter = icutter + 1;
            else
                % still inside the Cutter, increment position
                [pos,flag_end_of_file] = advance_pos(c,pos,1);
            end
        end

    elseif isstrprop(c(pos),'wspace') % process a date
        % already trimmed extra whitespace
        % the next four characters must be a date
        flag_found_date = 1;
        date = c(pos+1:pos+4);
        [pos,flag_end_of_file] = advance_pos(c,pos,5);

    else
        % didn't find either a Cutter or a date
        % increment position
        [pos,flag_end_of_file] = advance_pos(c,pos,1);
        
    end

    % if found three Cutters and a date, there's nothing more to find
    if icutter > 3 && flag_found_date
        flag_found_all_elements = 1;
    end

end

end

% --------------------------------------------------
function [pos,status] = advance_pos(c,pos,inc)
pos = pos + inc;
if pos > length(c)
    status = 1;
else
    status = 0;
end
end