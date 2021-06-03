%% Calculating a bulls eye (triangular) slip distribution given a maximum slip value

% Given a maximum slip value, which is assigned to the centre of the fault
% this script will calculate a triangular slip distribution (slip vs distance along the fault) which will then
% be applied to gridded fault

% Written 07/04/21 by Zoe Mildon - to reduce complexity of calculating slip distribution when only part of the fault ruptures. 
% Start and end points (in km) of ruptures are specified.
% Identical for both variable and planar dip, and better functionality for changing the location of maximum slip

slip_distribution=zeros((length(z_points(:,1))-1),(length(x_points(1,:))-1)); % generates a blank matrix for slip_distribution to be put into
% Checking for potential issues
if end_slip>fault_length
    errordlg('The specified slip length is longer than fault length!')
    return
elseif set_centre_hor.Value>=end_slip
    errordlg('The location of maximum slip is outside the specified rupture!')
    set(tabgp,'SelectedTab',tab2);
    return
end
    
mid_slip=(start_slip+end_slip)/2;
rupture_length=abs(end_slip-start_slip);

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

% Calculate the distances of all the mid-points of elements
length_last=sqrt((x_points(1,L-1)-x_points(1,L))^2+(y_points(1,L-1)-y_points(1,L))^2); % length of the last grid box
if length(x_points(1,:))>3
	distances=[d2,d,((L-2)*grid_sizem+length_last/2)];
elseif length(x_points(1,:))==3
	distances=[d2,((L-2)*grid_sizem+length_last/2)];
else
	distances=[set_centre_hor.Value];
end

a=find((distances >= (start_slip*1000)) & (distances <= (end_slip*1000))); %find the indicies of slip distribution that are within the area of slip along the fault
slip_distances=distances(a);
    
% Calculate the slip distribution for the specific section of the fault
slip_distances=sort(slip_distances);
slip_distances=slip_distances.';
    
slip_values=[0;maximum_slip;0];
    
data_distances=[start_slip*1000;set_centre_hor.Value*1000;end_slip*1000];
slipsx=interp1(data_distances,slip_values,slip_distances);
slips=slipsx.';
    
% Extending the slip distribution to depth, with a triangular profile
depth_distances=[0;centre_vertical;rupture_depth]; 
given_slip_proportions=[slip_at_surface;1;0];
       
% Calculating the depth of the middle of all the elements, works for both variable and planar dip cases
for h=1:length(z_points(:,1))-1
	calc_depth(h,1)=-(z_points(h,1)+z_points(h+1,1))/2;
end

calc_depth=calc_depth(find(calc_depth<rupture_depth)); % remove depths below the specified rupture depth
    
slip_proportions=interp1(depth_distances,given_slip_proportions,calc_depth);
slip_dist=slip_proportions*slips;
    
b=find((calc_depth <= rupture_depth)); % find the indicies that are with the area of slip down the fault

slip_distribution(b(1):b(end),a(1):a(end))=slip_dist; % Putting slip_dist matrix into the zeros matrix previously set up

