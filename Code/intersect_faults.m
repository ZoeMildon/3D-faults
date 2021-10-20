% code to detect intersecting faults and modify x/y/z_points  
function [ccmatrix,x_points,y_points,z_points] = intersect_faults(x_points,y_points,z_points,ccmatrix,int_thresh)
    %find all values that are close to an existing x, y and z-coordinate triplet:
    for k = 1:numel(x_points)
        x_dist = abs(ccmatrix(:,1) - abs(x_points(k)));
        y_dist = abs(ccmatrix(:,2) - abs(y_points(k)));
        z_dist = abs(ccmatrix(:,3) - abs(z_points(k)));
        near_x = find(x_dist < (int_thresh.Value*1000));
        if isempty(near_x) == false
        for j = 1:length(near_x)
            if any(y_dist(near_x(j)) < (int_thresh.Value*1000)) == true && any(z_dist(near_x(j)) < (int_thresh.Value*1000)) == true
                [ccrow,cccol] = find(x_points-x_points(k) == 0);
                for n = 1:numel(ccrow)                    
                    x_points(ccrow(n):end,cccol(n)) = NaN; %delete intersecting points
                    y_points(ccrow(n):end,cccol(n)) = NaN;
                    z_points(ccrow(n):end,cccol(n)) = NaN;
                end
            end
        end
        end
    end
    %writing the cross-cut matrix that stores all existing x-y-z coordinate triplets
    last_elem = nnz(~isnan(ccmatrix(:,1)));
    for j = 1:(numel(x_points))%-nnz(isnan(x_points)))      %convert x_points, y_points and z_points to lists and attach them to the cross-cut matrix
        if isnan(x_points(j)) == false
            ccmatrix(last_elem + j,1) = abs(x_points(j));
            ccmatrix(last_elem + j,2) = abs(y_points(j)); %[abs could cause problems when the study area crosses the equator]
            ccmatrix(last_elem + j,3) = abs(z_points(j));
        elseif isnan(x_points(j))
            last_elem = last_elem-1;
        end
    end

    %refine the grid for less artifacts:
    [nr,nc] = size(x_points);
    mx_points = nan((nr-1)*(nc-1),1);
    my_points = nan((nr-1)*(nc-1),1);
    mz_points = nan((nr-1)*(nc-1),1);
    np = 1;
    for r = 1:nr-1
        for c = 1:nc-1
            if x_points(r,c) > x_points(r+1,c+1)
                mx_points(np) = x_points(r,c) + (x_points(r+1,c+1)-x_points(r,c))/2;
            else
                mx_points(np) = x_points(r,c) - (x_points(r,c)-x_points(r+1,c+1))/2;
            end
            if y_points(r,c) > y_points(r+1,c+1)
                my_points(np) = y_points(r,c) + (y_points(r+1,c+1)-y_points(r,c))/2;
            else
                my_points(np) = y_points(r,c) - (y_points(r,c)-y_points(r+1,c+1))/2;
            end
            mz_points(np) = z_points(r,c) - abs(z_points(r+1,c+1)-z_points(r,c))/2;
            np = np+1;
        end
    end
    last_idx = nnz(~isnan(ccmatrix(:,1)));
    mx_points(isnan(mx_points)) = [];
    my_points(isnan(my_points)) = [];
    mz_points(isnan(mz_points)) = [];
    ccmatrix(last_idx+1:last_idx+numel(mx_points),1) = mx_points;
    ccmatrix(last_idx+1:last_idx+numel(mx_points),2) = my_points;
    ccmatrix(last_idx+1:last_idx+numel(mx_points),3) = abs(mz_points);
    %clearvars ccrow cccol ccidx x_dist y_dist z_dist near_x nr nc np mx_points my_points mz_points
    %scatter3(ccmatrix(1:last_idx,1),ccmatrix(1:last_idx,2),-ccmatrix(1:last_idx,3),'k','filled'); %plot the intersection grid (for debugging)
end