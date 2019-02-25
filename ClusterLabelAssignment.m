%% Detection assesment

function [LCM_LOC,LCM_LOC_COL]=ClusterLabelAssignment(LCM)

LCM_logical=logical(LCM);
Labels_per_cluster=sum(LCM_logical);
Clusters_one_label=(Labels_per_cluster==1); %COL=Clusters_one_label
LCM_COL=LCM_logical.*repmat(Clusters_one_label,size(LCM,1),1); %LCM with the clusters that has only one label.
Clusters_per_labels_COL=sum(LCM_COL,2);
LCM_COL_LTwoC=LCM_COL.*repmat(Clusters_per_labels_COL>1,1,size(LCM,2));%LCM with the clustersID that has more than on cluster with only one label.
LCM_COL_LOC=LCM_COL.*((LCM_COL_LTwoC.*LCM)==max((LCM_COL_LTwoC.*LCM),[],2));
LWC=repmat(sum(LCM_COL_LOC,2),1,size(LCM,2)); %Labels with cluster assigned


LCM_not_COL=LCM_logical;
LCM_not_COL(LCM_COL==1)=0; %LCM with the clusters that has more than one label
LCM_not_COL_LOC=(~LWC).*(LCM_not_COL.*((LCM_not_COL.*LCM)==max((LCM_not_COL.*LCM),[],2)));

LCM_LOC=LCM_COL_LOC+LCM_not_COL_LOC;% LCM assigning only one cluster to each Label

LCM_LOC_COL=(LCM_LOC.*((LCM_LOC.*LCM)==max((LCM_LOC.*LCM),[],1)));%LCM assigning only one cluster to each Label and one Label to each Cluster

end
