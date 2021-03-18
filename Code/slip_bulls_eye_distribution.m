%% Calculating a bulls eye (triangular) slip distribution given a maximum slip value

% Given a maximum slip value, which is assigned to the centre of the fault
% this script will calculate a triangular slip distribution (slip vs distance along the fault) which will then
% be applied to gridded fault

% Calculating halfway distance along the fault trace
utm_lon=utm_x;
utm_lat=utm_y;
L=length(utm_lat);

for i=1:L-1
   seg_length(i)=sqrt((utm_lat(i)-utm_lat(i+1))^2+(utm_lon(i)-utm_lon(i+1))^2);
   sum_length(1)=0;
   sum_length(i+1)=sum_length(i)+seg_length(i);
end
total_length=sum(seg_length);
if centre_horizontal>0
    middle_dist=centre_horizontal*1000;
else
    middle_dist=total_length/2;
end

L=length(x_points(1,:));
% number of mid-grid points
d2=grid_sizem/2;
if length(x_points(:,1))>=3
    for i=1:L-3
        d(i)=d2+grid_sizem*i;
    end
else
end

length_last=sqrt((x_points(1,L-1)-x_points(1,L))^2+(y_points(1,L-1)-y_points(1,L))^2); % length of the last grid box
if length(x_points(1,:))>3
    distances=[d2,d,((L-2)*grid_sizem+length_last/2)]; 
elseif length(x_points(1,:))==3
    distances=[d2,((L-2)*grid_sizem+length_last/2)];
else
    distances=[middle_dist];
end

% Creating a trigular slip distribution at the surface
distances=sort(distances);
distances=distances.';

Ldist=length(distances);
a=find(distances==middle_dist);
slip_values=[0;maximum_slip;0];

data_distances=[0;middle_dist;total_length]; 

slipsx=interp1(data_distances,slip_values,distances);
slips=slipsx.';

% Extending the slip distribution to depth, with a triangular profile
if rupture_depth>0        
    middle_vertical=(rupture_depthm/sind(constant_dip))/2;
    depth_extent=rupture_depthm;
else
	middle_vertical=(seismo_depthm/sind(constant_dip))/2;
    depth_extent=seismo_depthm/sind(constant_dip);
end

if centre_vertical>0
    middle_vertical=centre_vertical*1000;
else
end

depth_distances=[0;middle_vertical;depth_extent];
given_slip_proportions=[slip_at_surface;1;0];
C=[grid_size_to_depth/2:grid_size_to_depth:(m-1)*grid_size_to_depth+(grid_size_to_depth/2)];
calc_depth_prop=([0,C,depth_extent]).';
slip_proportions=interp1(depth_distances,given_slip_proportions,calc_depth_prop);

slip_proportions=[slip_proportions(2:length(slip_proportions)-1)];

slip_distribution=slip_proportions*slips;
slip_distribution(isnan(slip_distribution))=0;
