%function plt = patch_plotting(plt,x_points,y_points,z_points,utm_lat,utm_lon, maximum_slip, slip_distribution)
%Plotting 3D fault planes with patch approach, colour coded by slip distribution
if subplot_on.Value == true || strcmp(fault_name,fault_slip_name)==1
    for r=1:length(x_points(:,1))-1
        for c=1:length(x_points(1,:))-1                
            x = [x_points(r,c), x_points(r+1,c), x_points(r+1,c+1), x_points(r,c+1)];
            y = [y_points(r,c), y_points_copy(r+1,c), y_points_copy(r+1,c+1), y_points(r,c+1)];
            z = [z_points(r,c), z_points_copy(r+1,c), z_points_copy(r+1,c+1), z_points(r,c+1)];
            if (isnan(x_points(r+1,c)) && ~isnan(x_points(r+1,c+1))) || (~isnan(x_points(r+1,c)) && isnan(x_points(r+1,c+1)))
                %if only one bottom corner is missing, it is replaced and plotted anyway
                x(2)=x_points_copy(r+1,c);
                x(3)=x_points_copy(r+1,c+1);

                y(2)=y_points_copy(r+1,c);
                y(3)=y_points_copy(r+1,c+1);

                z(2)=z_points_copy(r+1,c);
                z(3)=z_points_copy(r+1,c+1);
            end
            patch(x,y,z,slip_distribution(r,c));
        end
    end
    hold('on')
    plot(utm_lon,utm_lat,'g','LineWidth',2);
    axis('equal')
    view(3)
    % Colour map for slip distribution
    T=[1,1,1; 1,1,0; 1,0,0];% white, yellow, red
    A=[0;1;2];
    slip_dist = interp1(A,T,linspace(0,2,101));
    colormap(slip_dist);
    cb = colorbar('southoutside');
    title(cb,'Total slip (m)');
    caxis([0 maximum_slip])
    xlabel('UTM x')
    ylabel('UTM y')
    zlabel('Depth (m)')
end
clearvars A T slip_dist x y z