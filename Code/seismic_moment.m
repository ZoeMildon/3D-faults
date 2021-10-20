% Calculating the seismic moment of the the assigned slip distribution
% created. Adapted from seis_moment Coulomb code.
amo=0.0;
for i=1:length(slip_distribution(:,1))
    for j=1:length(slip_distribution(1,:))
        shearmod = 800000 / (2.0 * (1.0 + 0.25));
        flength=sqrt((x_points(i,j)-x_points(i,j+1))^2+((y_points(i,j)-y_points(i,j+1))^2));
        wfault=(z_points(i,j)-z_points(i+1,j))/sind(constant_dip);
        slip=slip_distribution(i,j);
        smo = shearmod * flength/1000 * wfault/1000 * slip * 1.0e+18;
        if isnan(smo) == false %for intersecting (cut) faults
            amo = amo + smo;
        end
    end
end
mw = (2/3) * log10(amo) - 10.7;
%mw = (2/3) * (log10(amo) - 16.1);
disp(['   Total seismic moment = ' num2str(amo,'%6.2e') ' dyne cm (Mw = ', num2str(mw,'%4.2f') ')']);

% add-on for display in UI:
seis_txt = strcat('Total seismic moment = ',num2str(amo,'%6.2e'),' dyne cm (Mw = ',num2str(mw,'%4.2f'),')');
infotext = [seis_txt,infotext];
%seis_disp = uitextarea(tab3,'Position',[20 610 400 30],'Editable','off','Value',seis_txt,'FontSize',14);
clearvars amo shearmod flength wfault slip smo mw