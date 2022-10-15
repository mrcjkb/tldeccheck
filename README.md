# tldeccheck

> [![Maintenance](https://img.shields.io/badge/Maintained%3F-no-red.svg)](https://bitbucket.org/lbesson/ansi-colors)
>
> __NOTE:__
>
> Since I no longer use Matlab, I cannot actively maintain this model.
> I will gladly accept PRs, as long as I can review them without Matlab.

Matlab function: Checks the TickLabels of all axes objects of the current figure and adjusts the amount of decimals so that they are uniform.

Syntax:        TLDECCHECK              - adjusts the decimals
                                         automatically.

               TLDECCHECK('OptionName', OptionValue)


OptionName - OptionValue pairs:

    - 'axes'            -  Axes handle, e.g. TLDECCHECK('axes', gca)
                           (default: array containing all axes objects in gcf)
    - 'xNumDecimals'    -  Specifies the number of decimals the XTickLabels
                           should be set to (numeric).
    - 'yNumDecimals'    -  Specifies the number of decimals the YTickLabels
                           should be set to (numeric).
    - 'cNumDecimals'    -  Specifies the number of decimals the colorbar
                           TickLabels should be set to (numeric).
    - 'xMode'           -  'auto' (default) or 'manual' - Set this to 
                           'manual' for reduction of the XTickLabel decimals through
                           manual input. Doing so overrides the
                           'numDecimals' option.
    - 'yMode'           -  'auto' (default) or 'manual' - Set this to 
                           'manual' for reduction of the YTickLabel decimals through
                           manual input. Doing so overrides the
                           'numDecimals' option.
    - 'cMode'           -  'auto' (default) or 'manual' - Set this to 
                           'manual' for reduction of the colorbar TickLabel decimals through
                           manual input. Doing so overrides the
                           'numDecimals' option.
    - 'xLabelUnits'    -   Specify a custom unit (default: '%') that the XTickLabels
                           are checked for (string).
    - 'yLabelUnits'    -   Specify a custom unit (default: '%') that the 
                           YTickLabels are checked for (string).
    - 'cLabelUnits'    -   Specify a custom unit (default: '%') that the
                           colorbar TickLabels are checked for (string).


Old syntax:    (still works)
               TLDECCHECK              - adjusts the decimals
                                         automatically.
               TLDECCHECK(nd)          - adjusts the decimals and reduces the
                                         amount of decimals to nd
               TLDECCHECK('manual')    - reduction of the decimals through
                                         manual input

Input arguments (old syntax):

   - nd:   Amount of decimals for TickLabels (optional)
           -> Integer, for use on all axes objects
           -> String, 'manual', to set number of decimals for each axes
                      object separately

Hint:

   - If using the 'manual' option, invisible axes objects may be found.
     Just input a random number if this happens.

Author: Marc Jakobi - 22.01.2016
