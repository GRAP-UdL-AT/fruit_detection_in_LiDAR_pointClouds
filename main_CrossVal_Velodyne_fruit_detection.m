 clc
 clear
 
session=35;
directory='F:\Detecció Fruits 2017\velodyne_vent';
pcDirectory_txt=strcat(directory,'\data\AllTrees_pcloud\');
Groundtruth_Directory=strcat(directory,'\data\AllTrees_Groundtruth\');
models_Directory=strcat(directory,'\data\Trained_models\');
pcTreatDirectory=strcat(directory,'\data\Treated_pcloud\');
save_directory=strcat(directory,'\results\');

%Trials2eval={'E1_SV','E1_V','E1_VF','E2_SV','E2_V','E2_VF','E12_SV','E12_V','E12_VF'}; %E1_SV: Ensayo1 sin viento; E2_V:Ensayo 2 con viento; E12_VF: Ensayo 1+2 viento flojo.
%Trials2eval={'E1_SV','E1_VF','E1_V','E1_SV_VF','E1_SV_V','E1_SV_VF_V','E2_SV','E2_VF','E2_V','E2_SV_VF','E2_SV_V','E2_SV_VF_V','E12_SV','E12_VF','E12_V','E12_SV_VF','E12_SV_V','E12_SV_VF_V',...
%             'E1_SV_E','E1_VF_E','E1_V_E','E1_SV_VF_E','E1_SV_V_E','E1_SV_VF_V_E','E2_SV_E','E2_VF_E','E2_V_E','E2_SV_VF_E','E2_SV_V_E','E2_SV_VF_V_E','E12_SV_E','E12_VF_E','E12_V_E','E12_SV_VF_E','E12_SV_V_E','E12_SV_VF_V_E',...
%             'E1_SV_O','E1_VF_O','E1_V_O','E1_SV_VF_O','E1_SV_V_O','E1_SV_VF_V_O','E2_SV_O','E2_VF_O','E2_V_O','E2_SV_VF_O','E2_SV_V_O','E2_SV_VF_V_O','E12_SV_O','E12_VF_O','E12_V_O','E12_SV_VF_O','E12_SV_V_O','E12_SV_VF_V_O'};
%Trials2eval={'E1_SV','E1_SV_V','E1_SV_VF_V','E2_SV','E2_SV_V','E2_SV_VF_V'};
%Trials2eval={'E1_SV','E2_SV','E12_SV'};
%Trials2eval={'E1_SV'};
Trials2eval={'E1_SV','E1_SV_E','E1_SV_O'};
%Late_fusion_comb={[1,4],[2,5],[3,6],[1,2,4,5],[1,3,4,6],[1,2,3,4,5,6]}; %Trials2eval combinations that are want to be fused using late fusion.
Late_fusion_comb={};
[Trials , Trials2eval]= ListFiles_trial(pcDirectory_txt,Trials2eval,Late_fusion_comb);
    
save_dets=0; %save detections
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

%Training_features:
%2: nº of Points; 3-5: XYZ dimensions; 6: Volume using boundary points
%7-9: Principal values; 10-14: Intensity histogram from 60:8:100; 
%15: Geometrical parameter; 16: Bounding box in catesian coordinates; 
%17: Mean intensity; 18: max intensity; 19: Intensity standard distribution
Training_features=[2,6,7,8,9,10,11,12,13,14,15,17,18,19];  
%Training_features=[6,10,11,12,13,14,15,7,8,9];  

KernelFunctionFP='linear';
BoxConstrainFP=0.35;
StandardizeFP=true;
KernelFunctionCCwoa='linear';
BoxConstrainCCwoa=0.35;
StandardizeCCwoa=true;
KernelFunctionCCwmtoa='linear';
BoxConstrainCCwmtoa=0.35;
StandardizeCCwmtoa=true;

param_name={'Trials','thresh','Th','NumNeigh','K','Eps','technique_FP','Split_technique',...
        'KernelFunctionFP','BoxConstrainFP','StandardizeFP',...
        'KernelFunctionCCwoa','BoxConstrainCCwoa','StandardizeCCwoa',...
        'KernelFunctionCCwmtoa','BoxConstrainCCwmtoa','StandardizeCCwmtoa'};
params={strcat(Trials2eval{:}),thresh,Th,NumNeigh,K,Eps,technique_FP,Split_technique,...
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



%% Pre-processing: Thresholding + DbSCAN
if ~exist(pcTreatDirectory, 'dir')        
   mkdir(pcTreatDirectory);
end  
tic;
for trialID=1:size(Trials,2)
    for treeID=1:size(Trials(trialID).trees,2)
        if exist(strcat(pcTreatDirectory,Trials(trialID).trees(treeID).treeID,'_',Trials2eval{trialID},'_treated_s',num2str(session),'.mat'),'file')
            disp(strcat('Loading pre-procesado: ',Trials(trialID).trees(treeID).file));
            t=toc;
            load(strcat(pcTreatDirectory,Trials(trialID).trees(treeID).treeID,'_',Trials2eval{trialID},'_treated_s',num2str(session),'.mat'));
            Trials(trialID).trees(treeID).ptCloud_th=ptCloud_th;
            Trials(trialID).trees(treeID).class=class;
            Trials(trialID).trees(treeID).CCfeatures=CCfeatures;    
            disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
            t=toc;
        elseif strcmp(Trials(trialID).trees(treeID).file(1:4),'late')
            ptCloud_all_xyz=[];
            for fuseID=Trials(trialID).trees(treeID).fuseTrials
                load(strcat(pcTreatDirectory,Trials(fuseID).trees(treeID).file(1:end-4),'_treated_s',num2str(session),'.mat'));
                ptCloud_all_xyz=[ptCloud_all_xyz; ptCloud_th];
            end
            ptCloud_th=ptCloud_all_xyz;
            %% Clustering dbscan
            disp('Inicio Clustering dbscan...')
            [class,type] = dbscan(ptCloud_th(:,1:3), K, Eps);
            disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
            t=toc;


            %% CC feature extraction
            disp('Inicio feature extraction...')
            CCfeatures=CCfeatureExtraction(ptCloud_th,class,Groundtruth_Directory,{Trials(trialID).trees(treeID).treeID});
            disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
            t=toc;
            
            Trials(trialID).trees(treeID).ptCloud_th=ptCloud_th;
            Trials(trialID).trees(treeID).class=class;
            Trials(trialID).trees(treeID).CCfeatures=CCfeatures;
            save(strcat(pcTreatDirectory,Trials(trialID).trees(treeID).treeID,'_',Trials2eval{trialID},'_treated_s',num2str(session),'.mat'),'ptCloud_th','class','CCfeatures');
            
        else

            disp(strcat('Inicio pre-procesado: ',Trials(trialID).trees(treeID).file));


            %% Point cloud reading
            disp('Inicio Point cloud reading...')
            tic;
%             if ~strcmp(Trials(trialID).trees(treeID).file(1:4),'late')
                [~,ptCloud_all_xyz]=pointCloudReading({Trials(trialID).trees(treeID).file(1:end-4)},pcDirectory_txt);
                t=toc; disp(strcat('    realizado en:__', num2str(toc), ' seg.'))
%             else
%                 ptCloud_all_xyz=[];
% 
%                 for fuseID=Trials(trialID).trees(treeID).fuseTrials
%                     fileID=fopen(strcat(save_directory,'dets_s',num2str(session),'\dets',Trials(fuseID).trees(treeID).file(1:end-4),...
%                                     '\all_det',Trials(fuseID).trees(treeID).file(1:end-4),'_s',num2str(session),'.txt'),'r');
%                     ptCloud_xyz=fscanf(fileID,'%f %f %f %f %f %f %f',[7 Inf])';
%                     fclose(fileID);
%                     ptCloud_all_xyz=[ptCloud_all_xyz;ptCloud_xyz(:,1:4)];
%                 end
%                 ptCloud_all_xyz(:,5:6)=ones([size(ptCloud_all_xyz,1) 2]);
%             end

            %% Point cloud thresholding
            disp('Inicio Point cloud thresholding...')
            ptCloud_all_xyz_thresh60=ptCloud_all_xyz(ptCloud_all_xyz(:,4)>thresh,:);
            ptCloud_all_thresh60=pointCloud(ptCloud_all_xyz_thresh60(:,1:3));
            disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
            t=toc;


            %% Outliers removal
            disp('Inicio Outlier removal...')
            [ptCloud_all_thresh60_notOutliers,inlierIndices,~]=pcdenoise(ptCloud_all_thresh60,'NumNeighbors',NumNeigh,'Threshold',Th);
            ptCloud_th=ptCloud_all_thresh60_notOutliers.Location;
            ptCloud_th(:,4:5)=ptCloud_all_xyz_thresh60(inlierIndices,[4 6]);
            disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
            t=toc;


            %% Clustering dbscan
            disp('Inicio Clustering dbscan...')
            [class,type] = dbscan(ptCloud_th(:,1:3), K, Eps);
            disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
            t=toc;


            %% CC feature extraction
            disp('Inicio feature extraction...')
            CCfeatures=CCfeatureExtraction(ptCloud_th,class,Groundtruth_Directory,{Trials(trialID).trees(treeID).treeID});
            disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
            t=toc;
            
            Trials(trialID).trees(treeID).ptCloud_th=ptCloud_th;
            Trials(trialID).trees(treeID).class=class;
            Trials(trialID).trees(treeID).CCfeatures=CCfeatures;
%             if ~strcmp(Trials(trialID).trees(treeID).file(1:4),'late')
                save(strcat(pcTreatDirectory,Trials(trialID).trees(treeID).file(1:end-4),'_treated_s',num2str(session),'.mat'),'ptCloud_th','class','CCfeatures');
%             end
        end
    end
end



    %% Training and loading models for ClusterSplit and FP rmoval

if train
    disp('Inicio Training...')
    if ~exist(models_Directory, 'dir')        
       mkdir(models_Directory);
    end  
    
    for trialID=1:size(Trials,2)
        for treeID=1:size(Trials(trialID).trees,2)
            treeID_comp=(1:size(Trials(trialID).trees,2));
            treeID_comp(treeID_comp==treeID)=[];
            CCfeatures_comp=[];
            for Te=treeID_comp
                CCfeatures_comp=[CCfeatures_comp ; Trials(trialID).trees(Te).CCfeatures];
            end
            Trials(trialID).trees(treeID).CCfeatures_comp=CCfeatures_comp;
            [Trials(trialID).trees(treeID).SVMModelFP,Trials(trialID).trees(treeID).SVMModelCCwoa,Trials(trialID).trees(treeID).SVMModelCCwmtoa]=trainingCCwmtoaFP(...
                            CCfeatures_comp,Trials(trialID).trees(treeID).file,Training_features,...
                            StandardizeFP,KernelFunctionFP,BoxConstrainFP,...
                            StandardizeCCwoa,KernelFunctionCCwoa,BoxConstrainCCwoa,...
                            StandardizeCCwmtoa,KernelFunctionCCwmtoa,BoxConstrainCCwmtoa,models_Directory,session);
        end
    end
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;
else
    disp('Inicio Loading models...')
    for trialID=1:size(Trials,2)
        for treeID=1:size(Trials(trialID).trees,2)
            Trials(trialID).trees(treeID).SVMModelFP=loadCompactModel(strcat(models_Directory,'SVMModelFP_',...
                                                                    Trials(trialID).trees(treeID).file(1:end-4),'_s',...
                                                                    num2str(session),'.mat'));
            Trials(trialID).trees(treeID).SVMModelCCwoa=loadCompactModel(strcat(models_Directory,'SVMModelCCwoa_',...
                                                                    Trials(trialID).trees(treeID).file(1:end-4),'_s',...
                                                                    num2str(session),'.mat'));
            Trials(trialID).trees(treeID).SVMModelCCwmtoa=loadCompactModel(strcat(models_Directory,'SVMModelCCwmtoa_',...
                                                                    Trials(trialID).trees(treeID).file(1:end-4),'_s',...
                                                                    num2str(session),'.mat'));
        end
    end
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;
end



    %% FP rmoval
% 
% if technique_FP
%     disp('Inicio FP removal...')
%     for trialID=1:size(Trials,2)
%         for treeID=1:size(Trials(trialID).trees,2)
%             [Trials(trialID).trees(treeID).class,Trials(trialID).trees(treeID).CCfeatures_nonFP]=FP_removal(Trials(trialID).trees(treeID).SVMModelFP,...
%                                                                                           Trials(trialID).trees(treeID).CCfeatures,...
%                                                                                           Trials(trialID).trees(treeID).class,...
%                                                                                           technique_FP,Training_features,...
%                                                                                           Trials(trialID).trees(treeID).file(1:end-4));
%         end
%     end
%     disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
%     t=toc;
% else
    for trialID=1:size(Trials,2)
        for treeID=1:size(Trials(trialID).trees,2)
            Trials(trialID).trees(treeID).CCfeatures_nonFP=Trials(trialID).trees(treeID).CCfeatures;
        end
    end
% end

t=toc;

    %% CCwmtoa split
    disp('Inicio CCwmtoa split...')
for trialID=1:size(Trials,2)
    for treeID=1:size(Trials(trialID).trees,2)
%         [CCwmtoa_K]=Split_predict(Split_technique,Trials(trialID).trees(treeID).SVMModelCCwoa,...
%                                   Trials(trialID).trees(treeID).SVMModelCCwmtoa,...
%                                   Trials(trialID).trees(treeID).CCfeatures_nonFP,...
%                                   Trials(trialID).trees(treeID).ptCloud_th,...
%                                   Trials(trialID).trees(treeID).class,Training_features);
        [CCwmtoa_K]=Split_predict(Split_technique,Trials(1).trees(treeID).SVMModelCCwoa,...
                                  Trials(1).trees(treeID).SVMModelCCwmtoa,...
                                  Trials(trialID).trees(treeID).CCfeatures_nonFP,...
                                  Trials(trialID).trees(treeID).ptCloud_th,...
                                  Trials(trialID).trees(treeID).class,Training_features);


        Trials(trialID).trees(treeID).class=CC_split(CCwmtoa_K,Trials(trialID).trees(treeID).ptCloud_th,Trials(trialID).trees(treeID).class);
    end
end

    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;


    %% CC feature extraction
    %%%%%AQUÍ
for trialID=1:size(Trials,2)
    for treeID=1:size(Trials(trialID).trees,2)    
    disp('Inicio feature extraction...')
    Trials(trialID).trees(treeID).CCfeatures_splited=CCfeatureExtraction(Trials(trialID).trees(treeID).ptCloud_th,Trials(trialID).trees(treeID).class,Groundtruth_Directory,{Trials(trialID).trees(treeID).treeID});
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;
    end
end


    %% Training and loading models splitted FP rmoval

if train
    
    for trialID=1:size(Trials,2)
        for treeID=1:size(Trials(trialID).trees,2)
            treeID_comp=(1:size(Trials(trialID).trees,2));
            treeID_comp(treeID_comp==treeID)=[];
            CCfeatures_comp=[];
            for Te=treeID_comp
                CCfeatures_comp=[CCfeatures_comp ; Trials(trialID).trees(Te).CCfeatures_splited];
            end
            Trials(trialID).trees(treeID).CCfeatures_comp=CCfeatures_comp;
            
            [Trials(trialID).trees(treeID).SVMModelFP_splited,~,~]=trainingCCwmtoaFP(...
                            CCfeatures_comp,Trials(trialID).trees(treeID).file,Training_features,...
                            StandardizeFP,KernelFunctionFP,BoxConstrainFP,0,0,0,0,0,0,models_Directory,session);
        end
    end
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;
else
    disp('Inicio Loading models...')
    for trialID=1:size(Trials,2)
        for treeID=1:size(Trials(trialID).trees,2)
            Trials(trialID).trees(treeID).SVMModelFP_splited=loadCompactModel(strcat(models_Directory,'SVMModelFP_splited_',...
                                                                    Trials(trialID).trees(treeID).file(1:end-4),'_s',...
                                                                    num2str(session),'.mat'));
        end
    end
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;
end

    %% FP splited rmoval
   
if technique_FP
    disp('Inicio FP removal...')
    for trialID=1:size(Trials,2)
        for treeID=1:size(Trials(trialID).trees,2)
            [Trials(trialID).trees(treeID).class,Trials(trialID).trees(treeID).CCfeatures_splited_nonFP]=FP_removal(Trials(trialID).trees(treeID).SVMModelFP_splited,...
                                                                                          Trials(trialID).trees(treeID).CCfeatures_splited,...
                                                                                          Trials(trialID).trees(treeID).class,...
                                                                                          technique_FP,Training_features,...
                                                                                          Trials(trialID).trees(treeID).file(1:end-4));
        end
    end
    disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
    t=toc;
else
    for trialID=1:size(Trials,2)
        for treeID=1:size(Trials(trialID).trees,2)
            Trials(trialID).trees(treeID).CCfeatures_splited_nonFP=Trials(trialID).trees(treeID).CCfeatures_splited;
        end
    end
end

t=toc;

    %% Detection assesment
pcID=1;

for trialID=1:size(Trials,2)
    for treeID=1:size(Trials(trialID).trees,2)

        disp(strcat('Inicio Detection assesment technique',num2str(Split_technique),'...'))
        tree_index=(Trials(trialID).trees(treeID).class'>0);
        apple_detectionsPC=pointCloud(Trials(trialID).trees(treeID).ptCloud_th(tree_index,1:3));
        LCM=LabelClusterMatrix(apple_detectionsPC,Groundtruth_Directory,...
                                {Trials(trialID).trees(treeID).treeID},...
                                Trials(trialID).trees(treeID).class(tree_index));
        [Trials(trialID).trees(treeID).LCM_LOC,Trials(trialID).trees(treeID).LCM_LOC_COL]=ClusterLabelAssignment(LCM);

        [T,P,ClustersinLabel,LabelsDetected,...
            TP,FP_LOC_COL,FP,Localization_success_C,...
            Localization_success_L,FDR_LOC_COL,FDR,precision,...
            recall,F1]=detection_assesment(LCM,Trials(trialID).trees(treeID).LCM_LOC_COL);
        disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
        t=toc;
        
        if ~strcmp(Trials(trialID).trees(treeID).file(1:4),'late')
            results={Trials(trialID).trees(treeID).file(1:end-4),T,LabelsDetected,FP,Localization_success_L,FDR,...
                TP,FP_LOC_COL,recall,FDR_LOC_COL,F1,toc,precision};
        else
            results={strcat(Trials(trialID).trees(treeID).treeID,Trials(trialID).trees(treeID).file,'_',num2str(Trials(trialID).trees(treeID).fuseTrials)),...
                T,LabelsDetected,FP,Localization_success_L,FDR,...
                TP,FP_LOC_COL,recall,FDR_LOC_COL,F1,toc,precision};
        end
            
        fid = fopen(strcat(save_directory,'results.xlsx'), 'a');
        fclose('all');
        while (fid == -1)
            errormsg = strcat('the file: ',save_directory,'results.xlsx', ' is open. please close it!');
            waitfor(msgbox(errormsg,'Error'));
            fid = fopen(strcat(save_directory,'results.xlsx'), 'a');
            fclose('all');
        end    
        xlswrite(strcat(save_directory,'results.xlsx'), results , strcat('Results_s',num2str(session)) , ['B' num2str(pcID+4) ] );
             
        allT(treeID,trialID)=T; %Ground Truth labels
        allLabelsDetected(treeID,trialID)=LabelsDetected; %TPloc
        allFP(treeID,trialID)=FP;%FPloc
        allLocalization_success_L(treeID,trialID)=Localization_success_L;%Successloc
        allFDR(treeID,trialID)=FDR;%FDRloc
        allTP(treeID,trialID)=TP;%TPid
        allFP_LOC_COL(treeID,trialID)=FP_LOC_COL;%FPid
        allrecall(treeID,trialID)=recall;%Successid
        allFDR_LOC_COL(treeID,trialID)=FDR_LOC_COL;%FDRid
        allF1(treeID,trialID)=F1;
        allprecision(treeID,trialID)=precision;
        
        pcID=pcID+1;
    end
end
% 
% distributionHistograms_horizontal(Groundtruth_Directory,Trials);
% distributionHistograms(Groundtruth_Directory,Trials);

Loc_suc_trials=sum(allLabelsDetected)./(sum(allT));
Loc_FDR_trials=sum(allFP)./(sum(allLabelsDetected)+sum(allFP));
Id_suc_trials=sum(allTP)./(sum(allT));
Id_FDR_trials=sum(allFP_LOC_COL)./(sum(allTP)+sum(allFP_LOC_COL));

F1_trials=2*sum(allTP)./(sum(allTP)+sum(allFP_LOC_COL)+sum(allT));
F1_trials_not2_6=2*sum(allTP([1,3:5,7:11],:))./(sum(allTP([1,3:5,7:11],:))+sum(allFP_LOC_COL([1,3:5,7:11],:))+sum(allT([1,3:5,7:11],:)));
F1_trees=2*sum(allTP,2)./(sum(allTP,2)+sum(allFP_LOC_COL,2)+sum(allT,2));
disp(strcat('F1_trials=',num2str(F1_trials),'    F1_trials_not2_6=', num2str(F1_trials_not2_6)));
% 
% xlswrite(strcat(save_directory,'results.xlsx'), {'Loc_suc_trials','Loc_FDR_trials','Id_suc_trials','Id_FDR_trials','F1_trials','F1_trials_not2_6'} , strcat('Results_s',num2str(session)) , ['C' num2str(pcID+7) ] );
% xlswrite(strcat(save_directory,'results.xlsx'), Trials2eval' , strcat('Results_s',num2str(session)) , ['B' num2str(pcID+8) ] );
% xlswrite(strcat(save_directory,'results.xlsx'), Loc_suc_trials' , strcat('Results_s',num2str(session)) , ['C' num2str(pcID+8) ] );
% xlswrite(strcat(save_directory,'results.xlsx'), Loc_FDR_trials' , strcat('Results_s',num2str(session)) , ['D' num2str(pcID+8) ] );
% xlswrite(strcat(save_directory,'results.xlsx'), Id_suc_trials' , strcat('Results_s',num2str(session)) , ['E' num2str(pcID+8) ] );
% xlswrite(strcat(save_directory,'results.xlsx'), Id_FDR_trials' , strcat('Results_s',num2str(session)) , ['F' num2str(pcID+8) ] );
% xlswrite(strcat(save_directory,'results.xlsx'), F1_trials' , strcat('Results_s',num2str(session)) , ['G' num2str(pcID+8) ] );
% xlswrite(strcat(save_directory,'results.xlsx'), F1_trials_not2_6' , strcat('Results_s',num2str(session)) , ['H' num2str(pcID+8) ] );
% 
% xlswrite(strcat(save_directory,'results.xlsx'), {'F1_trials'} , strcat('Results_s',num2str(session)) , ['C' num2str(pcID+8+size(Trials2eval,2)) ] );
% xlswrite(strcat(save_directory,'results.xlsx'), {'tree01','tree02','tree03','tree04','tree05',...
%                         'tree06','tree07','tree08','tree09','tree10','tree11'}' , strcat('Results_s',num2str(session)) , ['B' num2str(pcID+9+size(Trials2eval,2)) ] );
% xlswrite(strcat(save_directory,'results.xlsx'), F1_trees , strcat('Results_s',num2str(session)) , ['C' num2str(pcID+9+size(Trials2eval,2)) ] );

%% compute predictions

[ab, predicted, error, RMSE, b_origin, predicted_origin, error_origin, RMSE_origin]=compute_predictions([139,106,139,137,94,131,119,145,139,136,159]',allTP+allFP_LOC_COL,Trials);

xlswrite(strcat(save_directory,'results.xlsx'), RMSE' , strcat('Results_s',num2str(session)) , ['I' num2str(pcID+8) ] );
xlswrite(strcat(save_directory,'results.xlsx'), RMSE_origin' , strcat('Results_s',num2str(session)) , ['J' num2str(pcID+8) ] );


    %% Save_clusters
    if save_dets
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


        
        for trialID=1:size(Trials,2)
            for treeID=1:size(Trials(trialID).trees,2)
                if ~exist(strcat(save_directory,'dets_s',num2str(session),'\dets',Trials(trialID).trees(treeID).file(1:end-4)), 'dir')        
                    mkdir(strcat(save_directory,'dets_s',num2str(session),'\dets',Trials(trialID).trees(treeID).file(1:end-4)));
                end 
                CCall=[];
                color_class=colormap(lines(max(Trials(trialID).trees(treeID).class)));
                for i=1:max(class)
                    CCxyz=Trials(trialID).trees(treeID).ptCloud_th(Trials(trialID).trees(treeID).class==i,1:4);
                    if size(CCxyz,1)
                        CCi=[CCxyz,repmat(color_class(i,:)*255,size(CCxyz,1),1)];
                        CCall=[CCall;CCi];
                        dlmwrite(strcat(save_directory,'dets_s',num2str(session),'\dets',Trials(trialID).trees(treeID).file(1:end-4),'\det',Trials(trialID).trees(treeID).file(1:end-4),'_s',num2str(session),'_',num2str(i,'%03.f'),'.txt'),CCi,'precision','%.3f','delimiter','\t')
                    end
                end
                
                dlmwrite(strcat(save_directory,'dets_s',num2str(session),'\dets',Trials(trialID).trees(treeID).file(1:end-4),'\all_det',Trials(trialID).trees(treeID).file(1:end-4),'_s',num2str(session),'.txt'),CCall,'precision','%.3f','delimiter','\t')
                
                disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
                t=toc;
            end
        end
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

%end

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

