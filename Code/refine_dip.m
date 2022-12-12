% Code to refine dip and depth values to get regular steps with specific gid size
%Inputs: list of depth values at intervals of 1km depth (vertical) + a max
%depth (currently uses the input from the previous versions)

function [dip_values,dip_depth] = refine_dip(dip_values_inp,grid_size)
    max_depth = length(dip_values_inp);
    if any(isnan(dip_values_inp))
        dip_values_inp = fillmissing(dip_values_inp,'linear','EndValues','nearest');
    end
    depths = nan(100,1);
    dips = nan(100,1);
    depths(1) = cosd(90-dip_values_inp(1)) * grid_size;
    D = depths(1); %depth of loop
    c = 1; %step counter
    while D < max_depth
        next_val = ceil(D);
        prev_val = floor(D);
        if next_val == length(dip_values_inp)
            dips(c) = dip_values_inp(end);
        else
            dips(c) = (next_val-D)*dip_values_inp(prev_val+1) + (D-prev_val) * dip_values_inp(next_val+1);
        end
        D = D + cosd(90-dips(c)) * grid_size;
        depths(c+1) = D;
        c = c+1;
    end
    depths = [0;depths]; %setting first val to 0 (surf)
    dips(isnan(dips)) = [];
    depths(isnan(depths)) = [];
    depths(end) = []; %del value > max_depth

    dip_values = dips;
    dip_depth = depths;
end