%% Josh Barrios 2/19/19
% Takes a string and an index value and looks for a number following that
% index. Intended to find fish numbers and trial numbers in filenames.
% Start the string with the index after 'Fish' or 'F' and go to end.

function num = findNum(string)

if ~isempty(string)
    num_bool = isstrprop(string,'digit');
    
    if logical(sum(num_bool))
        first = find(num_bool);
        first_num = str2double(string(first(1)));
        seqs = findseq(single(num_bool));
        
        if ~isempty(seqs) && seqs(1,2) == first(1)      % seqs doesn't find single numbers
            num = str2double(string(seqs(1,2):seqs(1,3)));
        else
            num = first_num;
        end
    else
        num = NaN;
    end
else
    num = NaN;
end