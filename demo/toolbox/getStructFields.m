function varlist = getStructFields(var, varlist)
if isstruct(var)
    fn = fieldnames(var);
    varlist = vertcat(varlist,fn); %# append fields to the list
    for field = fn' %# ' create row vector; iterate through fields
         varlist = getStructFields(var.(char(field)), varlist); %# recursion here 
    end
end
end