function StartSymphonySafe(type)
persistent Application;

    if islogical(type) && type && isempty(Application)
        clear all * global;
        clc;
        Application = 'SymphonyUI' %#ok<NOPRT>
        StartSymphony;
    else
        Application = 'SymphonyUI';
        StartSymphony;
    end
end