%% calculate preliminary seismic moment in slip_options panel
%calc slip distribution
calc_slip_distributions
% remove (set as NaN) all patches from the slip distribution that intersect with another fault:
for r = 1:length(slip_distribution(:,1))
    for c = 1:length(slip_distribution(1,:))
        if isnan(x_points(r,c)) || isnan(x_points(r,c+1)) || (isnan(x_points(r+1,c)) && isnan(x_points(r+1,c+1)))
            slip_distribution(r,c) = NaN; %#ok<SAGROW>
        end            
    end
end
% calc seismic moment and display
seismic_moment
msgbox(sprintf('Total seismic moment = %6.2e dyne cm | Mw %.2f', amo, mw))