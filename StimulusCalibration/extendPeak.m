function [ i_st_new, i_ed_new ] = extendPeak( v, i_st, i_ed )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    try
        i_st_new = extend_one_end(v, i_st, -1);
    catch
        2;
    end
    try
        i_ed_new = extend_one_end(v, i_ed, 1);
    catch
        2;
    end
    
end

function i_new = extend_one_end(v,i_init,inc)
    i0 = i_init;
    i = i0+inc;
    %while i>=1 && i<=length(v) && v(i) < v(i0) && v(i)>0
    while i>=1 && i<=length(v) && v(i) < v(i0)
       i0 = i;
       i = i + inc;
    end
    i_new = i-inc;

end

