% code to select and calculate slip distributions (functions below)

slip_type = 'bulls_eye'; % comment what you need (could be coupled with a UI element (e.g. a dropdown))
%slip_type = 'simple_backslip';

%% fetch variables:
start_slip = sp_start.Value;
end_slip = sp_end.Value;
rupture_depth = -round(sl_rupture_d.Value)*1000;
maximum_slip = set_maxSlip.Value;
slip_at_surface = set_surfSlip.Value / 100;
centre_horizontal = round(sl_centre_hor.Value)*1000;
centre_vertical = -round(sl_centre_ver.Value)*1000;
%% check slip type & call functions
switch slip_type
    case 'bulls_eye'
        slip_distribution = slipdist_bulls_eye(start_slip,end_slip,grid_sizem,rupture_depth,maximum_slip,slip_at_surface,centre_horizontal,centre_vertical,x_points,y_points,z_points,z_points_copy,geometry,dip_depth);
    case 'simple_backslip'
        slip_distribution = slipdist_triangular(maximum_slip,x_points);
end

%% plot slip distribution preview
imagesc(slip_ax,slip_distribution)

%% Calculating a bulls eye (triangular) slip distribution given a maximum slip value
% Given a maximum slip value, which is assigned to the centre of the fault this script will calculate a 
% triangular slip distribution (slip vs distance along the fault) which will then be applied to gridded fault.

% Written 07/04/21 by Zoe Mildon - to reduce complexity of calculating slip distribution when only part of the fault ruptures. 
% Start and end points (in km) of ruptures are specified.
% Identical for both variable and planar dip, and better functionality for changing the location of maximum slip

% adjusted version for new user interface 01/2023 (M.D.)
function slip_distribution = slipdist_bulls_eye(start_slip,end_slip,grid_sizem,rupture_depth,maximum_slip,slip_at_surface,centre_horizontal,centre_vertical,x_points,y_points,z_points,z_points_copy,geometry,dip_depth)
    %check for input issues
    if centre_vertical >= rupture_depth
        return
    end
    
    slip_distribution=zeros(size(x_points) - [1 1]); % generates a blank matrix for slip_distribution to be put into
    L=length(x_points(1,:));
    d2=grid_sizem/2;
    if length(x_points(:,1))>=3
        for i=1:L-3
            d(i)=d2+grid_sizem*i;
        end
    end
    
    % Calculate the distances of all the mid-points of elements
    length_last=sqrt((x_points(1,L-1)-x_points(1,L))^2+(y_points(1,L-1)-y_points(1,L))^2); % length of the last grid box
    if length(x_points(1,:))>3
	    distances=[d2,d,((L-2)*grid_sizem+length_last/2)];
    elseif length(x_points(1,:))==3
	    distances=[d2,((L-2)*grid_sizem+length_last/2)];
    else
	    distances=round(sl_centre_hor.Value)*1000;
    end
    
    a=find((distances >= (start_slip*1000)) & (distances <= (end_slip*1000))); %find the indices of slip distribution that are within the area of slip along the fault
    slip_distances=distances(a);
    
    % Calculate the slip distribution for the specific section of the fault
    slip_distances=sort(slip_distances);
    slip_distances=slip_distances.';
        
    slip_values=[0;maximum_slip;0];
        
    data_distances=[start_slip*1000;centre_horizontal;end_slip*1000];
    slipsx=interp1(data_distances,slip_values,slip_distances);
    slips=slipsx.';
    
    % Extending the slip distribution to depth, with a triangular profile
    switch geometry %make sure that rupture depth is not larger than the deepest portion of the fault
        case 'variable'
            if rupture_depth > dip_depth(end)*1000
                rupture_depth = dip_depth(end)*1000;
            end
    end
    depth_distances=[0;centre_vertical;rupture_depth]; 
    given_slip_proportions=[slip_at_surface;1;0];
    
    % Calculating the depth of the middle of all the elements, works for both variable and planar dip cases
    for h=1:length(z_points(:,1))-1
	    calc_depth(h,1)=-(z_points_copy(h,1)+z_points_copy(h+1,1))/2;
    end
    calc_depth(calc_depth > rupture_depth) = []; % remove depths below the specified rupture depth   
    
    slip_proportions=interp1(depth_distances,given_slip_proportions,calc_depth);
    slip_dist=slip_proportions*slips;
        
    b=find((calc_depth <= rupture_depth)); % find the indicies that are with the area of slip down the fault
    slip_distribution(b(1):b(end),a(1):a(end))=slip_dist; % Putting slip_dist matrix into the zeros matrix previously set up
    if slip_distribution(1,1) == 0
        slip_distribution(1,1) = 0.000001; %assign a small value to the first element to fix the issue with Coulomb code
    end
end

%% simple triangular slip distribution (for backslip)
% create slip distribution for backslip
% simple approach: use max. slip rate and triangular distribution
% maximum slip spinner is used to enter slip rate (mm/yr)
% currently not supporting variable segmentation etc.
function slip_distribution = slipdist_triangular(maximum_slip,x_points)
    slip_distribution=zeros(size(x_points) - [1 1]);
    slip_rate = maximum_slip;
    half_len = linspace(0,slip_rate,round(size(slip_distribution,2)/2));
    comp_len = [half_len, flip(half_len)];
    if length(comp_len) > size(slip_distribution,2)
        comp_len(length(half_len)) = [];
    end
    for i = 1:size(slip_distribution,1)
        slip_distribution(i,:) = comp_len;
    end
end
