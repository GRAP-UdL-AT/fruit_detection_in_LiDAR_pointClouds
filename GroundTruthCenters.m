%% Detection assesment

function center_of_labels=GroundTruthCenters(ROIs_directory)
    
    ROIs= ListFiles_txt(ROIs_directory);

    center_of_labels=zeros(size(ROIs,1),3);
    for i=1:size(ROIs,1)
        ROIvertex=txt2cell(strcat(ROIs_directory,'/',ROIs(i).name));
        ROIvertex=[cell2vec(ROIvertex(:,1))',cell2vec(ROIvertex(:,2))',cell2vec(ROIvertex(:,3))'];
        center_of_labels(i,:)=ROIvertex(1,:);
    end
end
