function cell = txt2cell(textfile, retreive_by, idxs)
% Function that reads a textfile and returns a cell array with the
% indicated columns. If there is no indicated columns the function returns
% the whole textfile into a cell array. 
% Example: txt2cell(textfile) returns all columns and rows.
%          txt2cell(textfile, 'columns', [1 3 5]) returns the first, third and fifth
%               columns (in the specified order).
%          txt2cell(textfile, 'rows', [1 3 5]) returns the first, third and
%               fifth rows (in the specified order).
    if nargin < 2
       retreive_by = 'nan';
       idxs = 0;
    end
    if nargin == 2
       disp('Error, requires index of selected columns or rows')
       return
    end
  
    file = fopen(textfile);
    cell = [];
    while(1)
        row = fgetl(file);
        if(row == -1)
            break
        else
            split_row = strsplit(row);
            if (isequal(retreive_by, 'columns'))
                cell = [cell; split_row(idxs)]; %Return selected columns
            else
                cell = [cell; split_row]; %Return the whole txt
            end
        end
        
    end
    fclose(file);
    if strcmp(retreive_by, 'rows')
        cell =  cell(idxs, :);
    end
end