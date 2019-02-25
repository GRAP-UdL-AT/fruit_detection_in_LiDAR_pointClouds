function [LCM,PtsInLabel]=LabelClusterMatrix(ptCloud,ROIs_directory,Trials,clustersID)

ROIs=[];
for i=1:size(Trials,2)
    files= ListFiles_txt(strcat(ROIs_directory,Trials{i}(1:6)));
    ROIs=[ROIs ; files];
end

PtsInLabel=zeros(size(clustersID));
positive=unique(clustersID);
LCM=zeros(size(ROIs,1),size(positive,2));%Labels_Clusters_matrix: matrix that relates the clustersID and the Labels
    for i=1:size(ROIs,1)
        ROIvertex=txt2cell(strcat(ROIs(i).folder,'/',ROIs(i).name));
        ROIvertex=[cell2vec(ROIvertex(:,1))',cell2vec(ROIvertex(:,2))',cell2vec(ROIvertex(:,3))'];
        ROI=[min(ROIvertex)',max(ROIvertex)'];
        ROIindex=findPointsInROI(ptCloud,ROI); 
        LCM(i,:)=histcounts(clustersID(ROIindex),[positive (max(positive)+1)]);
        PtsInLabel(ROIindex)=1;
        
    end

LCM(LCM<10)=0;

    PtsInLabel=PtsInLabel.*clustersID;
    classPtsInLabel=histcounts(PtsInLabel,[positive (max(positive)+1)]);
    classPts=histcounts(clustersID,[positive (max(positive)+1)]);
    LCM(:,(classPtsInLabel./classPts)<0.5)=0;

end
