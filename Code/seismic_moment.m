% Calculating the seismic moment of the assigned slip distribution. Adapted from seis_moment Coulomb code.
amo=0.0;
switch geometry
    case 'variable'
        dip = nan(1,length(slip_distribution(:,1)));
        num_dip2 = [0,num_dip];
        for j = 1:length(num_dip2(1,:))-1
            dip(num_dip2(j)+1:num_dip2(j+1)) = dip_angle(j);
        end
end
for r=1:length(slip_distribution(:,1))
    for c=1:length(slip_distribution(1,:))
        shearmod = 800000 / (2.0 * (1.0 + 0.25));
        flength=sqrt((x_points(r,c)-x_points(r,c+1))^2+((y_points(r,c)-y_points(r,c+1))^2));
        slip=slip_distribution(r,c);
        switch geometry
            case 'constant'
                wfault=(z_points(r,c)-z_points(r+1,c))/sind(constant_dip);
            case 'variable'
                wfault=(z_points(r,c)-z_points(r+1,c))/sind(dip(r));
        end
        smo = shearmod * flength/1000 * wfault/1000 * slip * 1.0e+18;
        if isnan(smo) == false %for intersecting (cut) faults
            amo = amo + smo;
        end
    end
end
mw = (2/3) * log10(amo) - 10.7; %Hanks & Kanamori, 1979
%mw = (2/3) * (log10(amo) - 16.1);
disp(['   Total seismic moment = ' num2str(amo,'%6.2e') ' dyne cm (Mw = ', num2str(mw,'%4.2f') ')']);

