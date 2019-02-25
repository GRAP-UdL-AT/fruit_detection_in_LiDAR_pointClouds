function [ptCloud_all,ptCloud_all_xyz]=pointCloudReading(Trials,pcDirectory_txt)

    ptCloud_all_xyz=[];
    for i=1:size(Trials,2)
        if exist(strcat(pcDirectory_txt,Trials{i},'.mat'),'file')
            load(strcat(pcDirectory_txt,Trials{i},'.mat'));
        else
            fileID=fopen(strcat(pcDirectory_txt,Trials{i},'.txt'),'r');
            ptCloud_xyz=fscanf(fileID,'%f %f %f %f %f',[5 Inf])';
            fclose(fileID);
            save(strcat(pcDirectory_txt,Trials{i},'.mat'),'ptCloud_xyz');
        end
        ptCloud_all_xyz=[ptCloud_all_xyz;[ptCloud_xyz,ones(size(ptCloud_xyz,1),1)*i]];
    end
    ptCloud_all=pointCloud(ptCloud_all_xyz(:,1:3));

end