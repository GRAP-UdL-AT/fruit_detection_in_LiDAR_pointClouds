 clc
 clear
 
session=2;
directory='F:\Detecció Fruits 2017\velodyne_vent';
pcDirectory_txt=strcat(directory,'\data\AllTrees_pcloud\');
Groundtruth_Directory=strcat(directory,'\data\AllTrees_Groundtruth\');
models_Directory=strcat(directory,'\data\Trained_models\');
pcTreatDirectory=strcat(directory,'\data\Treated_pcloud\');
save_directory=strcat(directory,'\results\');

Trials2eval={'H1_n_E_O','H1_n_E','H1_n_O','H1_H2_n_E_O','H1_n_af_E_O'}; %List the trials to evaluate  

[Trials , Trials2eval]= ListFiles_trial(pcDirectory_txt,Trials2eval,{});

Th=1;
NumNeigh=6;
pixel_dim=0.01;%Un pixcel cada 1cm.
steps=0.1;
center=336312.2;
y2=0:0.1:4;

LA_all=zeros(size(Trials(1).trees,2)+1,size(Trials,2));

fig=figure;
for trialID=1:size(Trials,2)
    Trials(trialID).all_ptCloud_nOut=[];
    for treeID=1:size(Trials(trialID).trees,2)
        
        %%Point cloud reading
        disp(strcat('Inicio Point cloud reading_',Trials(trialID).trees(treeID).file(1:end-4),' ...'))
        tic;
        [ptCloud_all,ptCloud_all_xyz]=pointCloudReading({Trials(trialID).trees(treeID).file(1:end-4)},pcDirectory_txt);
        t=toc; disp(strcat('    realizado en:__', num2str(toc), ' seg.'))
        
        %% Outliers removal
        disp('Inicio Outlier removal...')
        [ptCloud_all_notOutliers,inlierIndices,~]=pcdenoise(ptCloud_all,'NumNeighbors',NumNeigh,'Threshold',Th);
        ptCloud_nOut=ptCloud_all_notOutliers.Location;
        ptCloud_nOut(:,4:5)=ptCloud_all_xyz(inlierIndices,[4 6]);
        disp(strcat('    realizado en:__', num2str(toc-t), ' seg.'))
        t=toc;
        Trials(trialID).all_ptCloud_nOut=[Trials(trialID).all_ptCloud_nOut;ptCloud_nOut];

        LA_all(treeID,trialID)=LA_from_pc(ptCloud_nOut,pixel_dim);
        
        
    end
    save(strcat(save_directory,'Trials_LA_meanShape_','s',num2str(session),'.mat'),'Trials');
    LA_all(treeID+1,trialID)=LA_from_pc(Trials(trialID).all_ptCloud_nOut,pixel_dim);
    [tree_shape_E,tree_shape_W,mean_height(trialID),mean_width(trialID)]=mean_canopy_geometry(Trials(trialID).all_ptCloud_nOut,center,steps);
    meanShape(trialID).tree_shape_E=tree_shape_E;
    meanShape(trialID).tree_shape_W=tree_shape_W;
    meanSection(trialID)=sum((tree_shape_W-tree_shape_E).*steps); %mean cross section (m^2)

end


for trialID=1:size(Trials,2)
        hold on
    plt1(trialID)=plot(meanShape(trialID).tree_shape_E(1:size(y2,2)),y2);
    hold on
    plt2(trialID)=plot(meanShape(trialID).tree_shape_W(1:size(y2,2)),y2,'Color',plt1(trialID).Color);
    legend(plt1,Trials2eval,'Interpreter','none')
end

