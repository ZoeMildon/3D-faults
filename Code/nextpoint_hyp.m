function [x_next,y_next,last_point,a] = nextpoint_hyp(x_start,y_start,grid_size,utm_lon,utm_lat,last_point,a)
%nextpoint_hyp: Calculating the next point along the fault, using the hypoteneuse of the
%grid size
%   Given a start point, a grid size (in metres) and an input set of
%   coordinates (in UTM, usually from a kml file), this code searches along
%   the fault to the SE to grid the fault according to the distance as the
%   crow flies.   

% Setting counters
found=0;
while_loop_count=0;
    while found<1
        hyp_dist=sqrt((utm_lon(a)-x_start)^2+(utm_lat(a)-y_start)^2);
        if hyp_dist>grid_size
            found=1; 
            if while_loop_count==0 % when hyp_dist>grid_size for the next closest utm coordinates, while loop hasn't run once
                p=grid_size/hyp_dist;
                % calculating the next coordinates
                if utm_lon(a)>=x_start
                    x_next=x_start+p*(utm_lon(a)-x_start);
                else
                    x_next=x_start-p*(x_start-utm_lon(a));
                end
                if utm_lat(a)<=y_start
                    y_next=y_start-p*(y_start-utm_lat(a));
                else
                    y_next=y_start+p*(utm_lat(a)-y_start);
                end
            else
                l1=[utm_lon(a-1),utm_lat(a-1),0]-[x_start,y_start,0]; % vector from start to point before hyp_length = grid_size
                l2=[utm_lon(a-1),utm_lat(a-1),0]-[utm_lon(a),utm_lat(a),0]; % vector from point before to point after where hyp_length = grid_size
                e=acos(dot(l1,l2)/(norm(l1)*norm(l2)))*180/pi; % gives angle between two vectors above
                if e ==180 % dealing with the case when the next two kml_points are located along the same strike
                    p=(grid_size-norm(l1))/norm(l2);
                else
                    f=rad2deg(asin(norm(l1)*sind(e)/grid_size)); % law of sines
                    g=180-e-f; % angles in a triangle
                    p=(grid_size*sind(g)/sind(e))/norm(l2); % ratio to describe how far between (a-1) and (a) the next coordinate will be
                end
                % calculating the next coordinates
                if utm_lon(a)>=utm_lon(a-1)
                    x_next=utm_lon(a-1)+p*(utm_lon(a)-utm_lon(a-1));
                else
                    x_next=utm_lon(a-1)-p*(utm_lon(a-1)-utm_lon(a));
                end
                if utm_lat(a)<=utm_lat(a-1)
                    y_next=utm_lat(a-1)-p*(utm_lat(a-1)-utm_lat(a));
                else
                    y_next=utm_lat(a-1)+p*(utm_lat(a)-utm_lat(a-1));
                end
            end
        else
            a=a+1;
            if a>length(utm_lon)  % setting the end of the grid to be the end of the kml fault trace
                found=1;
                x_next=utm_lon(end);
                y_next=utm_lat(end);
                last_point=1;
            end
        end
        while_loop_count=while_loop_count+1;
    end