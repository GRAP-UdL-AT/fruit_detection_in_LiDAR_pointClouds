function [SVMModelFP,SVMModelCCwoa,SVMModelCCwmtoa]=trainingCCwmtoaFP(CCfeatures,trial,Training_features,...
                            StandardizeFP,KernelFunctionFP,BoxConstrainFP,...
                            StandardizeCCwoa,KernelFunctionCCwoa,BoxConstrainCCwoa,...
                            StandardizeCCwmtoa,KernelFunctionCCwmtoa,BoxConstrainCCwmtoa,models_Directory,session)


%% Training SVM FP
disp(strcat('    FP training (Standardize: ',num2str(StandardizeFP),' - Kernel: ',KernelFunctionFP,' - BoxConstrain: ',num2str(BoxConstrainFP),')'))
t=toc;
X=CCfeatures(:,Training_features);
Y=(CCfeatures(:,1)>0);
if size(unique(Y),1)==1
    BoxConstrainFP=1;
end
SVMModelFP = fitcsvm(X,Y,'Standardize',StandardizeFP,'KernelFunction',KernelFunctionFP,'BoxConstrain',BoxConstrainFP);
disp(strcat('        realizado en:__', num2str(toc-t), ' seg.'))
t=toc;

%% Training SVM CCwoa
if BoxConstrainCCwoa>0
    disp(strcat('    CCwoa training (Standardize: ',num2str(StandardizeCCwoa),' - Kernel: ',KernelFunctionCCwoa,' - BoxConstrain: ',num2str(BoxConstrainCCwoa),')'))
    X=CCfeatures(CCfeatures(:,1)>0,Training_features);
    Y=(CCfeatures(CCfeatures(:,1)>0,1)>1);
    if size(unique(Y),1)==1
        BoxConstrainCCwoa=1;
    end
    SVMModelCCwoa = fitcsvm(X,Y,'Standardize',StandardizeCCwoa,'KernelFunction',KernelFunctionCCwoa,'BoxConstrain',BoxConstrainCCwoa);
%     saveCompactModel(SVMModelCCwoa,strcat(models_Directory,'SVMModelCCwoa_',trial(1:end-4),'_s',num2str(session),'.mat'));
    disp(strcat('        realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;
else
    SVMModelCCwoa=[];
end

%% Training SVM CCwmtoa
if BoxConstrainCCwmtoa>0
    disp(strcat('    CCwmtoa training (Standardize: ',num2str(StandardizeCCwmtoa),' - Kernel: ',KernelFunctionCCwmtoa,' - BoxConstrain: ',num2str(BoxConstrainCCwmtoa),')'))
    X=CCfeatures(CCfeatures(:,1)>1,Training_features);
    Y=(CCfeatures(CCfeatures(:,1)>1,1)>2);
    if size(unique(Y),1)==1
        BoxConstrainCCwmtoa=1;
    end
    SVMModelCCwmtoa = fitcsvm(X,Y,'Standardize',StandardizeCCwmtoa,'KernelFunction',KernelFunctionCCwmtoa,'BoxConstrain',BoxConstrainCCwmtoa);
%     saveCompactModel(SVMModelCCwmtoa,strcat(models_Directory,'SVMModelCCwmtoa_',trial(1:end-4),'_s',num2str(session),'.mat'));
    disp(strcat('        realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;
else
    SVMModelCCwmtoa=[];
end





