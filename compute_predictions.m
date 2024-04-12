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
    
end
