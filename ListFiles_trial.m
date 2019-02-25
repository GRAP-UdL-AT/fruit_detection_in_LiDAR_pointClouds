function [Trials,Trial] = ListFiles_trial(directory,Trial,Late_fusion_comb)

f = dir(directory);
% 
% files = [];
% for i=1:size(f,1)
%     if f(i).isdir==0
%         if strcmp(Trial,'all')==1 && strcmp(f(i).name(end-2:end),'txt')==1
%             files = [files ; f(i)];
%         elseif strcmp(f(i).name(end-7:end),strcat(Trial,'.txt'))==1
%             files = [files ; f(i)];
%         elseif strcmp(f(i).name(end-8:end),strcat(Trial,'.txt'))==1
%             files = [files ; f(i)];
%         elseif strcmp(f(i).name(end-9:end),strcat(Trial,'.txt'))==1
%             files = [files ; f(i)];   
%         end
%     end
% end

Trials=struct('name',Trial);


for T=1:size(Trials,2)
    k=1;
    for i=1:size(f,1)
        if strcmp(f(i).name(8:end-4),Trials(T).name)==1 && strcmp(f(i).name(end-2:end),'txt')==1
            Trials(T).trees(k).treeID=f(i).name(1:6);
            Trials(T).trees(k).file=f(i).name;
            k=k+1;
        end            
    end      
end


for combID=1:size(Late_fusion_comb,2)
    T=T+1;
    for k=1:size(Trials(Late_fusion_comb{combID}(1)).trees,2)
        Trials(T).trees(k).treeID=Trials(Late_fusion_comb{combID}(1)).trees(k).treeID;
        Trials(T).trees(k).file='late_fusion';
        Trials(T).trees(k).fuseTrials=Late_fusion_comb{combID};
    end
    Trial{T}=strcat(Trial{Late_fusion_comb{combID}});
end
