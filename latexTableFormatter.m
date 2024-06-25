% Any element in <Data> having the avoidable value of '-111111' will be
% replaced by a 'x' mark
% Arguments:
% *  Data: [M x N] array of the data to be tabularized
% *  EveryColHeader: X number of headers, repeated for each X columns, string cell-array with 
%                               X elements, supports LaTeX formatted strings
% *  EveryRowHeader: Y number of headers, repeated for each Y rows, string cell-array with 
%                               X elements, supports LaTeX formatted strings
% *  settings: (OPTIONAL variable) containing the following sub-fields:
%       -  DataExtras: {M x N} cell-array of extra qualifiers added to data (supports partial empty 
%                           cells) [DEFAULT: 0, for empty cells]
%       -  DataExtraOptions: the choices are: 'pmx', '(x)', ' ' for +/-x, (x), or x respectively [DEFAULT: ' ']
%       -  GroupXnoOfCol: (int) group these many columns into one col-header, 0 would indicate 
%                                   no grouping, otherwise N/X should be an integer [DEFAULT: 0]
%       -  GroupYnoOfRows: (int) group these many rows into one row-header, 0 would indicate 
%                                        no grouping, otherwise M/Y should be an integer [DEFAULT: 0]
%       -  ColumnGradient: A sequence of binary values [1 0 1 1 0 ... etc.] of length N/X (if X > 0) 
%                                    or N (if X = 0), indicating decsending (0) or ascending (1) desirability 
%                                    of the metrics in these columns  [DEFAULT: all zeros]
%       -  RowGradient: A sequence of binary values [1 0 1 1 0 ... etc.] of length M/Y (if Y > 0) 
%                                    or M (if Y = 0), indicating decsending (0) or ascending (1) desirability 
%                                    of the metrics in these rows  [DEFAULT: all zeros]
%       -  ShowColumnGradientArrow: to show arrows after columns [DEFAULT: false]
%       -  ShowRowGradientArrow: to show arrows after rows [DEFAULT: false]
%       -  ColGroupHeader: N/X number of headers for N/X column-groups, string cell-array with 
%                                     N/X elements, supports LaTeX formatted strings, can be set to ' ' if 
%                                     X = 0 [DEFAULT: ' ']
%       -  RowGroupHeader: M/Y number of headers for M/Y column-groups, string cell-array 
%                                       with M/Y elements, supports LaTeX formatted strings, can be set to
%                                       ' ' if Y = 0 [DEFAULT: ' ']
%       -  ColorScheme: set 1 to visualize cell colors, 0 for not [DEFAULT: 0, corresponds to no color]
%       -  Precision: values after decimal [DEFAULT: 2]
%       -  OutputLocation: 'console' or a text file path '/some/random/location/file.txt' 
%                                       [DEFAULT: 'console']
%       -  SwitchToWhiteThreshold:  text color switched to white if grayscale value of cell 
%                                                       below this threshold [DEFAULT: 0.4]

function latexTableFormatter(Data, EveryColHeader, EveryRowHeader, settings)

    M = size(Data, 1); N = size(Data, 2); AVOID_VAL = -111111;

    gray1 = '{200,200,200}'; 

    %% What follows next is a long list of sanity check and optional val.
    % check:
    if ~exist('settings', 'var')
        settings = '';
    end

    if isfield(settings,'DataExtras')
        DataExtras = settings.DataExtras;
    else
        DataExtras = 0;
    end

    if isfield(settings,'DataExtraOptions')
        DataExtraOptions = settings.DataExtraOptions;
    else
        DataExtraOptions = ' ';
    end    

    if isfield(settings,'GroupXnoOfCol')
        GroupXnoOfCol = settings.GroupXnoOfCol;
    else
        GroupXnoOfCol = 0;
    end        

    if isfield(settings,'GroupYnoOfRows')
        GroupYnoOfRows = settings.GroupYnoOfRows;
    else
        GroupYnoOfRows = 0;
    end   

    if isfield(settings,'ColGroupHeader')
        ColGroupHeader = settings.ColGroupHeader;
    else
        ColGroupHeader = '';
    end 

    if isfield(settings,'RowGroupHeader')
        RowGroupHeader = settings.RowGroupHeader;
    else
        RowGroupHeader = '';
    end           

    if isfield(settings,'ColumnGradient')
        ColumnGradient = settings.ColumnGradient;
    else
        ColumnGradient = zeros(1, N);
    end   

    if isfield(settings,'RowGradient')
        RowGradient = settings.RowGradient;
    else
        RowGradient = zeros(1, N);
    end       

    if isfield(settings,'ShowColumnGradientArrow')
        ShowColumnGradientArrow = settings.ShowColumnGradientArrow;
    else
        ShowColumnGradientArrow = zeros(1, N);
    end    

    if isfield(settings,'ShowRowGradientArrow')
        ShowRowGradientArrow = settings.ShowRowGradientArrow;
    else
        ShowRowGradientArrow = zeros(1, N);
    end        
   

    if isfield(settings,'ColorScheme')
        ColorScheme = settings.ColorScheme;
    else
        ColorScheme = 0;
    end      

    if isfield(settings,'Precision')
        Precision = settings.Precision;
    else
        Precision = 2;
    end  

    if isfield(settings,'OutputLocation')
        OutputLocation = settings.OutputLocation;
    else
        OutputLocation = 'console';
    end   

    if isfield(settings,'SwitchToWhiteThreshold')
        SwitchToWhiteThreshold = settings.SwitchToWhiteThreshold;
    else
        SwitchToWhiteThreshold = 0.4;
    end       

    % Use these packages:
    fprintf(['--: Use the following <strong>packages</strong>:\n\n\\usepackage[export]{adjustbox}\n\\usepackage{' ...
        'booktabs}\n\\usepackage{colortbl}\n\\usepackage{pifont}\n\\usepackage{multirow}\n\n']);

    assert(mod(N,numel(EveryColHeader)) == 0 && (N/numel(EveryColHeader))>=1, 'Number of total columns must be integer nulitple of or equal to num of col headers ');
    assert(mod(M,numel(EveryRowHeader)) == 0 && (M/numel(EveryRowHeader))>=1, 'Number of total rows must be integer nulitple of or equal to num of row headers ');

    if( (numel(RowGroupHeader) ~= 0) && (numel(ColGroupHeader) ~= 0) )
        error('We do not currently support grouping both columns and rows in one table; it could be either or none, not both. Sorry!');
    end

    %% Sorting data (needed for colorisation and determining best val):
    nCol = numel(EveryColHeader); nRow = numel(EveryRowHeader);
    DataO = Data;
    if(numel(ColGroupHeader)~=0)
        totalActualCols = N/numel(ColGroupHeader);
    else
        totalActualCols = N;
        if(~( (sum(ColumnGradient) == numel(ColumnGradient)) || (sum(ColumnGradient) == 0) ))
            fprintf('<strong>Warning</strong>: for no column grouping, only the gradient direction of first column will be used');
            ColumnGradient = ones(1, numel(ColumnGradient)).*ColumnGradient(1);
        end
    end

    % This is unfortunately, a bit confusing. :(
    blocksInData = N/totalActualCols;

    intensityValList = zeros(size(Data));

    for ii = 1:totalActualCols
        if(blocksInData > 1)
            block = DataO(:,ii: totalActualCols:N); % Picking data by column groupd
        else
            block = DataO;
        end

        blockIntensity = [];
        for iRow = 1:M
            rowC = block(iRow,:);
            if(ColumnGradient(ii))
                % Lowest is best
                rowC(rowC==AVOID_VAL)=-realmax; % weeding out avoid vals
                [~,rank] = sort(rowC);
            else
                % Highest is best
                rowC(rowC==AVOID_VAL)=realmax; % weeding out avoid vals
                [~,rank] = sort(rowC, 'descend');
            end
            intensityVal = zeros(1, numel(rowC));
            intensityVal(1, rank) = 1:numel(rowC);
            blockIntensity = [blockIntensity; intensityVal];
        end

        % Concatenating the rank of values:
        if(blocksInData > 1)
            intensityValList(:,ii: totalActualCols:N) = blockIntensity;
        else
            intensityValList = blockIntensity;
        end
    end
    
    % 'Sky' colormap needs Matlab 2023a or higher
    if(blocksInData > 1)
        colList = colormap(sky(blocksInData));
        eCol = blocksInData;
    else
        colList = colormap(sky(totalActualCols));
        eCol = totalActualCols;
    end

    % rounding data to desirec precision
    Data = round(Data, Precision);

    %% Starting to build actual LaTeX string:
    defaultHeader = '\begin{table}[t] \begin{adjustbox}{width=\textwidth,center} \begin{tabular}{';

    opString = defaultHeader;

    if(numel(RowGroupHeader) ~= 0)
        totalCols = N + 2;
    else
        totalCols = N + 1;
    end

    % Building up table headers:
    for ii = 1:totalCols
        if( (numel(RowGroupHeader) == 0) && (ii == 1))
            opString = [opString 'r'];
        elseif( (numel(RowGroupHeader) ~= 0) && (ii == 2))
            opString = [opString 'r'];
        else
            opString = [opString 'c'];
        end
    end
    opString = [opString '}  \toprule \hline'];

    if(numel(ColGroupHeader) ~= 0)
        opString = [opString '\multirow{2}{*}{} &'];
    end

    if(numel(RowGroupHeader) ~= 0)
        opString = [opString ' &'];
    end


    % Adding column headers
    if(numel(ColGroupHeader)~=0)
        for ii = 1:(N/nCol)
            opString = [opString ' \multicolumn{' num2str(nCol) '}{c}{\cellcolor[RGB]' gray1 ' \textbf{' ColGroupHeader{ii} '}}'];
            if(ii ~= N/nCol)
                opString = [opString ' &'];
            end
        end
        opString = [opString '\\'];
    end

    opString = [opString ' &'];

    colStrInd = 1;
    
    % Col headers are always gray:
    for ii = 1:(N/nCol)
        for jj = 1:nCol
            opString = [opString ' \cellcolor[RGB]' gray1 ' \textbf{' EveryColHeader{jj} '}'];
            if(ShowColumnGradientArrow)
                if(~ColumnGradient(jj))
                    opString = [opString ' $\downarrow$ '];
                else
                    opString = [opString ' $\uparrow$ '];
                end
            end
            colStrInd = colStrInd + 1;
            if(colStrInd~=N+1)
                opString = [opString ' &'];
            end
        end
    end

    if(numel(RowGroupHeader) == 0)
        clineStart = 2;
    else
        clineStart = 3;
    end

    % Col. header and data separated by cline:
    clineEnd = clineStart + N - 1;
    newClineStr = ['\\ \cline{' num2str(clineStart) '-' num2str(clineEnd) '} '];

    opString = [opString newClineStr];

    groupNum = 1;

    % Some melodrama for getting the row-header in place
    for iRow = 1:M
        if( (numel(RowGroupHeader) ~= 0))
            if(mod(iRow,nRow) == 1) 
                opString = [opString '\multirow{' num2str(nRow) '}{*}{\textbf{' RowGroupHeader{groupNum} '}} &'];
                groupNum = groupNum + 1;
            else
                opString = [opString ' & '];
            end
        end
        opString = [opString '\textbf{' EveryRowHeader{mod(iRow,nRow)+1} '} '];
        if(ShowRowGradientArrow)
            if(~RowGradient(mod(iRow,nRow)+1))
                opString = [opString ' $\downarrow$ '];
            else
                opString = [opString ' $\uparrow$ '];
            end
        end
        opString = [opString ' & '];

        for iCol = 1:N
            % The data is being appended right here:
            if(Data(iRow, iCol)~=AVOID_VAL)
                if(ColorScheme~=0)
                    color = colList(intensityValList(iRow, iCol), :);
                    c1 = num2str(color(1)*255); c2 = num2str(color(2)*255); c3 = num2str(color(3)*255);
                    colScheme = ['\cellcolor[RGB]{' c1 ', ' c2 ', ' c3 '}'];
                    if(intensityValList(iRow, iCol) == eCol)
                        opString = [opString colScheme '\textbf{\textcolor{white}{' num2str(Data(iRow, iCol)) '}}'];
                    elseif(intensityValList(iRow, iCol) == eCol-1)
                        opString = [opString colScheme '\textbf{' num2str(Data(iRow, iCol)) '}'];                        
                    else
                        opString = [opString colScheme num2str(Data(iRow, iCol))];
                    end
                else
                    if(intensityValList(iRow, iCol) == eCol)
                        opString = [opString '\textbf{\underline{' num2str(Data(iRow, iCol)) '}}'];
                    elseif(intensityValList(iRow, iCol) == eCol-1)
                        opString = [opString '\textbf{' num2str(Data(iRow, iCol)) '}'];                        
                    else
                        opString = [opString num2str(Data(iRow, iCol))];
                    end
                end
            else
                opString = [opString '\ding{56}']; % Avoid val.s are tick marked
            end
            if (iCol ~=N)
                opString = [opString ' &'];
            end
        end

        opString = [opString '\\'];
    end
    % Appending table footer:
    opString = [opString '\hline'];
    opString = [opString '\bottomrule \end{tabular} \end{adjustbox} \caption{ToDo: put actual captions...}   \label{tab_label_ToChange} \end{table}'];

    if(strcmp(OutputLocation, 'console'))
        fprintf('\n\n==============\nThe output <strong>LaTeX table</strong> is as follows:\n\n%s \n\n ==============\n\n\n', ...
            opString);
    else
        fprintf('\n\n==============\nThe output <strong>LaTeX table</strong> has been written to:\n\t<strong>\%s</strong> \n ==============\n\n\n', ...
            OutputLocation);
        fid = fopen(OutputLocation,'wt') ;
        fwrite(fid,opString) ;
        fclose (fid) ;
    end




end