function plot_S450stream( c,fname,g)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [ ~, max_count, ~] = gain_S450stream( g );
    c = c(5:end);%avoid first few lines
    s = cellfun(@(s)s(2:end),c,'uniformoutput',false);
    v0 = hex2dec(s);
    v0(v0<1000)=NaN;%change here??
    baseline = mode(v0);
    min_count = baseline-max_count;
    xvec = [1 length(v0)];
    figure;
    plot(v0,'x-')
    hold on
    plot(xvec, min_count*[1 1],'r-')
    title(fname,'interpreter','none')
end

