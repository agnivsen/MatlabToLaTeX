# Color-coded tables: a convertor from Matlab data to LaTeX tables
This is a Matlab script for converting data arrays in Matlab to color-coded tables in LaTeX format.


## For the script <latexTableFormatter.m>

### The first example script follows:
	%% Example 1: the simple table (with colors)
	M = 5; N = 10; nHeaderChars = 4;
	Data = rand(M,N); % assigning random data
	colHeaders = getRandomHeaders(N, nHeaderChars); % assigning random column headers
	rowHeaders = getRandomHeaders(M, nHeaderChars); % assigning random row headers
	Data(2,2) = -111111; % assigning arbitrary points in the data to be avoided (prints x) with the avoid val: -111111
	Data(3,7) = -111111;
	settings.Precision = 4; % precision for displaying values
	settings.ShowRowGradientArrow = true; % turning on row arrow display
	settings.ShowColumnGradientArrow = true; % turning on col arrow display
	settings.RowGradient = [1 1 0 1 1]; % direction of desired metric
	settings.ColumnGradient = [1 0 0 1 0 1 1 0 0 1]; % direction of desired metric
	settings.ColorScheme = 1;
	
	fprintf('\nShowing the <strong>first</strong> example of a <strong>simple LaTeX table</strong>\n\n');
	latexTableFormatter(Data, colHeaders, rowHeaders, settings);

produces the following table:

![Table1](https://github.com/agnivsen/MatlabToLaTeX/assets/5153445/72e2bd4b-29c7-40c4-982f-657271073250)

### The second example script follows:

	%% Example 2: the simple table with grouped row headers (no colors)
	M = 9; N = 10; nHeaderChars = 4;
	Data = rand(M,N); % assigning random data
	colHeaders = getRandomHeaders(N, nHeaderChars); % assigning random column headers
	rowHeaders = getRandomHeaders(3, nHeaderChars); % assigning random row headers
	rowGroupHeaders = getRandomHeaders(3, nHeaderChars); % assigning random column headers
	Data(2,2) = -111111; % assigning arbitrary points in the data to be avoided (prints x) with the avoid val: -111111
	Data(5,6) = -111111;
	Data(5,7) = -111111;
	settings.Precision = 2; % precision for displaying values
	settings.ShowRowGradientArrow = true; % turning on row arrow display
	settings.ShowColumnGradientArrow = true; % turning on col arrow display
	settings.RowGradient = [1 1 0]; % direction of desired metric
	settings.ColumnGradient = [1 0 1 1 0 1 1 0 0 1]; % direction of desired metric
	settings.RowGroupHeader = rowGroupHeaders;
	
	fprintf('\nShowing the <strong>second</strong> example of a <strong>LaTeX table with row-grouping</strong>\n\n');
	latexTableFormatter(Data, colHeaders, rowHeaders, settings);

produces the following table:

![Table2](https://github.com/agnivsen/MatlabToLaTeX/assets/5153445/71ceef2c-6f48-43d7-93a0-378c3f85e1d5)


### The third example script follows:

	%% Example 3: the simple table with grouped column headers (with colors)
	M = 9; N = 10; nHeaderChars = 4;
	Data = rand(M,N); % assigning random data
	colHeaders = getRandomHeaders(2, nHeaderChars); % assigning random column headers
	colGroupHeaders = getRandomHeaders(5, nHeaderChars); % assigning random column headers
	rowHeaders = getRandomHeaders(M, nHeaderChars); % assigning random row headers
	Data(2,1) = -111111; % assigning arbitrary points in the data to be avoided (prints x) with the avoid val: -111111
	Data(5,6) = -111111;
	Data(6,6) = -111111;
	settings.Precision = 2; % precision for displaying values
	settings.ShowColumnGradientArrow = true; % turning on col arrow display
	settings.RowGradient = [1 1 0 1 0 1 0 0 1]; % direction of desired metric
	settings.ColumnGradient = [1 0 1]; % direction of desired metric
	settings.ColGroupHeader = colGroupHeaders;
	settings.ColorScheme = 1;
	
	fprintf('\nShowing the <strong>third</strong> example of a <strong>LaTeX table with column-grouping</strong>\n\n');
	latexTableFormatter(Data, colHeaders, rowHeaders, settings);

 produces the following table:
![Table3](https://github.com/agnivsen/MatlabToLaTeX/assets/5153445/b1105028-8932-4576-ae75-9b6c34fe470e)


### Additional help:

Please type 

        help latexTableFormatter

in the Matlab command window for additional information about this script


## Dependencies

- Needs **Matlab 2023a** or later
 
