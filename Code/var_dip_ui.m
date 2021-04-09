%test UI for variable dip
r = 1;
ui2 = uifigure('Name','Variable Dip','Position',[600 200 248 340],'Color',[.98 .98 .98]);

%create table that stores all variable dip values
%var_dip = table(t.fault_name,cell(length(t.fault_name),1),cell(length(t.fault_name),1));
%var_dip.Properties.VariableNames = {'fault_name','depth','dip'};

%interface elements
dips = table([1:10]',cell(10,1),cell(10,1));
dips.Properties.VariableNames = {'interval','depth','dip'};
uidip = uitable(ui2,'Position',[10 40 228 249],'Data',dips,'ColumnEditable',[false true true]);

dd = uidropdown(ui2,'Position',[10 300 228 30],'Items',t.fault_name,'ValueChangedFcn',@(dd,event) change_fault(dd,t,var_dip,uidip,r));

close_btn = uibutton(ui2,'push','Text','Close','Position',[75 10 98 25],'BackgroundColor',[.3 .8 .8],'ButtonPushedFcn',@(close_btn,event) close(ui2));


%function to get the correct table when selecting the Fault from dropdown
function [var_dip,uidip,r] = change_fault(dd,t,var_dip,uidip,r)
    var_dip.depth{r} = cell2mat(uidip.Data.depth)';
    var_dip.dip{r} = cell2mat(uidip.Data.dip)';
    var_dip
    r = find(strcmp(dd.Value,t.fault_name));
    r
    %temp_dips = table([1:10]',cell(10,1),cell(10,1));
    %temp_dips.Properties.VariableNames = {'interval','depth','dip'};
        if isempty(var_dip.depth{r}) == true
            uidip.Data.depth = cell(10,1);
            disp('empty')
        else
            for j = 1:length(var_dip.depth{r})
                uidip.Data.depth{j} = var_dip.depth{r}(j);
                disp('not empty')
            end
        end
        if isempty(var_dip.dip{r}) == true
            uidip.Data.dip = cell(10,1);
        else
            for j = 1:length(var_dip.dip{r})
                uidip.Data.dip{j} = var_dip.dip{r}(j);
            end
        end
end



