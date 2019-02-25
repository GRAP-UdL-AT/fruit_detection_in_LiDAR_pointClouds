function [tree_shape_E,tree_shape_W,mean_height,mean_width]=mean_canopy_geometry(ptCloud_nOut,center,steps)

%Este codigo solamente es valido cuando la hilera de arboles es paralela al
%eje de coordenadas "Y" y perpendicular al eje de coordenadas "Z".
    %% Procesado 
    x_min=min(ptCloud_nOut(:,1));
    x_max=max(ptCloud_nOut(:,1));
    y_min=min(ptCloud_nOut(:,2));
    y_max=max(ptCloud_nOut(:,2));
    z_min=min(ptCloud_nOut(:,3));
    z_max=max(ptCloud_nOut(:,3));

    y_sub=y_min;
    z_sub=z_min;
    x_sub_min=zeros(round(z_max-z_min/steps)-1,round(y_max-y_min/steps)-1);
    x_sub_max=zeros(round(z_max-z_min/steps)-1,round(y_max-y_min/steps)-1);
    i=1;
    j=1;

    while(y_sub<y_max)
        ptCloud_nOut_sub=ptCloud_nOut(ptCloud_nOut(:,2)>y_sub&ptCloud_nOut(:,2)<(y_sub+steps),:);
        while(z_sub<z_max)
            ptCloud_nOut_sub_sub=ptCloud_nOut_sub(ptCloud_nOut_sub(:,3)>z_sub&ptCloud_nOut_sub(:,3)<(z_sub+steps),:);

            %size(ptCloud_nOut_sub_sub,1)

            if size(ptCloud_nOut_sub_sub,1)
                x_sub_min(j,i)=min(ptCloud_nOut_sub_sub(:,1));
                x_sub_max(j,i)=max(ptCloud_nOut_sub_sub(:,1));
            else
                x_sub_min(j,i)=center;
                x_sub_max(j,i)=center;
            end
            j=j+1;
            z_sub=z_sub+steps;
        end
        z_sub=z_min;
        j=1;
        i=i+1;
        y_sub=y_sub+steps;     
    end

    m_x_sub_max=mean(x_sub_max,2);
    m_x_sub_min=mean(x_sub_min,2);
    tree_shape_E=m_x_sub_min-center;
    tree_shape_W=m_x_sub_max-center;

    mean_height=mean(max(repmat([1:size(x_sub_min,1)]'./10,1,size(x_sub_min,2)).*[x_sub_min~=center]));
    mean_width=mean(max(x_sub_max-x_sub_min));

end
