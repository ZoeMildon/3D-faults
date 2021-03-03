function [x_next,y_next,last_point,a] = nextpoint_hyp2_ZKM(x_start,y_start,grid_size,kml_utm_lon,kml_utm_lat,b)
%nextpoint_hyp: Calculating the next point along the fault, using the hypoteneuse of the
%grid size
%   Given a start point, a grid size (in metres) and an input set of
%   coordinates (in UTM, usually from a kml file), this code searches along
%   the fault to the SE to grid the fault according to the distance as the
%   crow flies.   

% Finding the next value in the kml file which is greater than the start
% location
    kml_cut=kml_utm_lon;

for j=1:b-1
    kml_cut(j)=0;
end
a=find(kml_cut>0,1,'first');

if a~=b && isempty(a)==1
    a=find(kml_utm_lon>x_start,1,'first'); % fixes for when grid_size is smaller than the first kml segment
end

L=length(kml_utm_lon);

if isempty(a)==1  % setting the end of the grid to be the end of the kml fault trace
   found=1;
   x_next=kml_utm_lon(L);
   y_next=kml_utm_lat(L);
   last_point=1;
else
        
found=0;
last_point=0;

% setting a counter, used for when the distance between kml_utm(1) and
% kml_utm(2) is greater than grid_size
counter=0;

while found<1
    hyp_dist=sqrt((kml_utm_lon(a)-x_start)^2+(kml_utm_lat(a)-y_start)^2);
    if hyp_dist>grid_size
        found=1;
       if counter==0
%             x_next=x_start+(grid_size/hyp_dist)*(kml_utm_lon(a)-x_start);
%             y_next=y_start+(grid_size/hyp_dist)*(kml_utm_lat(a)-y_start); 
            if x_start<=kml_utm_lon(a)
                x_next=x_start+(grid_size/hyp_dist)*(kml_utm_lon(a)-x_start);
            else
                x_next=x_start-(grid_size/hyp_dist)*(x_start-kml_utm_lon(a));
            end
            if y_start>=kml_utm_lat(a)
                y_next=y_start-(grid_size/hyp_dist)*(y_start-kml_utm_lat(a));
            else
                y_next=y_start+(grid_size/hyp_dist)*(kml_utm_lat(a)-y_start);
            end
            a=a;
    else
            % calculate the coordinates of x_next and y_next. Has an issue with
            % horizontal lines.
            l1=[kml_utm_lon(a-1),kml_utm_lat(a-1),0]-[x_start,y_start,0];
            l2=[kml_utm_lon(a-1),kml_utm_lat(a-1),0]-[kml_utm_lon(a),kml_utm_lat(a),0];
            e=acos(dot(l1,l2)/(norm(l1)*norm(l2)))*180/pi;
            f=rad2deg(asin(norm(l1)*sind(e)/grid_size));
            g=180-e-f;
            t=(grid_size*sind(g)/sind(e))/norm(l2);
%             x_next=kml_utm_lon(a-1)+t*(kml_utm_lon(a)-kml_utm_lon(a-1));
%             y_next=kml_utm_lat(a-1)+t*(kml_utm_lat(a)-kml_utm_lat(a-1));
            
           if kml_utm_lon(a)>=kml_utm_lon(a-1)
               x_next=kml_utm_lon(a-1)+t*(kml_utm_lon(a)-kml_utm_lon(a-1));
           else
               x_next=kml_utm_lon(a-1)-t*(kml_utm_lon(a-1)-kml_utm_lon(a));
           end
           if kml_utm_lat(a)<=kml_utm_lat(a-1)
               y_next=kml_utm_lat(a-1)-t*(kml_utm_lat(a-1)-kml_utm_lat(a));
           else
               y_next=kml_utm_lat(a-1)+t*(kml_utm_lat(a)-kml_utm_lat(a-1));
           end
            % check that the x_next,y_next are a grid_size away from the
            % x_start,y_start. BUT be aware of machine code error (hence it is >=0.1, not ==grid_size)
            if abs((sqrt((x_next-x_start)^2+(y_next-y_start)^2)-grid_size)/grid_size)>=0.1
                disp('Calculation not worked, the next point hasnt been calculated correctly')
                grid_size_calculated=sqrt((x_next-x_start)^2+(y_next-y_start)^2);
            else
            end
            
    end
    else
        a=a+1;
        if a>L  % setting the end of the grid to be the end of the kml fault trace
            found=1;
            x_next=kml_utm_lon(L);
            y_next=kml_utm_lat(L);
            last_point=1;
        else
        end
end
    counter=counter+1;
end
        end
end

