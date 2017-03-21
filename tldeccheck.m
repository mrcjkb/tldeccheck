function [] = tldeccheck(varargin)
%TLDECCHECK: Checks the TickLabels of all axes objects of the current figure
%and adjusts the amount of decimals so that they are uniform.
%
%Syntax:        TLDECCHECK              - adjusts the decimals
%                                         automatically.
%
%               TLDECCHECK('OptionName', OptionValue)
%
%
%OptionName - OptionValue pairs:
%
%    - 'axes'            -  Axes handle, e.g. TLDECCHECK('axes', gca)
%                           (default: array containing all axes objects in gcf)
%    - 'xNumDecimals'    -  Specifies the number of decimals the XTickLabels
%                           should be set to (numeric).
%    - 'yNumDecimals'    -  Specifies the number of decimals the YTickLabels
%                           should be set to (numeric).
%    - 'cNumDecimals'    -  Specifies the number of decimals the colorbar
%                           TickLabels should be set to (numeric).
%    - 'xMode'           -  'auto' (default) or 'manual' - Set this to 
%                           'manual' for reduction of the XTickLabel decimals through
%                           manual input. Doing so overrides the
%                           'numDecimals' option.
%    - 'yMode'           -  'auto' (default) or 'manual' - Set this to 
%                           'manual' for reduction of the YTickLabel decimals through
%                           manual input. Doing so overrides the
%                           'numDecimals' option.
%    - 'cMode'           -  'auto' (default) or 'manual' - Set this to 
%                           'manual' for reduction of the colorbar TickLabel decimals through
%                           manual input. Doing so overrides the
%                           'numDecimals' option.
%    - 'xLabelUnits'    -   Specify a custom unit (default: '%') that the XTickLabels
%                           are checked for (string).
%    - 'yLabelUnits'    -   Specify a custom unit (default: '%') that the 
%                           YTickLabels are checked for (string).
%    - 'cLabelUnits'    -   Specify a custom unit (default: '%') that the
%                           colorbar TickLabels are checked for (string).
%
%
%Old syntax:    (still works)
%               TLDECCHECK              - adjusts the decimals
%                                         automatically.
%               TLDECCHECK(nd)          - adjusts the decimals and reduces the
%                                         amount of decimals to nd
%               TLDECCHECK('manual')    - reduction of the decimals through
%                                         manual input
%
%Input arguments (old syntax):
%
%   - nd:   Amount of decimals for TickLabels (optional)
%           -> Integer, for use on all axes objects
%           -> String, 'manual', to set number of decimals for each axes
%                      object separately
%
%Hint:
%
%   - If using the 'manual' option, invisible axes objects may be found.
%     Just input a random number if this happens.
%
%Author: Marc Jakobi - 22.01.2016

%% Changelog
%
%   - 01.08.2016:   Fixed a bug in which axes are trimmed if the FontSize is
%                   changed after using this function.
%   - 21.03.2016:   - Fixed bug with percentages messing up this function's
%                     functionality.
%                   - Eliminated repeated code.
%                   - Added new option to define tick label units.
%                   - Added ability to run on single axes object
%                   - Custom options can now be set for x, y and colorbar
%                     TickLabels individually.
%                   - Syntax overhaul (still compatible with old syntax)

%% Initialization
AX  = findobj(gcf,'type','axes');
C = findall(gcf,'Type','colorbar');
na = length(AX);
nc = length(C);
if nargin == 1 % For backward-compatibility with old syntax
    defDec = varargin{1};
    if strcmp(defDec, 'manual')
        defMode = 'manual';
    else
        defMode = 'auto';
    end
else % new syntax
    defDec = nan;
    defMode = 'auto';
end
% option value pairs and additional features
p = inputParser;
addOptional(p, 'xMode', defMode, @(x) any(validatestring(x, {'auto', 'manual'})))
addOptional(p, 'yMode', defMode, @(x) any(validatestring(x, {'auto', 'manual'})))
addOptional(p, 'cMode', defMode, @(x) any(validatestring(x, {'auto', 'manual'})))
addOptional(p, 'xNumDecimals', defDec, @isnumeric)
addOptional(p, 'yNumDecimals', defDec, @isnumeric)
addOptional(p, 'cNumDecimals', defDec, @isnumeric)
addOptional(p, 'xLabelUnits', '%', @ischar)
addOptional(p, 'yLabelUnits', '%', @ischar)
addOptional(p, 'cLabelUnits', '%', @ischar)
addOptional(p, 'axes', AX, @(x) isa(x, 'matlab.graphics.axis.Axes'))
parse(p, varargin{:})
xlu = p.Results.xLabelUnits;
ylu = p.Results.yLabelUnits;
clu = p.Results.cLabelUnits;
AX = p.Results.axes;
% Loop through axes objects
for i = 1:na
    ax = AX(i);
    yl = cellstr(ax.YTickLabel);
    if isticklabel(yl)
        [mode, numdec] = getMode(p, 0);
        yt = ax.YTick;
        [dn, isdec, dt, isper, perspace] = getDecNum(yl, ylu);
        if isdec
            yl = adjDecNum(yl, dn, dt, isper, perspace, ylu);
        end
        ax.YTickLabel = yl;
        ax.YTick = yt;
    end
    xl = cellstr(ax.XTickLabel);
    if isticklabel(xl)
        [mode, numdec] = getMode(p, 1);
        xt = ax.XTick;
        [dn, isdec, dt, isper, perspace] = getDecNum(xl, xlu);
        if isdec
            xl = adjDecNum(xl, dn, dt, isper, perspace, xlu);
        end
        ax.XTickLabel = xl;
        ax.XTick = xt;
    end
end
for i = 1:nc
    c = C(i);
    cl = cellstr(c.TickLabels);
    if isticklabel(cl)
        [mode, numdec] = getMode(p, 2);
        ct = c.Ticks;
        [dn, isdec, dt, isper, perspace] = getDecNum(cl, clu);
        if isdec
            cl = adjDecNum(cl, dn, dt, isper, perspace, clu);
        end
        c.TickLabels = cl;
        c.Ticks = ct;
    end
end
%function for retrieving number of decimals
    function [dn, isdec, dt, hasUnits, unitSpace] = getDecNum(lab, lUnit)
        % dn: number of digits after decimal separator
        % isdec: true if decimal separator found
        % dt: decimal separator ('.' or ',')
        % hasUnit: true if label has units
        % unitSpace: true if space between digit and unit
        % lUnit: Unit to check for
        dn = 0;
        isdec = false;
        dt = [];
        hasUnits = any(cellfun(@(x) contains(x, lUnit), lab));
        if hasUnits
            unitSpace = any(cellfun(@(x) contains(x, [' ', lUnit]), lab));
        else
            unitSpace = false;
        end
        for ind = 1:length(lab)
            val = lab{ind};
            val(strfind(val,' ')) = [];
            isdec = isdec || contains(val,'.')...
                || contains(val,',');
            if isdec
                idec = max([strfind(val,'.'), strfind(val,',')]);
                if contains(val,'.')
                    dt = '.';
                elseif contains(val,',')
                    dt = ',';
                end
                dn = max([dn, length(val(idec+1:end))]);
            end
        end
        if hasUnits
            dn = dn - 1;
        end
        if mode > 0
            if mode == 1
                dn = dninputfun('TickLabels', lab);
            else
                dn = numdec;
            end
        end
    end
end
%function for adjusting number of decimals
function lab = adjDecNum(lab, dn, dt, hasUnits, unitSpace, lUnit)
if hasUnits
    lab = cellfun(@(x) strrep(x, lUnit, ''), lab, 'un', false);
end
for i = 1:length(lab)
    val = lab{i};
    val(strfind(val,' ')) = [];
    if ~contains(val,dt) && ~strcmp(val,'')
        val = [val,dt,repmat('0',1,dn)]; %#ok<AGROW>
    elseif ~strcmp(val,'')
        idec = strfind(val,dt);
        val = [val,repmat('0',1,dn-length(val))]; %#ok<AGROW>
        val = [val,repmat('0',1,dn-length(val(idec+1:end)))]; %#ok<AGROW>
    end
    if ~strcmp(val,'')
        idec = strfind(val,dt);
        del = diff([dn, length(val(idec+1:end))]);
        val = val(1:end-del);
    end
    lab{i} = val;
end
if hasUnits
    if unitSpace
        unit = [' ', lUnit];
    else
        unit = lUnit;
    end
    lab = cellfun(@(x) [x, unit], lab, 'un', false);
end
end

function tf = isticklabel(lab)
tf = false;
for i = 1:length(lab)
    if tf || ~strcmp(lab{i},'')
        tf = true;
    end
end
end

function dn = dninputfun(labeltype, lab)
disp(' ')
disp([labeltype,' found:'])
disp(char(lab))
disp(' ')
dn = input('Please input the number of digits after the decimal: ');
end

function [mode, numdec] = getMode(parser, axis)
% axis: 0 for y, 1 for x, 2 for colorbar
if axis == 0
    pMode = 'xMode';
    pND = 'xNumDecimals';
elseif axis == 1
    pMode = 'yMode';
    pND = 'yNumDecimals';
else
    pMode = 'cMode';
    pND = 'cNumDecimals';
end
numdec = [];
if strcmp(parser.Results.(pMode), 'manual')
    mode = 1; % user input
else
    if ~isnan(parser.Results.(pND))
        mode = 2; % fixed number of decimals
        numdec = parser.Results.(pND);
    else
        mode = 0; % automatic determination
    end
end
end