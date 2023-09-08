%replace the #fixed value in the output file with the actual number of fault elements (patch_count)
function replace_fixed(patch_count,output_data_file)
newtext = sprintf('#reg1=  0  #reg2=  0   #fixed= %s    sym=  1 \n',num2str(patch_count));
fileID = fopen(output_data_file,'r+');
for k=1:2 %2 because the line to be replaced is 3
   fgetl(fileID);
end
fprintf(fileID,newtext);
fclose(fileID);
