function [ab, predicted, error, RMSE, b_origin, predicted_origin, error_origin, RMSE_origin]=compute_predictions(R,C,Trials)

    ab=zeros(size(R,1),2,size(C,2));
    b_origin=zeros(size(R,1),size(C,2));
    predicted=zeros(size(R,1),size(C,2));
    predicted_origin=zeros(size(R,1),size(C,2));
    error=zeros(size(R,1),size(C,2));
    error_origin=zeros(size(R,1),size(C,2));
    color=[255 0 0 ; 0 255 0 ; 0 0 255 ; 255 255 0 ; 255 0 255 ; 200 50 0 ; 0 255 255 ; 200 200 200 ; 255 150 0  ; 0 150 0 ; 100 100 100];


    for j=1:size(C,2)
        fig=figure;
        for i=1:size(R,1)
            ab(i,:,j)=polyfit(C(1:size(R,1)~=i,j),R(1:size(R,1)~=i),1);
            b_origin(i,j)=C(1:size(R,1)~=i,j)\R(1:size(R,1)~=i);
            predicted(i,j)=ab(i,1,j)*C(i,j)+ab(i,2,j);
            predicted_origin(i,j)=b_origin(i,j)*C(i,j);
            error(i,j)=(R(i)-predicted(i,j))*100/R(i);
            error_origin(i,j)=(R(i)-predicted_origin(i,j))*100/R(i);
            coR=corrcoef(C(1:size(R,1)~=i,j),R(1:size(R,1)~=i));
            R2(i,j)=coR(2,1).^2;
            leg{i}=strcat('Tree\_',num2str(i),' ; a=',num2str(ab(i,1,j)),' ; b=',num2str(ab(i,2,j)));
    %         leg{i*2-1}=strcat('Tree\_',num2str(i),' - R^2=',num2str(R2(i,j)),' - Error=',num2str(error(i,j)),'%');
    %         leg{i*2}=strcat('Tree\_',num2str(i),' - R^2=',num2str(R2(i,j)),' - Error=',num2str(error(i,j)),'%');
            p1(i)=plot(C(i,j),R(i),'o','LineWidth',2,'MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor',color(i,:)/255);
            hold on
            p2(i)=plot(C(:,j),polyval(ab(i,:,j),C(:,j)),'-','LineWidth',1,'Color',color(i,:)/255);
            hold on
            
            
            
        end

        legend(p2,leg);
        title(strcat('Trial_',Trials(j).name),'Interpreter','none');
        xlabel('Counted (TP+FP)');
        ylabel('Ground truth');
        set(fig.CurrentAxes,'fontsize',10,'FontName','Times New Roman');

    end
    
    RMSE=sqrt(sum(error.^2)/size(error,1));
    RMSE_origin=sqrt(sum(error_origin.^2)/size(error_origin,1));
    
    % 
    % h = findobj(gca,'Type','line');
    % legend([h(19) h(17) h(15) h(13) h(11) h(9) h(8) h(7) h(5) h(3) h(1)],'Tree\_1 - a=0.9144 - b=33.75'...
    % , 'Tree\_2 - a=0.9063 - b=34.83', 'Tree\_3 - a=0.9195 - b=33.40','Tree\_4 - a=0.9299 - b=32.60',...
    % 'Tree\_5 - a=0.9136 - b=33.95','Tree\_6 - a=0.9832 - b=27.97','Tree\_7 - a=0.9056 - b=35.15',...
    % 'Tree\_8 - a=0.9108 - b=32.99','Tree\_9 - a=0.9271 - b=32.78','Tree\_10 - a=0.9150 - b=33.44','Tree\_11 - a=0.8492 - b=39.76')
    % 
    % print(gcf,'F:\Detecció Fruits 2017\velodyne_vent\manuscrit\figures\regresion_prediction\regression_prediction.png','-dpng','-r300')
% 
%     directory='F:\Detecció Fruits 2017\velodyne_vent';
%     save_directory=strcat(directory,'\results\');
%     xlswrite(strcat(save_directory,'results.xlsx'), [R,C] , strcat('Results_s',num2str(session)) , ['B680'] );
%     xlswrite(strcat(save_directory,'results.xlsx'), ab(:,:,1) , strcat('Results_s',num2str(session)) , ['G680'] );
%     xlswrite(strcat(save_directory,'results.xlsx'), ab(:,:,2) , strcat('Results_s',num2str(session)) , ['I680'] );
%     xlswrite(strcat(save_directory,'results.xlsx'), ab(:,:,3) , strcat('Results_s',num2str(session)) , ['K680'] );
%     %xlswrite(strcat(save_directory,'results.xlsx'), ab(:,:,4) , strcat('Results_s',num2str(session)) , ['M680'] );
%     xlswrite(strcat(save_directory,'results.xlsx'), predicted , strcat('Results_s',num2str(session)) , ['O680'] );
%     xlswrite(strcat(save_directory,'results.xlsx'), error , strcat('Results_s',num2str(session)) , ['S680'] );

end
