%tableChangedFcn: set vertical and horizontal centre, update table style and overview map
function uit = tableChangedfun(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input)
    %plot the overview map
    map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input);
    
    %set style for table rows
    s = uistyle('BackgroundColor',[.3 .8 .3]);
    s2 = uistyle('BackgroundColor',[.95 .5 .3]);
    removeStyle(uit);
    for i = 1:length(uit.Data.dip)
        if any(isnan(uit.Data.dip{i})) || isnan(uit.Data.rake(i)) || isnan(uit.Data.dip_dir(i)) || ismissing(uit.Data.rake(i)) || ismissing(uit.Data.dip_dir(i)) %highlight rows with missing data
            uit.Data.plot(i) = false;
            addStyle(uit,s2,'row',i);
        elseif ~isnumeric(uit.Data.dip{i}) %highlight variable dip faults
            addStyle(uit,s,'row',i);            
        end
    end
end