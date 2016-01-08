function [fpaths] = file_paths(filename)

fid = fopen(filename);
fpaths = cell(1);
tline = fgets(fid);
i = 0;
while ischar(tline)
    i = i + 1;
    tline = fgets(fid);
    tline(end) = []; % last characters create a problem with readtable
    fpaths{i} = ['../datasets/', tline];
end

fpaths(i) = []; % The last filepath is empty
fclose(fid);

end
