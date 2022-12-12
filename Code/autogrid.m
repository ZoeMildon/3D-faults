%calculate well-fitting grid extends (Auto button):
function [minx_txt,maxx_txt,miny_txt,maxy_txt] = autogrid(uit,fault_input,minx_txt,maxx_txt,miny_txt,maxy_txt,set_margin,axe)
    rows = find(uit.Data.plot);
    coords = table(fault_input.X,fault_input.Y);
    coords.Properties.VariableNames = {'X','Y'};
    for i = 1:length(uit.Data.plot) %fetching coordiniates from input table
        idx = find(strcmp(uit.Data.fault_name(i),fault_input.fault_name));
        coords.X(i) = fault_input.X(idx);
        coords.Y(i) = fault_input.Y(idx);
    end
    faults = uit.Data(rows,:);
    faults.X = coords.X(rows);
    faults.Y = coords.Y(rows);
    dim = zeros(length(faults.X),4);
    for i = 1:length(faults.X)
       dim(i,1)= min(faults.X{i});
       dim(i,2)= max(faults.X{i});
       dim(i,3)= min(faults.Y{i});
       dim(i,4)= max(faults.Y{i});
    end
    width = max(dim(:,2)) - min(dim(:,1));
    height = max(dim(:,4)) - min(dim(:,3));
    add = max([width height]);
    mrg = set_margin.Value/100;
    set(minx_txt,'Value', num2str(round((min(dim(:,1)) - mrg * add),-3)/1000));
    set(maxx_txt,'Value', num2str(round((max(dim(:,2)) + mrg * add),-3)/1000));
    set(miny_txt,'Value', num2str(round((min(dim(:,3)) - mrg * add),-3)/1000));
    set(maxy_txt,'Value', num2str(round((max(dim(:,4)) + mrg * add),-3)/1000));
    map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input);
end