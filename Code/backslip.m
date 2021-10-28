% create slip distribution for backslip
% simple approach: use max. slip rate and triangular distribution

%[slip_file,slip_path] = uigetfile('*.txt','Select source for slip rates');
function [slip_distribution,maximum_slip] = backslip(fault_name,slip_distribution,slip_file,slip_path)
slip_rates = readtable(fullfile(slip_path,slip_file),'Delimiter',';');

slip_idx = find(strcmp(slip_rates{:,1},fault_name)==1);
max_slip = slip_rates.max_slip_rate(slip_idx)/1000;
half_len = linspace(0,max_slip,round(size(slip_distribution,2)/2));
comp_len = [half_len, flip(half_len)];
if length(comp_len) > size(slip_distribution,2)
    comp_len(length(half_len)) = [];
end
for i = 1:size(slip_distribution,1)
    slip_distribution(i,:) = comp_len;
end
%clearvars slip_idx max_slip half_len compl_len
maximum_slip = max(slip_rates.max_slip_rate)/1000;
end