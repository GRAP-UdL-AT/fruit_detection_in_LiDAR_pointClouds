function [CCwmtoa_K]=Split_predict(Split_technique,SVMModelCCwoa,SVMModelCCwmtoa,CCfeatures_nonFP,ptCloud_all_thresh60_notOutliers_xyz,class,Training_features)


CCwmtoa_K=zeros(size(CCfeatures_nonFP,1),1);


if Split_technique==3 %Technique 2 + if CCF(:,6)>(0.0012)||(CCF(:,2)>400&&CCF(:,15)<0.062) - > 3 apples + if CCF(:,6)>(0.0016) -> 4 apples
   CCwmtoa_K=CCwmtoa_K+(CCwmtoa_K>0).*((CCfeatures_nonFP(:,6)>0.0012)|((CCfeatures_nonFP(:,2)>400)&(CCfeatures_nonFP(:,15)<0.6)));    %3 apples
    CCwmtoa_K=CCwmtoa_K+(CCwmtoa_K>0).*(CCfeatures_nonFP(:,6)>0.0016);     %4 apples
end


if Split_technique==5 %SVM
        
    CCwmtoa_index=predict(SVMModelCCwoa,CCfeatures_nonFP(:,Training_features));
    CCwmtoa_K=zeros(size(CCwmtoa_index));
    CCwmtoa_K(CCwmtoa_index>0)=predict(SVMModelCCwmtoa,CCfeatures_nonFP(CCwmtoa_index,Training_features))+2;   
end