%tableChangedFcn: set vertical and horizontal centre, update table style and overview map
function [set_centre_hor,set_centre_ver,uit] = tableChangedfun(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input,set_centre_hor,set_centre_ver,set_seismoDepth)
    %set the horizontal spinner to faultlength/2 and the vertical spinner to depth/2
    idx = find(uit.Data.source_fault~=0);
    if nnz(idx) == 1
        len = uit.Data.len(idx)/2;
        if isnan(len) == true
            warndlg('No fault length given for source fault. Make sure to set a sensible horizontal centre or fault length')
        else
            set(set_centre_hor,'Value',len)
        end
        if isempty(uit.Data.depth{idx}) == true || strcmp(uit.Data.depth{idx},'seism. dep.') == true %no depth specified --> use seismo depth or aspect ratio 1
            if uit.Data.len(idx) >= set_seismoDepth.Value
                dep = set_seismoDepth.Value/2;
            else                                        %faults shorter than seismo_depth
                dep = (uit.Data.len(idx)*cosd(uit.Data.dip{idx}))/2;
            end
        else %use specified depth
            if isnumeric(uit.Data.depth{idx}) == false
                dep = str2double(uit.Data.depth{idx})/2;
            else
                dep = uit.Data.depth{idx}/2;
            end
        end
        set(set_centre_ver,'Value',dep);
    end
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