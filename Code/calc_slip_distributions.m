% code to select and calculate slip distributions (functions below)

slip_type = 'bulls_eye'; % comment what you need (could be coupled with a UI element (e.g. a dropdown))
%slip_type = 'simple_backslip';

%% fetch variables:
if input_check == false
    return
end
start_slip = sp_start.Value;
end_slip = sp_end.Value;
rupt_top = sp_rupt_top.Value*1000;
rupt_bot = sp_rupt_bot.Value*1000;
max_slip = set_maxSlip.Value;
surf_slip = set_surfSlip.Value / 100;
centre_hor = round(sl_centre_hor.Value)*1000;
centre_ver = sp_centre_ver.Value*1000;
%% check slip type & call functions
switch slip_type
    case 'bulls_eye'
        slip_distribution = slipdist_bulls_eye(start_slip,end_slip,rupt_top,rupt_bot,grid_sizem,max_slip,surf_slip,centre_hor,centre_ver,x_points,y_points,z_points,z_points_copy,geometry,dip_depth);
    case 'simple_backslip'
        slip_distribution = slipdist_triangular(max_slip,x_points);
end

%% plot slip distribution preview
imagesc(slip_ax,slip_distribution)

%% Calculating a bulls eye (triangular) slip distribution given a maximum slip value
% Given a maximum slip value, which is assigned to the centre of the fault this script will calculate a 
% triangular slip distribution (slip vs distance along the fault) which will then be applied to gridded fault.

% Written 07/04/21 by Zoe Mildon - to reduce complexity of calculating slip distribution when only part of the fault ruptures. 
% Start and end points (in km) of ruptures are specified.
% Identical for both variable and planar dip, and better functionality for changing the location of maximum slip

% adjusted version for new user interface - updated 08/2023
function slip_distribution = slipdist_bulls_eye(start_slip,end_slip,rupt_top,rupt_bot,grid_sizem,max_slip,surf_slip,centre_hor,centre_ver,x_points,y_points,z_points,z_points_copy,geometry,dip_depth)
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
    
    col_idx=find((distances >= (start_slip*1000)) & (distances <= (end_slip*1000))); %find the indices of slip distribution that are within the area of slip along the fault
    slip_distances=distances(col_idx);
    
    % Calculate the slip distribution for the specific section of the fault
    slip_distances=sort(slip_distances);
    slip_distances=slip_distances.';
    
    slip_values=[0;max_slip;0];
        
    data_distances=[start_slip*1000;centre_hor;end_slip*1000];
    slipsx=interp1(data_distances,slip_values,slip_distances);
    slips=slipsx.';
    
    % Extending the slip distribution to depth, with a triangular profile
    switch geometry %make sure that rupture depth is not larger than the deepest portion of the fault
        case 'variable'
            if rupt_bot > dip_depth(end)*1000
                rupt_bot = dip_depth(end)*1000;
            end
    end
    depth_distances=[rupt_top;centre_ver;rupt_bot]; 
    if rupt_top == 0
        given_slip_proportions=[surf_slip;1;0];
    else
        given_slip_proportions=[0;1;0];
    end
    
    % Calculating the depth of the middle of all the elements, works for both variable and planar dip cases
    for h=1:length(z_points(:,1))-1
	    mid_depths(h,1)=-(z_points_copy(h,1)+z_points_copy(h+1,1))/2;
    end  
    calc_depth = mid_depths(mid_depths > rupt_top & mid_depths < rupt_bot); %remove depths between rupture top and rupture bottom
    
    slip_proportions=interp1(depth_distances,given_slip_proportions,calc_depth);
    slip_dist=slip_proportions*slips;
    
    row_idx=find(calc_depth(1)==mid_depths);
    slip_distribution(row_idx:(row_idx+length(calc_depth)-1),col_idx(1):col_idx(end))=slip_dist; % Putting slip_dist matrix into the zeros matrix previously set up
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
