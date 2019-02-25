function class=CC_split(CCwmtoa_K,ptCloud_all_thresh60_notOutliers_xyz,class)


for i=1:size(CCwmtoa_K,1)
    if CCwmtoa_K(i)
        CCxyz=ptCloud_all_thresh60_notOutliers_xyz(class==i,1:3);
        rng(1); % For reproducibility
        idx=kmeans(CCxyz,CCwmtoa_K(i));
        idx_class=idx;
        idx_class(idx==1)=i;
        if max(idx)>1
            for j=2:max(idx)
                idx_class(idx==j)=max(class)+j-1;
            end
        end
        class(class==i)=idx_class;           
    end
end
