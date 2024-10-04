function sortedFilepaths = exampleHelperSortFilepathsByIndex(filepaths)
    %EXAMPLEHELPERSORTFILEPATHSBYINDEX Sort file paths by their index
    %   Obtain the numeric index which is the last part of the file name obtained by
    %   splitting the file name at the '_' characters. Then sort the file
    %   paths in ascending order of this numeric value.
    
    % Obtain names of files from file paths
    [~,filenames,~] = fileparts(filepaths);
    
    % Split the name at the "_" characters
    splits = split(filenames,"_");
    
    % Convert indices from string to double datatype
    % Note: We assume index is present at the end of the split
    positions = str2double(splits(:,end));
    
    % Sort the indices and obtain sorted order
    [~,sortedIdxs] = sort(positions);
    
    % Obtain file paths from sorted order
    sortedFilepaths = filepaths(sortedIdxs);
end