
%% Writing out the beginning of the Coulomb output file
format long
grid_sizem=grid_size*1000;
seismo_depthm=seismo_depth*1000;
rupture_depthm=rupture_depth*1000;
output_data_path='Output_files/filename_slipm_grid_sizekm.inr';
gkm=num2str(grid_size);
slip=num2str(maximum_slip);
output_data_file=strrep(output_data_path,'filename',filename);
output_data_file=strrep(output_data_file,'grid_size',gkm);
output_data_file=strrep(output_data_file,'slip',slip);

fid=fopen(output_data_file, 'wt');
if fid > 0
% comments about the data file
fprintf (fid,'This is a file created by rectangularly gridding the faults.\n');
fprintf (fid,'Fault with slip is %s, the grid size of faults is %2.0f km\n',fault_slip_name,(grid_size));
fprintf (fid,'#reg1=  0  #reg2=  0   #fixed= 1000  sym=  1\n');
fprintf (fid,' PR1=       .250      PR2=       .250    DEPTH=        5.0\n');
fprintf (fid,'  E1=   0.800000E+06   E2=   0.800000E+06\n');
fprintf (fid,'XSYM=       .000     YSYM=       .000\n');
fprintf (fid,'FRIC=       .400\n');
fprintf (fid,'S1DR=    19.0001     S1DP=     -0.0001    S1IN=    100.000     S1GD=   .000000\n');
fprintf (fid,'S3DR=    89.9999     S3DP=      89.999    S3IN=     30.000     S3GD=   .000000\n');
fprintf (fid,'S2DR=   109.0001     S2DP=     -0.0001    S2IN=      0.000     S2GD=   .000000\n');
fprintf (fid,'\n');
fprintf (fid,'  #   X-start    Y-start     X-fin      Y-fin   Kode  rake    net slip   dip angle     top      bot\n');
fprintf (fid,'xxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx\n');

%% Import the text file containing all the fault names
disp('Select the text file with the list of faults')
[fault_filename,fault_filepath]=uigetfile('*.txt');
if fault_filename==0
    errordlg('No file selected')
else
% disp('Select the folder where the fault kml files are located')
% [kml_folder]=uigetdir('');
kml_folder='Fault_traces';
fault_names=importdata([fault_filepath fault_filename]);
for i=1:length(fault_names)
    fault_name=fault_names{i};
    kml_path='folder/fault_name.kml';
    kml_file=strrep(kml_path,'folder',kml_folder);
    kml_file=strrep(kml_file,'fault_name',fault_name);
    
    % Import kml file and convert to UTM coordinates
    fileid=fopen(kml_file);
    if fileid < 0
        msgkml=sprintf('Cannot find the kml file for %s.\nFault not plotted.',fault_name);
        errordlg(msgkml)
    else
    [lat,lon]=read_kml(kml_file);
    [utm_lon,utm_lat] = wgs2utm(lat,lon,UTM_zone,UTM_letter);
    if utm_lon(1)<utm_lon(end)
    else
        %disp('flipped coordinates')
        utm_lon=flip(utm_lon);
        utm_lat=flip(utm_lat);
    end
    % Adding extra point to enable calculation of the next point
    I=eye(length(utm_lat));
    b=zeros(1,length(utm_lat));
    row_no=2;
    I(1:row_no-1,:)=I(1:row_no-1,:);
    tp =I(row_no:end,:);
    I(row_no,:)=b;
    I(row_no+1:end+1,:)=tp;
    utm_lat=I*utm_lat;
    utm_lat(2)=utm_lat(1)+0.1;
    utm_lon=I*utm_lon;
    utm_lon(2)=utm_lon(1)+0.1;
    % Grid the fault, starting at the NW end, by grid_size (as the crow flies)
    last_point=0;
    n=1;
    utm_x(1)=utm_lon(1);
    utm_y(1)=utm_lat(1);
    b=0;
    % Finding the next grid point by hypotenuse method
    while last_point<1
        [utm_x(n+1),utm_y(n+1),last_point,a]=nextpoint_hyp(utm_x(n),utm_y(n),grid_sizem,utm_lon,utm_lat,b);
        n=n+1;
        b=a;
    end
    %% Extending the fault to depth
    utm_z(:,length(utm_x))=0; % Assuming all faults come to the surface (0m depth)
   
    % extracting the dip profile
        [dip_depth,dip_values]=textread(DIPS_FILE,'%f %f');
    % extracting the relevant rake value to use
        [fault_name_slip,rake_values]=textread(RAKES_FILE,'%s %f');
        b=strmatch(fault_name,fault_name_slip,'exact');
        rake=rake_values(b);
        if isempty(rake)==1
            msgrake=sprintf('Missing rake information %s.\nFault not plotted.',fault_name);
            errordlg(msgrake)
        else
    % extracting the relevant projection direction to use
        [fault_name_proj,proj_dir]=textread(PROJECTION_DIRECTION_FILE,'%s %f');
        e=strmatch(fault_name,fault_name_proj,'exact');
        proj_dir=proj_dir(e);
        if isempty(proj_dir)==1
        	msgproj=sprintf('Missing projection direction information for %s.\nFault not plotted.',fault_name);
        	errordlg(msgproj)
       	else
            x_points=utm_x;
            y_points=utm_y;
            z_points=utm_z;        
        for i=1:length(dip_depth(:,1))-1
           constant_dip=dip_values(i);
           depth1=dip_depth(i+1);
           fault_down_dip_length=-(depth1-dip_depth(i))*1000/sind(constant_dip);
           % calculating the grid size to use to depth (to ensure a whole number
            % of boxes, resulting elements will be recetangular rather than square
            if grid_sizem<=abs((-depth1*1000/sind(constant_dip)))
                    m=abs(round(fault_down_dip_length/grid_sizem)); % whole number of boxes that will fit into the fault_down_dip_length
                    grid_size_to_depth=-fault_down_dip_length/m;
            else 
                    grid_size_to_depth=-fault_down_dip_length;
                    m=1;
            end
            grid_size_surface=grid_size_to_depth*cosd(constant_dip);
            grid_size_depth=grid_size_to_depth*sind(constant_dip);
            
            % Projecting the fault to depth
            delta_z=grid_size_depth;
                if isempty(proj_dir)==1
                    delta_x=0;
                    delta_y=0;
                else
                    delta_x=abs(grid_size_surface*sind(proj_dir));
                    delta_y=abs(grid_size_surface*cosd(proj_dir));
                end
               if isempty(proj_dir)==1
                            dx=0;
                            dy=0;
                        elseif proj_dir>=0 && proj_dir<90
                            dx=1;
                            dy=1;
                        elseif proj_dir>=90 && proj_dir<180
                            dx=1;
                            dy=-1;
                        elseif proj_dir>=180 && proj_dir<270
                            dx=-1;
                            dy=-1;
                        elseif proj_dir>=270 && proj_dir<=360
                            dx=-1;
                            dy=1;
                        else
                            msgrake=sprintf('The projection direction must be 0 - 360 degrees for %s.\nFault not plotted.',fault_name);
                            errordlg(msgrake)
               end
               a=length(x_points(:,1));
            for k=1:length(utm_x)
                    for l=1:m
                        if i==1
                            x_points(1+l,k)=x_points(l,k)+dx*delta_x;
                            y_points(1+l,k)=y_points(l,k)+dy*delta_y;
                            z_points(1+l,k)=z_points(l,k)-delta_z;
                        else
                           x_points(l+a,k)=x_points(l+a-1,k)+dx*delta_x;
                           y_points(l+a,k)=y_points(l+a-1,k)+dy*delta_y;
                           z_points(l+a,k)=z_points(l+a-1,k)-delta_z;
                        end
                    end
            end
            num_dip(i)=length(x_points(:,1));
       end
       % Calculating the bulls eye slip distribution. Options
                % included 
                if strcmp(fault_name,fault_slip_name)==1
                    slipq=questdlg('How much of the fault slips?','Slip distribution','All','Partial rupture','All');
                    switch slipq
                        case 'All'
                            slip_bulls_eye_distribution
                        case 'Partial rupture'
                            slip_partq=questdlg('Which part of the fault ruptures?','Slip distribution','Central section','North or west end','South or east end','Central section');
                            switch slip_partq
                                case 'Central section'
                                    slip_length1=inputdlg('What is the length of the fault that ruptures? (in km)');
                                    slip_length=str2num(slip_length1{1});
                                    slip_bulls_eye_distribution_C
                                case 'North or west end'
                                    slip_length1=inputdlg('What is the length of the fault that ruptures? (in km)');
                                    slip_length=str2num(slip_length1{1});
                                    slip_bulls_eye_distribution_NW
                                case 'South or east end'
                                    slip_length1=inputdlg('What is the length of the fault that ruptures? (in km)');
                                    slip_length=str2num(slip_length1{1});
                                    slip_bulls_eye_distribution_SE
                            end
                    end
                    seismic_moment
                elseif strcmp(fault_name,fault_slip_name)==0
                    slip_distribution=zeros((length(z_points(:,1))-1),(length(x_points(1,:))-1)); % creates a slip of 0 for faults without movement
                else
                    errordlg('Slip calculations have gone wrong')
                end
                patch_plotting
                %% Writing the data to the Coulomb output file
                for i=1:length(z_points(:,1))-1
                    % working out what value of dip to use
                    found=0;
                    v=1;
                    while found==0
                        if -dip_depth(v+1)*1000<z_points(i,1)
                            found=1;
                        else
                            v=v+1;
                        end
                    end
                    for j=1:length(x_points(1,:))-1
                        if isempty(proj_dir)==1 %for faults which are vertical
                            fprintf (fid,'  1    %4.3f   %4.3f    %4.3f   %4.3f 100     %2.2f      %2.3f    %2.0f     %2.2f     %2.2f    %s\n', x_points(i,j)/1000,y_points(i,j)/1000,x_points(i,j+1)/1000,y_points(i,j+1)/1000,rake,slip_distribution(i,j),dip_values(v),abs(z_points(i,j)/1000),abs(z_points(i+1,j)/1000),fault_name);
                        elseif proj_dir>=90 && proj_dir<=270 % for south dipping faults
                            fprintf (fid,'  1    %4.3f   %4.3f    %4.3f   %4.3f 100     %2.2f      %2.3f    %2.0f     %2.2f     %2.2f    %s\n', x_points(i,j)/1000,y_points(i,j)/1000,x_points(i,j+1)/1000,y_points(i,j+1)/1000,rake,slip_distribution(i,j),dip_values(v),abs(z_points(i,j)/1000),abs(z_points(i+1,j)/1000),fault_name);
                        else % for north dipping faults
                            fprintf (fid,'  1    %4.3f   %4.3f    %4.3f   %4.3f 100     %2.2f      %2.3f    %2.0f     %2.2f     %2.2f    %s\n', x_points(i,j+1)/1000,y_points(i,j+1)/1000,x_points(i,j)/1000,y_points(i,j)/1000,rake,slip_distribution(i,j),dip_values(v),abs(z_points(i,j)/1000),abs(z_points(i+1,j)/1000),fault_name);
                        end
                    end
                end
                clearvars -except grid_size grid_sizem seismo_depth rupture_depth rupture_depthm seismo_depthm maximum_slip fault_names fault_slip_name fid output_data_file filename min_x max_x min_y max_y UTM_zone UTM_letter kml_folder COUL_GRID_SIZE constant_dip rake slip_at_surface PROJECTION_DIRECTION_FILE SHORT_FAULT_LENGTHS_FILE DIPS_FILE RAKES_FILE plotting slip_distribution centre_horizontal centre_vertical% clears all data except variables required for each loop
        end
    end
    end
end
%% Finishing off writing the Coulomb input file
fprintf (fid,'\n');
fprintf (fid,'\n');
fprintf (fid,'    Grid Parameters\n');
fprintf (fid,'  1  ----------------------------  Start-x =    %3.5f\n',min_x);
fprintf (fid,'  2  ----------------------------  Start-y =   %5.4f\n',min_y);
fprintf (fid,'  3  --------------------------   Finish-x =    %3.5f\n',max_x);
fprintf (fid,'  4  --------------------------   Finish-y =   %5.4f\n',max_y);
fprintf (fid,'  5  ------------------------  x-increment =      %2.4f\n',COUL_GRID_SIZE);
fprintf (fid,'  6  ------------------------  y-increment =      %2.4f\n',COUL_GRID_SIZE);
fprintf (fid,'     Size Parameters\n');
fprintf (fid,'  1  --------------------------  Plot size =     3.000000\n');
fprintf (fid,'  2  --------------  Shade/Color increment =     1.000000\n');
fprintf (fid,'  3  ------  Exaggeration for disp.& dist. =     150000.0\n');
fprintf (fid,'\n');
fprintf (fid,'Cross section default\n');
fprintf (fid,'  1  ----------------------------  Start-x =   %3.5f\n',min_x);
fprintf (fid,'  2  ----------------------------  Start-y =   %4.4f\n',min_y);
fprintf (fid,'  3  --------------------------   Finish-x =   %3.5f\n',max_x);
fprintf (fid,'  4  --------------------------   Finish-y =   %4.4f\n',max_y);
fprintf (fid,'  5  ------------------  Distant-increment =      %2.4f\n',COUL_GRID_SIZE);
fprintf (fid,'  6  ----------------------------  Z-depth =     20.00000\n');
fprintf (fid,'  7  ------------------------  Z-increment =      %2.4f\n',COUL_GRID_SIZE);
fclose(fid);
fclose('all');
% else fid < 0;
%     errordlg('You are not in the correct directory.')
end
end
%clear