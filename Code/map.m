%plot/update overview map:
function axe = map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input)
    min_x = str2double(minx_txt.Value{1});
    max_x = str2double(maxx_txt.Value{1});
    min_y = str2double(miny_txt.Value{1});
    max_y = str2double(maxy_txt.Value{1});
    %set(axe,'HandleVisibility','on');
    cla(axe)
    hold(axe,'ON')
    rectangle(axe,'Position',[min_x min_y max_x-min_x max_y-min_y],'FaceColor',[.85 .95 .7])
    axis(axe, 'equal')
    title(axe, 'Fault Network Map')
    xlabel(axe,'UTM x')
    ylabel(axe,'UTM y')
    coords = table(fault_input.X,fault_input.Y);
    coords.Properties.VariableNames = {'X','Y'};
    for i = 1:length(uit.Data.plot)
        idx = find(strcmp(uit.Data.fault_name(i),fault_input.fault_name));
        coords.X(i) = fault_input.X(idx);
        coords.Y(i) = fault_input.Y(idx);
    end
    for i = 1:length(coords.X)
        if uit.Data.plot(i) == true && uit.Data.source_fault(i) ~= 1
            plot(axe,cell2mat(coords.X(i))/1000,cell2mat(coords.Y(i))/1000,'k')
        elseif uit.Data.plot(i) == true && uit.Data.source_fault(i) ~= 0
            plot(axe,cell2mat(coords.X(i))/1000,cell2mat(coords.Y(i))/1000,'r','LineWidth',2)
            xval=coords.X{i}(~isnan(coords.X{i}));
            yval=coords.Y{i}(~isnan(coords.Y{i}));
            scatter(axe,(xval(1))/1000,(yval(1))/1000,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','w')
            scatter(axe,(xval(end))/1000,(yval(end))/1000,'Marker','o','MarkerFaceColor','w','MarkerEdgeColor','k')
        end
    end
    %set(axe,'HandleVisibility','off');
end