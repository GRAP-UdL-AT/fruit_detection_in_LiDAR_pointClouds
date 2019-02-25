function [class,CCfeatures_nonFP]=FP_removal(SVMModelFP,CCfeatures,class,technique_FP,Training_features,trial)

    disp(strcat('Inicio FP removal ',trial,'...'))
    t=toc;
    CCfeatures_nonFP=CCfeatures;
    T=sum(CCfeatures(:,1)==0);
    TP=0;
    FP=0;
if technique_FP==1
    i=1;
    while (i<=max(class))
        if (CCfeatures_nonFP(i,2)<70 && CCfeatures_nonFP(i,17)<65.25)||CCfeatures_nonFP(i,6)>0.001||CCfeatures_nonFP(i,15)<0.46
            TP=TP+1-(CCfeatures_nonFP(i,1)>0);
            FP=FP+1-(CCfeatures_nonFP(i,1)==0);
            class(class==i)=-1;
           class(class>i)=class(class>i)-1;
            CCfeatures_nonFP(i,:)=[];
            i=i-1;
        end
        i=i+1;
    end
end    
    
    
if technique_FP==2
    i=1;
    while (i<=max(class))
        FPprediction=predict(SVMModelFP,CCfeatures_nonFP(i,Training_features));
        if ~FPprediction
            TP=TP+1-(CCfeatures_nonFP(i,1)>0);
            FP=FP+1-(CCfeatures_nonFP(i,1)==0);
            class(class==i)=-1;
           class(class>i)=class(class>i)-1;
            CCfeatures_nonFP(i,:)=[];
            i=i-1;
        end
        i=i+1;
    end
end
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg. __  De_',num2str(T),'_FP se han eliminado_',num2str(TP),' correctamente i_',num2str(FP),' incorrectamente'))
    