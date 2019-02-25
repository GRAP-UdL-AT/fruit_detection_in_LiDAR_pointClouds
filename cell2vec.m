function [vector] = cell2vec(cell)
    vector = [];
    for i=1:size(cell,1)
        aux = cell(i);
        vector = [vector, str2double(aux{1})];
    end
end