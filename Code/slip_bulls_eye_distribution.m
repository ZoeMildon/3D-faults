%% Calculating a bulls eye (triangular) slip distribution given a maximum slip value

% Given a maximum slip value, which is assigned to the centre of the fault
% this script will calculate a triangular slip distribution (slip vs distance along the fault) which will then
% be applied to gridded fault

% Updated 31/03/21 by Zoe Mildon - made uniform for both variable and
% planar dip, and better functionality for changing the location of maximum
% slip

% Calculating the mid-element lengths to determine interpolation distances 
L=length(x_points(1,:));

d2=grid_sizem/2;
if length(x_points(:,1))>=3
    for i=1:L-3
        d(i)=d2+grid_sizem*i;
    end
else
    disp('length(x_points(:,1)) < 3')   %just for debugging!
    return
end

length_last=sqrt((x_points(1,L-1)-x_points(1,L))^2+(y_points(1,L-1)-y_points(1,L))^2); % length of the last grid box
if length(x_points(1,:))>3
    distances=[d2,d,((L-2)*grid_sizem+length_last/2)]; 
elseif length(x_points(1,:))==3
    distances=[d2,((L-2)*grid_sizem+length_last/2)];
else
    distances=[set_centre_hor.Value];
end

% Creating a triangular slip distribution at the surface
distances=sort(distances);
distances=distances.';

Ldist=length(distances);
a=find(distances==centre_horizontal);
slip_values=[0;maximum_slip;0];

data_distances=[0;set_centre_hor.Value*1000;fault_length*1000];
slipsx=interp1(data_distances,slip_values,distances);
slips=slipsx.';

% Extending the slip distribution to depth, with a triangular profile

depth_distances=[0;centre_vertical;rupture_depth]; 
given_slip_proportions=[slip_at_surface;1;0];

%Calculating the depth of the middle of all the elements - should work for
%both variable and planar dip cases
for h=1:length(z_points(:,1))-1
    calc_depth(h,1)=-(z_points(h,1)+z_points(h+1,1))/2;
end
slip_proportions=interp1(depth_distances,given_slip_proportions,calc_depth);
slip_distribution=slip_proportions*slips;
slip_distribution(isnan(slip_distribution))=0; 