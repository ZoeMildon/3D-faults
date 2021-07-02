%function plt = patch_plotting(plt,x_points,y_points,z_points,utm_lat,utm_lon, maximum_slip, slip_distribution)
% Plotting 3D fault planes with patch approach, colour coded by slip distribution

for i=1:length(x_points(:,1))-1
    for j=1:length(x_points(1,:))-1
    x(1)=x_points(i,j);
    x(2)=x_points(i+1,j);
    x(3)=x_points(i+1,j+1);
    x(4)=x_points(i,j+1);

    y(1)=y_points(i,j);
    y(2)=y_points(i+1,j);
    y(3)=y_points(i+1,j+1);
    y(4)=y_points(i,j+1);

    z(1)=z_points(i,j);
    z(2)=z_points(i+1,j);
    z(3)=z_points(i+1,j+1);
    z(4)=z_points(i,j+1);
    patch(plt,x,y,z,slip_distribution(i,j));
    end
end
hold(plt,'on')
plot(plt,utm_lon,utm_lat,'g','LineWidth',2);
axis(plt,'equal')
view(plt,3)
% Colour map for slip distribution
T=[1,1,1    % white
   1,1,0   % yellow
   1,0,0]; % red
A=[0;1;2];
slip_dist = interp1(A,T,linspace(0,2,101));
colormap(plt,slip_dist);

cb = colorbar(plt, 'southoutside');
title(cb,'Total slip (m)');
caxis(plt,[0 maximum_slip])
xlabel(plt,'UTM x')
ylabel(plt,'UTM y')
zlabel(plt,'Depth (m)')
clearvars x y z
patch_count = patch_count + numel(slip_distribution);