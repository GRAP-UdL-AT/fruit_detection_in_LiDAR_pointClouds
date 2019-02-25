%% Detection assesment

function [T,P,ClustersinLabel,LabelsDetected,...
    TP,FP_LOC_COL,FP,Localization_success_C,...
    Localization_success_L,FDR_LOC_COL,FDR,precision,...
    recall,F1]=detection_assesment(LCM,LCM_LOC_COL)

T=size(LCM_LOC_COL,1); %B: N� manzanas etiquetadas (Labelling ground truth)
P=size(LCM_LOC_COL,2); %C: N� de cl�steres detectados

ClustersinLabel=sum(sum(LCM)>1); %D: N� de cl�steres que tienen m�s de 10 puntos dentro de una etiqueta
LabelsDetected=sum(sum(LCM,2)>1); %E: N� de etiquetas que tienen m�s de 10 puntos de un mismo cl�ster
TP=sum(sum(LCM_LOC_COL)); %F: N� de detecciones assignando una sola etiqueta a cada cluster.

FP_LOC_COL=P-TP;
FP=P-ClustersinLabel;

Localization_success_C=LabelsDetected/P;
Localization_success_L=LabelsDetected/T;

FDR_LOC_COL=FP_LOC_COL/P;
FDR=FP/(LabelsDetected+FP);

precision=TP/P;
recall=TP/T;
F1=2*TP/(P+T);

disp(strcat('T:__', num2str(T)))
disp(strcat('P:__', num2str(P)))
disp('__')
disp(strcat('ClustersinLabel:__', num2str(ClustersinLabel)))
disp(strcat('LabelsDetected:__', num2str(LabelsDetected)))
disp(strcat('TP:__', num2str(TP)))
disp('__')
disp(strcat('FP_LOC_COL:__', num2str(FP_LOC_COL)))
disp(strcat('FP:__', num2str(FP)))
disp('__')
disp(strcat('Localization_success_C:__', num2str(Localization_success_C*100), ' %'))
disp(strcat('Localization_success_L:__', num2str(Localization_success_L*100), ' %'))
disp('__')
disp(strcat('FDR_LOC_COL:__', num2str(FDR_LOC_COL*100), ' %'))
disp(strcat('FDR:__', num2str(FDR*100), ' %'))
disp('__')
disp(strcat('Precision(TP/P):__', num2str(precision*100), ' %'))
disp(strcat('Recall(TP/T):__', num2str(recall*100), ' %'))
disp(strcat('F1:__', num2str(F1*100), ' %'))


end
