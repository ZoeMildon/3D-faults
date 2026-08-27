% code to detect intersecting faults and modify x/y/z_points
% grid is refined (densified) and stored in ccmatrix
% updated 05/2026; M. Diercks
function [ccmatrix,x_points,y_points,z_points] = intersect_faults(x_points,y_points,z_points,ccmatrix,grid_size,ii,faults,intersect_dd)
fault_id = ii; %assigns a specific id to each fault
min_distance = grid_size/2.35; %all patches closer than 1/3 of a grid size are removed

%find all values that are close to an existing x, y and z-coordinate triplet:
for k = 1:numel(x_points)
    x_dist = abs(ccmatrix(:,1) - abs(x_points(k)));
    y_dist = abs(ccmatrix(:,2) - abs(y_points(k)));
    z_dist = abs(ccmatrix(:,3) - abs(z_points(k)));
    near_x = find(x_dist < (min_distance*1000)); %x coords closer than threshold
    if isempty(near_x) == false
        for j = 1:length(near_x)
            if any(y_dist(near_x(j)) < (min_distance*1000)) == true && any(z_dist(near_x(j)) < (min_distance*1000)) == true %check if y and z points are also nearer than threshold
                [ccrow,cccol] = find(x_points-x_points(k) == 0);
                if strcmp(intersect_dd.Value,'by priority') == true
                    %identify the fault patches that interfere:
                    near_y = find(y_dist < (min_distance*1000));
                    near_z = find(z_dist < (min_distance*1000));
                    near_idx = nan(length(near_x),1);
                    for c = 1:length(near_x)
                        if (any(near_y == near_x(c)) && any(near_z == near_x(c))) == true
                            near_idx(c) = near_x(c);
                        end
                    end
                    near_idx(isnan(near_idx)) = [];
                    int_list = ccmatrix(near_idx,4); %identifies the fault_id of the intersecting faults
                    %get the single fault ids from the int_list:
                    for n = 1:fault_id
                        if any(int_list == n)
                            if faults.priority(fault_id) > faults.priority(n)
                                [x_points,y_points,z_points] = delete_patches(x_points,y_points,z_points,ccrow,cccol);
                            end
                        end
                    end
                else
                    [x_points,y_points,z_points] = delete_patches(x_points,y_points,z_points,ccrow,cccol);
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
        ccmatrix(last_elem + j,4) = fault_id;
    elseif isnan(x_points(j))
        last_elem = last_elem-1;
    end
end

%refine the grid of x_points, y_points and z_points
[X,Y] = meshgrid(1:size(x_points,2),1:size(x_points,1));
[Xq,Yq] = meshgrid(1:0.25:size(x_points,2),1:0.25:size(x_points,1));
mx_points = interp2(X,Y,x_points,Xq,Yq);
my_points = interp2(X,Y,y_points,Xq,Yq);
mz_points = interp2(X,Y,z_points,Xq,Yq);
last_idx = nnz(~isnan(ccmatrix(:,1)));
mx_points(isnan(mx_points)) = [];
my_points(isnan(my_points)) = [];
mz_points(isnan(mz_points)) = [];
ccmatrix(last_idx+1:last_idx+numel(mx_points),1) = mx_points(1:end);
ccmatrix(last_idx+1:last_idx+numel(mx_points),2) = my_points(1:end);

ccmatrix(last_idx+1:last_idx+numel(mx_points),3) = abs(mz_points(1:end));
ccmatrix(last_idx+1:last_idx+numel(mx_points),4) = fault_id;
% scatter3(fax,ccmatrix(1:last_idx,1),ccmatrix(1:last_idx,2),-ccmatrix(1:last_idx,3),5,'k','filled','o'); %plot the intersection grid (FOR DEBUGGING)
    % add fax to function input to make this line work

    function [x_points,y_points,z_points] = delete_patches(x_points,y_points,z_points,ccrow,cccol)
        for a = 1:numel(ccrow)
            x_points(ccrow(a):end,cccol(a)) = NaN; %delete intersecting points
            y_points(ccrow(a):end,cccol(a)) = NaN;
            z_points(ccrow(a):end,cccol(a)) = NaN;
        end
    end
end

