function LA=LA_from_pc(ptCloud_nOut,pixel_dim)


%%Inicialització imatge 2D
        x_min=min(ptCloud_nOut(:,1));
        x_max=max(ptCloud_nOut(:,1));
        y_min=min(ptCloud_nOut(:,2));
        y_max=max(ptCloud_nOut(:,2));
        z_min=min(ptCloud_nOut(:,3));
        z_max=max(ptCloud_nOut(:,3));
        
        nuvol_2D_front=zeros((round((z_max-z_min)/pixel_dim))+1,round((y_max-y_min)/pixel_dim)+1);
        nuvol_2D_top=zeros((round((x_max-x_min)/pixel_dim))+1,round((y_max-y_min)/pixel_dim)+1);
        
        %%Creació imatge 2D.
        for i=1:size(ptCloud_nOut,1)

            Px2D=round((x_max-ptCloud_nOut(i,1))/pixel_dim)+1;
            Py2D=round((y_max-ptCloud_nOut(i,2))/pixel_dim)+1;
            Pz2D=round((z_max-ptCloud_nOut(i,3))/pixel_dim)+1;
            
            nuvol_2D_front(Pz2D,Py2D)=1;
            nuvol_2D_top(Px2D,Py2D)=1;
        end
        
        %%Calcul LA
        PFS=sum(sum(nuvol_2D_front))*(pixel_dim^2)/(y_max-y_min); %Superficie frontal / metre lineal
        PTS=sum(sum(nuvol_2D_top))*(pixel_dim^2)/(y_max-y_min); %Superficie top / metre lineal
        PTRS=2*PFS+2*PTS;

        LA=1.61*PTRS-2.88;
end
