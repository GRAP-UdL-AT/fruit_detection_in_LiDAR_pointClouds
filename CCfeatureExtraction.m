function CCfeatures=CCfeatureExtraction(ptCloud_all_thresh60_notOutliers_xyz,class,Groundtruth_Directory,Trials)

apple_detectionsPC=pointCloud(ptCloud_all_thresh60_notOutliers_xyz(class>0,1:3));

LCM=LabelClusterMatrix(apple_detectionsPC,Groundtruth_Directory,Trials,class(class>0));
CCfeatures=zeros(size(LCM,2),15);
for i=1:size(LCM,2)
    CCxyz=ptCloud_all_thresh60_notOutliers_xyz(class==i,1:4);
    if size(CCxyz,1)
    CCfeatures(i,1)=sum(LCM(:,i)>10); %nº of apples in the cluster(Groundtruth)
    CCfeatures(i,2)=size(CCxyz,1); %nº of points in the cluster
    CCfeatures(i,3:5)=max(CCxyz(:,1:3))-min(CCxyz(:,1:3)); %XYZ dimensions
    [~,CCfeatures(i,6)]=boundary(CCxyz(:,1:3),0); %Volume using the boundary points
        if size(CCxyz,1)>2
            CCfeatures(i,7:9)=svd(CCxyz(:,1:3)-mean(CCxyz(:,1:3)))/sum(svd(CCxyz(:,1:3)-mean(CCxyz(:,1:3))));    
        else
            CCfeatures(i,7:9)=[1,0,0];
        end
    CCfeatures(i,10:14)=histcounts(CCxyz(:,4),60:8:100, 'Normalization', 'probability');
    CCfeatures(i,16)=prod(CCfeatures(i,3:5)); %Volume of the bounding box in cartesian coordinates
    CCfeatures(i,17)=mean(CCxyz(:,4));
    CCfeatures(i,18)=max(CCxyz(:,4));
    CCfeatures(i,19)=std(CCxyz(:,4));
    CCfeatures(i,20)=mean(CCxyz(:,1));
    CCfeatures(i,21)=mean(CCxyz(:,3));
    end

end

CCfeatures(:,15)=27*prod(CCfeatures(:,7:9),2);
