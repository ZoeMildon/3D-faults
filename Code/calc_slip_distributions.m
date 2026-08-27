function slip_distribution = calc_slip_distributions(input_check,slip_distribution,x_points,y_points,z_points,grid_size,geometry,dip_depth,sl_centre_hor,sp_end,sp_start,sp_rupt_top,sp_centre_ver,sp_rupt_bot,set_surfSlip,set_maxSlip,sliptype_dd)
% code to select and calculate slip distributions (functions below)

%% fetch variables:
if input_check == false
    return
end
if sliptype_dd.Value(1) ~= 'C'
    start_slip = sp_start.Value;
    end_slip = sp_end.Value;
    rupt_top = sp_rupt_top.Value*1000;
    rupt_bot = sp_rupt_bot.Value*1000;
    max_slip = set_maxSlip.Value;
    surf_slip = set_surfSlip.Value / 100;
    centre_hor = round(sl_centre_hor.Value)*1000;
    centre_ver = sp_centre_ver.Value*1000;
end
%% check slip type & call functions
switch sliptype_dd.Value
    case 'Bulls-eye (for normal/thrust)'
        slip_distribution = slipdist_bulls_eye(true,start_slip,end_slip,rupt_top,rupt_bot,grid_size,max_slip,surf_slip,centre_hor,centre_ver,x_points,y_points,z_points,geometry,dip_depth);
    case 'Elongated bulls-eye (for strike-slip)'
        slip_distribution = slipdist_bulls_eye(false,start_slip,end_slip,rupt_top,rupt_bot,grid_size,max_slip,surf_slip,centre_hor,centre_ver,x_points,y_points,z_points,geometry,dip_depth);
    case 'Custom (csv-import)'
        [slip_distribution,x_points,y_points,z_points] = slipdist_custom(x_points,y_points,z_points);
end

%% plot slip distribution preview
% imagesc(slip_ax,slip_distribution)

%% Bulls eye (concentric) slip distribution for normal/thrust
% Given a maximum slip value, which is assigned to the centre of the fault this script will calculate a 
% triangular slip distribution (slip vs distance along the fault) which will then be applied to gridded fault.

function slip_distribution = slipdist_bulls_eye(dipslip,start_slip,end_slip,rupt_top,rupt_bot,grid_size,max_slip,surf_slip,centre_hor,centre_ver,x_points,y_points,z_points,geometry,dip_depth)
    slip_distribution=zeros(size(x_points) - [1 1]); % generates a blank matrix for slip_distribution to be put into
    grid_size = grid_size*1000;
    L=length(x_points(1,:));
    d2=grid_size/2;
    if length(x_points(:,1))>=3
        for i=1:L-3
            d(i)=d2+grid_size*i;
        end
    end
    
    % Calculate the distances of all the mid-points of elements
    length_last=sqrt((x_points(1,L-1)-x_points(1,L))^2+(y_points(1,L-1)-y_points(1,L))^2); % length of the last grid box
    if length(x_points(1,:))>3
	    distances=[d2,d,((L-2)*grid_size+length_last/2)];
    elseif length(x_points(1,:))==3
	    distances=[d2,((L-2)*grid_size+length_last/2)];
    else
	    distances=round(sl_centre_hor.Value)*1000;
    end
    
    col_idx=find((distances >= (start_slip*1000)) & (distances <= (end_slip*1000))); %find the indices of slip distribution that are within the area of slip along the fault
    slip_distances=distances(col_idx);
    
    % Calculate the slip distribution for the specific section of the fault
    slip_distances=sort(slip_distances);
    slip_distances=slip_distances.';
    
    if dipslip == true %deciding between standard dip-slip slip distributions and elongated for strike-slip
        slip_values=[0;max_slip;0];
        data_distances=[start_slip*1000;centre_hor;end_slip*1000];
    elseif dipslip == false
        slip_values=[0;max_slip;max_slip;0];
        rupture_length=(end_slip*1000)-(start_slip*1000);
        data_distances=[start_slip*1000;(start_slip*1000)+0.1*rupture_length;(end_slip*1000)-0.1*rupture_length;end_slip*1000]; % create elongated slip distribution for strike-slip earthquakes
    end
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
	    mid_depths(h,1)=-(z_points(h,1)+z_points(h+1,1))/2;
    end  
    
    %remove depths between rupture top and rupture bottom
    patch_dip=nan(numel(mid_depths,1)); %calc dip for each patch (for variable dip faults)
    patch_depth=nan(numel(mid_depths,1));
    sum_depth=zeros(numel(mid_depths,1));
    for n = 1:numel(mid_depths)
        patch_dip(n) = 90-acosd(abs((z_points(n+1,1)-z_points(n,1)))/grid_size);
        patch_depth(n) = cosd(90-patch_dip(n))*grid_size;
        sum_depth(n+1) = patch_depth(n) + sum_depth(n);
    end
    rupt_bot_tot = rupt_bot; rupt_top_tot = rupt_top; %total depth of rupture top/bottom
    % if rupt_bot > max(sum_depth) %removed, can't find the bug ... (MD 05/2026)
    %     fprintf('The code assumes a fault width/length ratio of max. 1. Due to fault length and dip max. rupture depth is %.0f m\n',max(sum_depth))
    %     rupt_bot_tot = max(sum_depth);
    % end
    if rupt_top > max(sum_depth)
        fprintf('Rupture top and bottom adjusted to %.0f and %.0f m\n',max(sum_depth)-2*grid_size,max(sum_depth))
        rupt_bot_tot = max(sum_depth);
        rupt_top_tot = max(sum_depth)-2*grid_size;
        depth_distances=[rupt_top_tot;rupt_top_tot+grid_size;rupt_bot_tot]; 
    end
    calc_depth = mid_depths(mid_depths > rupt_top_tot & mid_depths < rupt_bot_tot); %remove depths between rupture top and rupture bottom
    
    %interpolate slip distribution onto grid
    slip_proportions=interp1(depth_distances,given_slip_proportions,calc_depth);
    slip_dist=slip_proportions*slips;
    
    row_idx=find(calc_depth(1)==mid_depths);
    slip_distribution(row_idx:(row_idx+length(calc_depth)-1),col_idx(1):col_idx(end))=slip_dist; % Putting slip_dist matrix into the zeros matrix previously set up
end

%% custom slip distribution from csv file
%import a custom slip distribution; must be imported as a table of values; 
%grid size of the 3D-Fault is adjusted to the number of rows/columns of the slip distribution
%add zeros to the slip distribution to achieve partial rupture of a fault

function [slip_distribution,x_points,y_points,z_points] = slipdist_custom(x_points,y_points,z_points)
    [file,path] = uigetfile({'*.xlsx;*.xls','Excel Files (*.xlsx, *.xls)';'*.csv','csv file'; '*.*','All Files'}, 'Select csv or excel file');
    custom_slip = readmatrix(fullfile(path,file));
    if all(custom_slip(1,1:end) == 1:size(custom_slip,2))
        custom_slip(1,:) = []; %discard top line
        disp('Ignoring first line (header) of custom slip file.')
    end
    % resample x_points, Y_points, z_points to match size of custom_slip (not impacting fault dimensions)
    if ~all(size(x_points)-1 == size(custom_slip))
    [X,Y] = meshgrid(1:size(x_points,2),1:size(x_points,1));
    [Xq,Vq] = meshgrid(linspace(1,size(x_points,2),size(custom_slip,2)+1), linspace(1,size(x_points,1),size(custom_slip,1)+1));
    x_points = interp2(X, Y, x_points, Xq, Vq, 'linear');
    y_points = interp2(X, Y, y_points, Xq, Vq, 'linear');
    z_points = interp2(X, Y, z_points, Xq, Vq, 'linear');
    end
    slip_distribution = custom_slip;
    assignin('base',"x_points",x_points)
    assignin('base',"y_points",y_points)
    assignin('base',"z_points",z_points)
end

end