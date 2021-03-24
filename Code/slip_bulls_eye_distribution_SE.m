%% Calculating a bulls eye (triangular) slip distribution given a maximum slip value

% Given a maximum slip value, which is assigned to the centre of the fault
% this script will calculate a triangular slip distribution (slip vs distance along the fault) which will then
% be applied to gridded fault
%slip_length=str2num(slip_length); % for use with generalised plotting code

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
if slip_length*1000>total_length
    errordlg('Given rupture length is longer than fault length!')
else
    if (slip_length*1000)/2<=grid_sizem
        warning('Given rupture length is close to the specified grid size, slip distribution may be rendered inaccurately. Make the grid size smaller.')
    end
    %middle_dist=total_length/2;
    no_slip=total_length-(slip_length*1000);

    L=length(x_points(1,:));
    % number of mid-grid points
    d2=grid_sizem/2;
    for i=round(no_slip/grid_sizem):L-3
        d(i)=d2+grid_sizem*i;
    end
    d=d(d~=0);
    
    length_last=sqrt((x_points(1,L-1)-x_points(1,L))^2+(y_points(1,L-1)-y_points(1,L))^2); % length of the last grid box

    distances=[(total_length-(slip_length)*1000),d,total_length];

    % Creating a trigular slip distribution at the surface
    distances=sort(distances);
    distances=distances.';
    
    slip_values=[0;maximum_slip;0];
    if centre_horizontal>0
        middle_dist=no_slip+centre_horizontal*1000;
        if centre_horizontal>slip_length
            errordlg('Location of maximum slip is outside the area that slips. No slip distribution calculated')
        end
    else
        middle_dist=grid_sizem*(L-2-(slip_length/2));
        middle_dist=(total_length-(slip_length*1000))+(slip_length*1000/2);
    end
    data_distances=[total_length-(slip_length*1000);middle_dist;total_length];

    slip=interp1(data_distances,slip_values,distances);
    slips=slip.';

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
    end
    switch geometry
        case 'constant'
            depth_distances=[0;middle_vertical;depth_extent];
            given_slip_proportions=[slip_at_surface;1;0];
            C=[grid_size_to_depth/2:grid_size_to_depth:(m-1)*grid_size_to_depth+(grid_size_to_depth/2)];
            calc_depth_prop=([0,C,depth_extent]).';
            slip_proportions=interp1(depth_distances,given_slip_proportions,calc_depth_prop);

            slips=[slips(2:(length(slips))-1)];
            slip_proportions=[slip_proportions(2:length(slip_proportions)-1)];

            slip_distribution=slip_proportions*slips;
            slip_distribution(isnan(slip_distribution))=0;
            slip_distribution=[zeros([length(slip_distribution(:,1)),length(x_points)-1-length(slip_distribution(1,:))]),slip_distribution];
        case 'variable'
            depth_distances=[0;middle_vertical;depth_extent];
            given_slip_proportions=[slip_at_surface;1;0];
            for h=1:length(z_points(:,1))-1
                calc_depth(h,1)=-(z_points(h,1)+z_points(h+1,1))/2;
            end
            slip_proportions=interp1(depth_distances,given_slip_proportions,calc_depth);

            slips=[slips(2:(length(slips))-1)];
    
            slip_distribution=slip_proportions*slips;
            slip_distribution(isnan(slip_distribution))=0;
            slip_distribution=[zeros([length(slip_distribution(:,1)),length(x_points(1,:))-1-length(slip_distribution(1,:))]),slip_distribution];
end
end

