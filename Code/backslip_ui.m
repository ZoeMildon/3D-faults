function slip_distribution = backslip_ui(x_points,fault_name,grid_size)
%user interface to generate slip distribution for backslip method
%
% (M. Diercks, 05/2026)

backslip_fig = uifigure("Name",'Backslip Options','Position',[500 500 700 800],'Resize','off');
backslip_fig.UserData = false;
uilabel(backslip_fig,'Position',[10 700 550 20],'Text',strcat('Backslip slip distribution for: ',fault_name),'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');

%% set up plot
backslip_ax = uiaxes(backslip_fig,'Position',[50 100 640 250],'Color',[1 1 1],'Color',[.95 .95 .95]);
ylim(backslip_ax,[0 inf])
[slip_distribution, backslip_ax] = slipdist_triangular(1,x_points,backslip_ax,grid_size);
%% UI elements to calculate slip distribution
% uispinner to set generic triangular slip distribution
annualslip_lbl = uilabel(backslip_fig,'Position',[50 530 180 20],'Text','Annual slip (mm):');
set_annualslip = uispinner(backslip_fig,'Position',[150 530 60 20],'Step',0.1,'Limits',[0 inf],'Value',1,...
    'Tooltip','Annual slip (mm) = slip rate (mm/a):',...
    'ValueChangedFcn', @(src,event) localWrapper(src,event,x_points,backslip_ax,grid_size));

% uitable to set custom slip distribution values
numRows = 42;
backslip_vals = table(nan(numRows,1), nan(numRows,1), 'VariableNames', {'Distance (km)','Slip rate (mm/a)'});
backslip_uit = uitable(backslip_fig,'Position',[400 350 240 200],'Data',backslip_vals,'Enable','off','ColumnEditable',[true true],...
    'CellEditCallback',@(src,evt) localWrapper2(src,evt,x_points,backslip_ax,grid_size));

% radiobutton group for selecting slip distribution type
bg = uibuttongroup(backslip_fig,'Position',[50 560 600 60],'Title','Slip distribution type',...
    'BorderType','none',...
    'SelectionChangedFcn',@(src,evt) slipSelectionChanged(src,evt,set_annualslip, annualslip_lbl,backslip_uit));
uiradiobutton(bg,'Text','Triangular (default)','Position',[10 10 160 20],'Value',true,'Tag','T');
uiradiobutton(bg,'Text','Custom','Position',[360 10 160 20],'Value',false,'Tag','C');

% OK button
uibutton(backslip_fig,'Position',[325 50 50 30],'Text','OK','ButtonPushedFcn', @(s,e) onOK(backslip_fig));

uiwait(backslip_fig)
if isvalid(backslip_fig)
    delete(backslip_fig)
end

%% callback functions
function localWrapper(src,~,x_points,backslip_ax,grid_size) %callback for triangular slip distribution
    [slip_distribution, backslip_ax] = slipdist_triangular(src.Value,x_points,backslip_ax,grid_size);  %#ok<ASGLU> % store or use result
end

function localWrapper2(src,~,x_points,backslip_ax,grid_size) %callback for custom slip distribution
    [slip_distribution, backslip_ax] = slipdist_custom(src.Data,x_points,backslip_ax,grid_size);  %#ok<ASGLU> % store or use result
end

function onOK(backslip_fig)
    uiresume(backslip_fig);          % resume execution in the calling function
    fprintf(strcat('Slip distribution exported with negative slip. For back slip calculation in Coulomb choose \n',...
        'Functions >> Stress >> Calc. stress on Faults >> Coulomb for individual rake'))
end

%% radiobutton callback controlling UI elements
function slipSelectionChanged(src,~,set_annualslip,annualslip_lbl,backslip_uit)
    sel = src.SelectedObject;
    switch sel.Tag
        case 'T'
            disp('Backslip: Simple triangular slip distribution selected.')
            % enable the annual slip spinner when triangular slip distribution is selected
            set_annualslip.Enable = 'on';
            annualslip_lbl.Enable = 'on';
            %disable uitable
            backslip_uit.Enable = 'off';

        case 'C'
            disp('Backslip: Custom slip distribution selected.')
            % disable the annual slip spinner when custom distribution is selected
            set_annualslip.Enable = 'off';
            annualslip_lbl.Enable = 'off';
            % enable uitable for custom slip distribution
            backslip_uit.Enable = 'on';
            % backslip_uit.Data = backslip_vals; % Reset data for custom input
    end
end

%% Triangular slip distribution (for generic backslip)
% simple slip distribution to calculate interseismic stress loading using
% 'virtual negative displacements ('back-slip' method; Deng & Sykes, 1997)
function [slip_distribution, backslip_ax] = slipdist_triangular(max_slip,x_points,backslip_ax,grid_size)
    slip_distribution=zeros(size(x_points) - [1 1]);
    slip_rate = max_slip/1000; %converting to m
    % half_len = linspace(0,slip_rate,round(size(slip_distribution,2)/2));
    half_len = linspace(0.05*slip_rate,slip_rate,round(size(slip_distribution,2)/2)); %instead of zero, patches at the margin receive 5% of the max slip
    comp_len = [half_len, flip(half_len)];
    if length(comp_len) > size(slip_distribution,2)
        comp_len(length(half_len)) = [];
    end
    for i = 1:size(slip_distribution,1)
        slip_distribution(i,:) = comp_len;
    end
    imagesc(backslip_ax,slip_distribution)
    cb = colorbar(backslip_ax,'southoutside'); cb.Label.String = 'slip (mm)';
    axis(backslip_ax,'equal')
    xlabel(backslip_ax,'distance (km)')
    xt = backslip_ax.XTick;                             % numeric tick positions
    backslip_ax.XTickLabel = string(round(xt * grid_size));            % set new labels (string array)
    T=[1,1,1; 1,1,0; 1,0,0]; A=[0;1;2]; % white, yellow, red % Colour map for slip distribution
    colormap(backslip_ax,interp1(A,T,linspace(0,2,101)))
    
    %export slip distribution with negative values for back slip calculation via "Coulomb for individual rake"
    slip_distribution = -slip_distribution;
    assignin("base", "slip_distribution", slip_distribution);
end

%% Cutom slip distribution
function [slip_distribution, backslip_ax] = slipdist_custom(data,x_points,backslip_ax,grid_size)
    sortrows(data);
    slip_distribution=zeros(size(x_points) - [1 1]);
    xq = (1:size(slip_distribution,2)).*grid_size;
    nan_idx = any(isnan(table2array(data))')';
    data(nan_idx,:) = [];
    x = table2array(data(:,1)); %location
    x = unique([0; x; xq(end)]);
    v = table2array(data(:,2)); %slip
    v = [0; v; 0];
    v = v./1000; %converting to m
    slip_row = interp1(x,v,xq);
    slip_distribution = repmat(slip_row, size(slip_distribution,1), 1);% replicate slip_row to fill all rows of slip_distribution
    
    imagesc(backslip_ax,slip_distribution)
    cb = colorbar(backslip_ax,'southoutside'); cb.Label.String = 'slip (mm)';
    axis(backslip_ax,'equal')
    xlabel(backslip_ax,'distance (km)')
    xt = backslip_ax.XTick;                             % numeric tick positions
    backslip_ax.XTickLabel = string(round(xt * grid_size));            % set new labels (string array)
    T=[1,1,1; 1,1,0; 1,0,0]; A=[0;1;2]; % white, yellow, red % Colour map for slip distribution
    colormap(backslip_ax,interp1(A,T,linspace(0,2,101)))
    
    %export slip distribution with negative values for back slip calculation via "Coulomb for individual rake"
    slip_distribution = -slip_distribution;
    assignin("base", "slip_distribution", slip_distribution);
end

end
