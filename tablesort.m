%sort table based on drop-down menu selection
function [uit] = tablesort(uit,sort_dd)
    switch sort_dd.Value
        case 'name A-Z'
            uit.Data = sortrows(uit.Data,1);
        case 'name Z-A'
            uit.Data = sortrows(uit.Data,1,'descend');
        case 'length asc.'
            uit.Data = sortrows(uit.Data,8);
        case 'length desc.'
            uit.Data = sortrows(uit.Data,8,'descend');
    end
    %update uitable style (same code as in tableChangedFun function)
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