function[] = printtable(M,SD,table_head,row_name)
% PRINTTABLE prints the array M in LaTeX table format
% M is an array of size m x n
% SD is an array of size m x n
% In our context, the values in M are averaged performance indicators
% If a standard deviation is available, we print the value in () also
% You must put SD as an array of m x n. If SD is not available just put []
% 
% table_head is a cell of strings containing the column header (size n)
% row_name is a cell of strings containing the row header (size m)
% 
% You can modify the format of printing (float, string, integer, etc in the for loop
% USAGE: 
% printtable(M,SD,table_head,row_name)
% printtable(M,[],table_head,row_name)
    
[m,n] = size(M);
str_table_head = ' & ';
for k=1:n
    if k < n
        str_table_head = [str_table_head table_head{k} ' & '];
    else
        str_table_head = [str_table_head table_head{k}];
    end
end
str_table_head = [str_table_head ' \\\\ \n'];



fprintf('\n');
fprintf(['\\begin{tabular}{' repmat('c',1,n+1) '} \\hline \n']);
fprintf(str_table_head);
if isempty(SD)
        for ii = 1:m
        value_row = [row_name{ii} '& '];
        for jj=1:n
            if jj < n
                value_row = [value_row [num2str(M(ii,jj),'%2.1f'), ' & ']];
            else
                value_row = [value_row [num2str(M(ii,jj),'%2.1f')]];
            end            
        end
        value_row = [value_row ' \\\\ \n'];
        fprintf(value_row);
        end
    
else
        for ii = 1:m
        value_row = [row_name{ii} '& '];
        for jj=1:n
            if jj < n
                value_row = [value_row ['\\textbf{',num2str(M(ii,jj),'%2.1f'),'}', ' (','\\textbf{',num2str(SD(ii,jj),'%2.1f'),'}', ') & ']];
            else
                value_row = [value_row ['\\textbf{',num2str(M(ii,jj),'%2.1f'),'}', ' (','\\textbf{',num2str(SD(ii,jj),'%2.1f'),'}', ')']];
            end         
        end
        value_row = [value_row ' \\\\ \n'];
        fprintf(value_row);
        end
end
fprintf(' \\end{tabular} \n')
end
