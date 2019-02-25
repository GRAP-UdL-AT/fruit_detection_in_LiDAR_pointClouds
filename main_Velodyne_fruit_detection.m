 clc
 clear
 

session=5;
directory='F:\Detecció Fruits 2017\velodyne_vent';
pcDirectory_txt=strcat(directory,'\data\TrainingData\');
Groundtruth_Directory=strcat(directory,'\data\AllTrees_Groundtruth\');
models_Directory=strcat(directory,'\data\Trained_models\');
save_directory=strcat(directory,'\results\');

Trees=ListFiles_txt(pcDirectory_txt);
    
save=0; %save detections
save_all=0; %save all detections (after each step)
show3D=0;
train=1; %1 to train, 0 for test.




%% Algorithm parameters:

thresh=60;
Th=0;
NumNeigh=20;
K=15;
Eps=0.03;

technique_FP=2; % 1: thresholding ; 2: SVM
Split_technique=5; %3: thresholding; 5: SVM

KernelFunctionFP='linear';
BoxConstrainFP=0.26;
StandardizeFP=true;
KernelFunctionCCwoa='linear';
BoxConstrainCCwoa=1;
StandardizeCCwoa=true;
KernelFunctionCCwmtoa='linear';
BoxConstrainCCwmtoa=1;
StandardizeCCwmtoa=true;

param_name={'thresh','Th','NumNeigh','K','Eps','technique_FP','Split_technique',...
        'KernelFunctionFP','BoxConstrainFP','StandardizeFP',...
        'KernelFunctionCCwoa','BoxConstrainCCwoa','StandardizeCCwoa',...
        'KernelFunctionCCwmtoa','BoxConstrainCCwmtoa','StandardizeCCwmtoa'};
params={thresh,Th,NumNeigh,K,Eps,technique_FP,Split_technique,...
        KernelFunctionFP,BoxConstrainFP,StandardizeFP,...
        KernelFunctionCCwoa,BoxConstrainCCwoa,StandardizeCCwoa,...
        KernelFunctionCCwmtoa,BoxConstrainCCwmtoa,StandardizeCCwmtoa};    

fid = fopen(strcat(save_directory,'results.xlsx'), 'a');
fclose('all');
while (fid == -1)
    errormsg = strcat('the file: ',save_directory,'results.xlsx', ' is open. please close it!');
    waitfor(msgbox(errormsg,'Error'));
    fid = fopen(strcat(save_directory,'results.xlsx'), 'a');
    fclose('all');
end    
xlswrite(strcat(save_directory,'results.xlsx'), param_name , strcat('Results_s',num2str(session)) , ['B1'] );
xlswrite(strcat(save_directory,'results.xlsx'), params , strcat('Results_s',num2str(session)) , ['B2'] );

for pcID=1:size(Trees,1)

    Trials={Trees(pcID).name(1:end-4)};
    disp(strcat('Inicio processado ',num2str(pcID),': ',Trees(pcID).name));

    train_modelFP=strcat('SVMModelFP_',Trials{:},'_s',num2str(session),'.mat'); %Trained model used for test. It must be at 'directory\Code\Trained_models'
    train_modelCCwoa=strcat('SVMModelCCwoa_',Trials{:},'_s',num2str(session),'.mat'); %Trained model used for test. It must be at 'directory\Code\Trained_models'
    train_modelCCwmtoa=strcat('SVMModelCCwmtoa_',Trials{:},'_s',num2str(session),'.mat'); %Trained model used for test. It must be at 'directory\Code\Trained_models'

    test_modelFP=strcat('SVMModelFP_',Trials{:},'_s',num2str(session),'.mat'); %Trained model used for test. It must be at 'directory\Code\Trained_models'
    test_modelCCwoa=strcat('SVMModelCCwoa_',Trials{:},'_s',num2str(session),'.mat'); %Trained model used for test. It must be at 'directory\Code\Trained_models'
    test_modelCCwmtoa=strcat('SVMModelCCwmtoa_',Trials{:},'_s',num2str(session),'.mat'); %Trained model used for test. It must be at 'directory\Code\Trained_models'



    %% Point cloud reading
    disp('Inicio Point cloud reading...')
    tic;
    [ptCloud_all,ptCloud_all_xyz]=pointCloudReading(Trials,pcDirectory_txt);
    t=toc; disp(strcat('    realizado en:__', num2str(toc), ' seg.'))

    %% Point cloud thresholding
    disp('Inicio Point cloud thresholding...')
    ptCloud_all_xyz_thresh60=ptCloud_all_xyz(ptCloud_all_xyz(:,4)>thresh,:);
    ptCloud_all_thresh60=pointCloud(ptCloud_all_xyz_thresh60(:,1:3));
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;


    %% Outliers removal
    disp('Inicio Outlier removal...')
    [ptCloud_all_thresh60_notOutliers,inlierIndices,~]=pcdenoise(ptCloud_all_thresh60,'NumNeighbors',NumNeigh,'Threshold',Th);
    ptCloud_all_thresh60_notOutliers_xyz=ptCloud_all_thresh60_notOutliers.Location;
    ptCloud_all_thresh60_notOutliers_xyz(:,4:5)=ptCloud_all_xyz_thresh60(inlierIndices,[4 6]);
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;


    %% Clustering dbscan
    disp('Inicio Clustering dbscan...')
    [class,type] = dbscan(ptCloud_all_thresh60_notOutliers_xyz(:,1:3), K, Eps);
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;
    class_dbscan=class;



    %% CC feature extraction
    disp('Inicio feature extraction...')
    CCfeatures=CCfeatureExtraction(ptCloud_all_thresh60_notOutliers_xyz,class,Groundtruth_Directory,Trials);
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;

    %% Training ClusterSplit and FP rmoval
    disp('Inicio Training...')
    if train
        if ~exist(models_Directory, 'dir')        
           mkdir(models_Directory);
        end  
        trainingCCwmtoaFP(CCfeatures,Trials,StandardizeFP,KernelFunctionFP,BoxConstrainFP,StandardizeCCwoa,KernelFunctionCCwoa,BoxConstrainCCwoa,StandardizeCCwmtoa,KernelFunctionCCwmtoa,BoxConstrainCCwmtoa,models_Directory,train_modelFP,train_modelCCwoa,train_modelCCwmtoa);
    end
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))


         CCfeatures_nonFP=CCfeatures;


    %% CCwmtoa split
    disp('Inicio CCwmtoa split...')


    [CCwmtoa_K]=Split_predict(Split_technique,test_modelCCwoa,test_modelCCwmtoa,CCfeatures_nonFP,ptCloud_all_thresh60_notOutliers_xyz,class,models_Directory);

    class=CC_split(CCwmtoa_K,ptCloud_all_thresh60_notOutliers_xyz,class);
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;


    %% CC feature extraction
    disp('Inicio feature extraction...')
    CCfeatures_splited=CCfeatureExtraction(ptCloud_all_thresh60_notOutliers_xyz,class,Groundtruth_Directory,Trials);
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;

    %% FP rmoval

    if technique_FP
        [class,CCfeatures_splited_nonFP]=FP_removal(directory,test_modelFP,CCfeatures_splited,class,technique_FP,models_Directory);
    else
        CCfeatures_splited_nonFP=CCfeatures_splited;
    end

    t=toc;
    disp(strcat('Procesado realizado en:__', num2str(toc), ' seg.'))

    %% Detection assesment


        disp(strcat('Inicio Detection assesment technique',num2str(Split_technique),'...'))
        tree_index=(class'>0);
        apple_detectionsPC=pointCloud(ptCloud_all_thresh60_notOutliers_xyz(tree_index,1:3));
        LCM=LabelClusterMatrix(apple_detectionsPC,Groundtruth_Directory,Trials,class(tree_index));
        [LCM_LOC,LCM_LOC_COL]=ClusterLabelAssignment(LCM);

        [T,P,ClustersinLabel,LabelsDetected,...
            TP,FP_LOC_COL,FP,Localization_success_C,...
            Localization_success_L,FDR_LOC_COL,FDR,precision,...
            recall,F1]=detection_assesment(LCM,LCM_LOC_COL);
        disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
        t=toc;
        results={Trees(pcID).name,T,LabelsDetected,FP,Localization_success_L,FDR,...
                TP,FP_LOC_COL,recall,FDR_LOC_COL,F1,toc,precision};
            
        fid = fopen(strcat(save_directory,'results.xlsx'), 'a');
        fclose('all');
        while (fid == -1)
            errormsg = strcat('the file: ',save_directory,'results.xlsx', ' is open. please close it!');
            waitfor(msgbox(errormsg,'Error'));
            fid = fopen(strcat(save_directory,'results.xlsx'), 'a');
            fclose('all');
        end    
        xlswrite(strcat(save_directory,'results.xlsx'), results , strcat('Results_s',num2str(session)) , ['B' num2str(pcID+4) ] );
        
        
        treeID=str2num(Trees(pcID).name(5:6));
        if min(Trees(pcID).name(end-8:end)=='E1_SV.txt')
            trailID=1;
        elseif   min(Trees(pcID).name(end-7:end)=='E1_V.txt')
            trailID=2;
        elseif   min(Trees(pcID).name(end-8:end)=='E1_VF.txt')
            trailID=3;       
        elseif   min(Trees(pcID).name(end-8:end)=='E2_SV.txt')
            trailID=4;
        elseif   min(Trees(pcID).name(end-7:end)=='E2_V.txt')
            trailID=5;
        elseif   min(Trees(pcID).name(end-8:end)=='E2_VF.txt')
            trailID=6;            
        elseif   min(Trees(pcID).name(end-9:end)=='E12_SV.txt')
            trailID=7;            
        elseif   min(Trees(pcID).name(end-8:end)=='E12_V.txt')
            trailID=8;            
        elseif   min(Trees(pcID).name(end-9:end)=='E12_VF.txt')
            trailID=9;   
        end
        
        allLocalization_success_L(treeID,trailID)=Localization_success_L;
        allFDR(treeID,trailID)=FDR;
        allrecall(treeID,trailID)=recall;
        allFDR_LOC_COL(treeID,trailID)=FDR_LOC_COL;
        allF1(treeID,trailID)=F1;
        allprecision(treeID,trailID)=precision;
            



    %% Save_clusters
    if save
        disp('Inicio Save...')
        if save_all
            if ~exist(strcat(save_directory,'dets_s',num2str(session)), 'dir')        
               mkdir(strcat(save_directory,'dets_s',num2str(session)));
            end  
    
            %Saving after thresholding
            dlmwrite(strcat(save_directory,'dets_s',num2str(session),'\',[Trials{:}],'_thresh_',num2str(thresh),'.txt'),ptCloud_all_xyz_thresh60,'precision','%.3f','delimiter','\t')
            %Saving after outlier_removal
            dlmwrite(strcat(save_directory,'dets_s',num2str(session),'\',[Trials{:}],'_thresh_',num2str(thresh),'denoise_Th_',num2str(Th),'NumNeigh_',num2str(NumNeigh),'.txt'),ptCloud_all_thresh60_notOutliers_xyz,'precision','%.3f','delimiter','\t')
    
    
            %Saving after dbscan
            color_class=colormap(lines(max(class_dbscan)));
            if ~exist(strcat(save_directory,'dets_s',num2str(session),'\dets_dbscan',Trials{:}), 'dir')        
               mkdir(strcat(save_directory,'dets_s',num2str(session),'\dets_dbscan',Trials{:}));
            end  
            for i=1:max(class_dbscan)
                CCxyz=ptCloud_all_thresh60_notOutliers_xyz(class_dbscan==i,1:4);
                CCi=[CCxyz,repmat(color_class(i,:)*255,size(CCxyz,1),1)];
                dlmwrite(strcat(save_directory,'dets_s',num2str(session),'\dets_dbscan',Trials{:},'\det_dbscan',[Trials{:}],'_s',num2str(session),'_',num2str(i,'%03.f'),'.txt'),CCi,'precision','%.3f','delimiter','\t')
            end
        end

        if ~exist(strcat(save_directory,'dets_s',num2str(session),'\dets',Trials{:}), 'dir')        
           mkdir(strcat(save_directory,'dets_s',num2str(session),'\dets',Trials{:}));
        end 
        
        color_class=colormap(lines(max(class)));
        for i=1:max(class)
            CCxyz=ptCloud_all_thresh60_notOutliers_xyz(class==i,1:4);
            CCi=[CCxyz,repmat(color_class(i,:)*255,size(CCxyz,1),1)];
            dlmwrite(strcat(save_directory,'dets_s',num2str(session),'\dets',Trials{:},'\det',[Trials{:}],'_s',num2str(session),'_',num2str(i,'%03.f'),'.txt'),CCi,'precision','%.3f','delimiter','\t')
        end
        disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
        t=toc;
    end

    %% plots
    if show3D
        figure;
        pcshow(ptCloud_all_xyz(:,1:3),ptCloud_all_xyz(:,4)/100)
        title('ptCloud\_all');
        colormap jet

        figure;
        pcshow(ptCloud_all_xyz_thresh60(:,1:3),ptCloud_all_xyz_thresh60(:,4)/100)
        title('ptCloud\_all\_thresh');
        colormap jet

        figure;
        pcshow(ptCloud_all_thresh60_notOutliers_xyz(:,1:3),ptCloud_all_thresh60_notOutliers_xyz(:,4)/100)
        title('ptCloud\_all\_thresh\_notoutliers');
        colormap jet

        figure;
        pcshow(ptCloud_all_thresh60_notOutliers_xyz(class>0,1:3),class(class>0))
        title('ptCloud\_all\_thresh\_notoutliers\_CC');
        colormap lines

        %Features 2D
        colors='gbmkr';
        markers= 'sd*x+';
        feature_pair=[2 6 ; 2 17 ; 2 15 ; 6 17 ; 6 15 ; 17 15];
        feature_pair_label={'Nº of Points','Cluster Volume [m^3]';...
                            'Nº of Points','Mean reflectance [%]';...
                            'Nº of Points','\Psi';...
                            'Cluster Volume [m^3]','Mean reflectance [%]';...
                            'Cluster Volume [m^3]','\Psi';...
                            'Mean reflectance [%]','\Psi'};

        for j=1:size(feature_pair,1)
            figure; 

            plot(CCfeatures(CCfeatures(:,1)==1,feature_pair(j,1)),CCfeatures(CCfeatures(:,1)==1,feature_pair(j,2)), [colors(1) markers(1)]);
            hold on;        
            plot(CCfeatures(CCfeatures(:,1)==2,feature_pair(j,1)),CCfeatures(CCfeatures(:,1)==2,feature_pair(j,2)), [colors(2) markers(2)]);
            hold on;        
            plot(CCfeatures(CCfeatures(:,1)==3,feature_pair(j,1)),CCfeatures(CCfeatures(:,1)==3,feature_pair(j,2)), [colors(3) markers(3)]);
            hold on;        
            plot(CCfeatures(CCfeatures(:,1)>3,feature_pair(j,1)),CCfeatures(CCfeatures(:,1)>3,feature_pair(j,2)), [colors(4) markers(4)]);

            legend('K = 1','K = 2','K = 3','K \geq 4');
            title(strcat('Clusters features ','Eps:__', num2str(Eps),'NumNeigh:__', num2str(NumNeigh),'Th:__', num2str(Th)));
            xlabel(feature_pair_label{j,1})
            ylabel(feature_pair_label{j,2})
        end

        %Features splited 2D
        colors='rb';
        markers= 'xo';
        feature_pair=[17 6 ; 15 6 ; 17 15];
        feature_pair_label={'Mean reflectance [%]','Cluster Volume [m^3]';...
                            '\Psi','Cluster Volume [m^3]';...
                            'Mean reflectance [%]','\Psi'};

        for j=1:size(feature_pair,1)
            figure; 
            plot(CCfeatures_splited(CCfeatures_splited(:,1)==0,feature_pair(j,1)),CCfeatures_splited(CCfeatures_splited(:,1)==0,feature_pair(j,2)), [colors(1) markers(1)]);
            hold on;      
            plot(CCfeatures_splited(CCfeatures_splited(:,1)>0,feature_pair(j,1)),CCfeatures_splited(CCfeatures_splited(:,1)>0,feature_pair(j,2)), [colors(2) markers(2)]);
            legend('False Positive','True Positive');
            %title(strcat('Clusters features ','Eps:__', num2str(Eps),'NumNeigh:__', num2str(NumNeigh),'Th:__', num2str(Th)));
            xlabel(feature_pair_label{j,1})
            ylabel(feature_pair_label{j,2})
        end    
        line([65.25 65.25],[0.4 1],'color','black');
        h=legend('False Positive','True Positive','$$V_{th\_FP}$$','$$\psi_{th\_FP}$$');
        set(h,'Interpreter','latex')

        %Features 3D
        colors='rgbmkc';
        markers= 'osd*x+';
        figure;    
        for i=0:max(CCfeatures(:,1))
            plot3(CCfeatures(CCfeatures(:,1)==i,2),CCfeatures(CCfeatures(:,1)==i,6),CCfeatures(CCfeatures(:,1)==i,15), [colors(i+1) markers(i+1)]);
            hold on;        
        end
        legend('0','1','2','3','4','5');
        title(strcat('Clusters features ','Eps:__', num2str(Eps),'NumNeigh:__', num2str(NumNeigh),'Th:__', num2str(Th)));
        xlabel('Nº of Points')
        ylabel('Cluster Volume')
        zlabel('Eigenvalues parameter')

        figure;    
        for i=0:max(CCfeatures(:,1))
            plot3(CCfeatures(CCfeatures(:,1)==i,2),CCfeatures(CCfeatures(:,1)==i,17),CCfeatures(CCfeatures(:,1)==i,15), [colors(i+1) markers(i+1)]);
            hold on;        
        end
        legend('0','1','2','3','4','5');
        title(strcat('Clusters features ','Eps:__', num2str(Eps),'NumNeigh:__', num2str(NumNeigh),'Th:__', num2str(Th)));
        xlabel('Nº of Points')
        ylabel('Mean reflectivity')
        zlabel('Eigenvalues parameter')


        %Features splited
            colors='rgbmkc';
        markers= 'osd*x+';
        figure;    
        for i=0:max(CCfeatures_splited(:,1))
            plot3(CCfeatures_splited(CCfeatures_splited(:,1)==i,2),CCfeatures_splited(CCfeatures_splited(:,1)==i,6),CCfeatures_splited(CCfeatures_splited(:,1)==i,15), [colors(i+1) markers(i+1)]);
            hold on;        
        end
        legend('0','1','2','3','4','5');
        title(strcat('Clusters features splited ','Eps:__', num2str(Eps),'NumNeigh:__', num2str(NumNeigh),'Th:__', num2str(Th)));
        xlabel('Nº of Points')
        ylabel('Cluster Volume')
        zlabel('Eigenvalues parameter')

            figure;    
        for i=0:max(CCfeatures_splited(:,1))
            plot3(CCfeatures_splited(CCfeatures_splited(:,1)==i,2),CCfeatures_splited(CCfeatures_splited(:,1)==i,17),CCfeatures_splited(CCfeatures_splited(:,1)==i,15), [colors(i+1) markers(i+1)]);
            hold on;        
        end
        legend('0','1','2','3','4','5');
        title(strcat('Clusters features splited ','Eps:__', num2str(Eps),'NumNeigh:__', num2str(NumNeigh),'Th:__', num2str(Th)));
        xlabel('Nº of Points')
        ylabel('Mean reflectivity')
        zlabel('Eigenvalues parameter')

        %Features nonFP
                colors='rgbmkc';
        markers= 'osd*x+';
        figure;    
        for i=0:max(CCfeatures_splited_nonFP(:,1))
            plot3(CCfeatures_splited_nonFP(CCfeatures_splited_nonFP(:,1)==i,2),CCfeatures_splited_nonFP(CCfeatures_splited_nonFP(:,1)==i,6),CCfeatures_splited_nonFP(CCfeatures_splited_nonFP(:,1)==i,15), [colors(i+1) markers(i+1)]);
            hold on;        
        end
        legend('0','1','2','3','4','5');
        title(strcat('Clusters features nonFP ','Eps:__', num2str(Eps),'NumNeigh:__', num2str(NumNeigh),'Th:__', num2str(Th)));
        xlabel('Nº of Points')
        ylabel('Cluster Volume')
        zlabel('Eigenvalues parameter')

            figure;    
        for i=0:max(CCfeatures_splited_nonFP(:,1))
            plot3(CCfeatures_splited_nonFP(CCfeatures_splited_nonFP(:,1)==i,2),CCfeatures_splited_nonFP(CCfeatures_splited_nonFP(:,1)==i,17),CCfeatures_splited_nonFP(CCfeatures_splited_nonFP(:,1)==i,15), [colors(i+1) markers(i+1)]);
            hold on;        
        end
        legend('0','1','2','3','4','5');
        title(strcat('Clusters features splited ','Eps:__', num2str(Eps),'NumNeigh:__', num2str(NumNeigh),'Th:__', num2str(Th)));
        xlabel('Nº of Points')
        ylabel('Mean reflectivity')
        zlabel('Eigenvalues parameter')


        %Depth distribution histogram
    rng 'default'
    edges = -0.7:0.1:0.7;
    center_of_labels=GroundTruthCenters(strcat(Groundtruth_Directory,Trials{:}));
    h1=histcounts(center_of_labels(sum(LCM_LOC_COL,2)==1,1)-336312,edges);
    h2=histcounts(center_of_labels(:,1)-336312,edges);
    h=h1./h2;
    h(isnan(h))=0;
    figure
    yyaxis left
    bar(edges(1:end-1),[h1; h2]')
    yyaxis right
    plot(edges(1:end-1),h*100)

    legend('TP','GroundTruth')
    title('Depth distribution histogram');

    %Height distribution histogram
    rng 'default'
    edges = 0:0.2:3.5;
    center_of_labels=GroundTruthCenters(strcat(Groundtruth_Directory,Trials{:}));
    Dist_z_min=min(center_of_labels(:,3));
    h1=histcounts(center_of_labels(sum(LCM_LOC_COL,2)==1,3)-Dist_z_min+0.2,edges);
    h2=histcounts(center_of_labels(:,3)-Dist_z_min+0.2,edges);
    h=h1./h2;
    h(isnan(h))=0;
    figure
    yyaxis left
    bar(edges(1:end-1),[h1; h2]')
    yyaxis right
    plot(edges(1:end-1),h*100)
    legend('TP','GroundTruth')
    title('Height distribution histogram');

    end

    %%
    disp(strcat('Final processado. Tiempo total procesado:__', num2str(toc), ' seg.'))
    t=toc;

end

figure;
bar(allLocalization_success_L);
title(strcat('Localization\_success\_s',num2str(session)));
figure;
bar(allFDR);
title(strcat('Localization\_FDR\_s',num2str(session)));
figure;
bar(allrecall);
title(strcat('Identification\_success or Recall\_s',num2str(session)));
figure;
bar(allFDR_LOC_COL);
title(strcat('Identification\_FDR\_s',num2str(session)));
figure;
bar(allF1);
title(strcat('F1\_s',num2str(session)));
figure;
bar(allprecision);
title(strcat('precision\_s',num2str(session)));

