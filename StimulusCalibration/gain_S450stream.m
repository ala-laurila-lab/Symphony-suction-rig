function [ gain, max_count, max_range ] = gain_S450stream( g )
%gain_S450stream Return gain of S450
    switch lower(g)
        case 'a'
            gain = 7.864*10^-9;
            max_range = 4.123*10^-3;
        case 'b'
            gain = 7.864*10^-10;
            max_range = 4.123*10^-4;
        case 'c'
            gain = 7.864*10^-11;
            max_range = 4.123*10^-5;
        case 'd'
            gain = 7.864*10^-12;
            max_range = 4.123*10^-6;
        case 'e'
            gain = 7.943*10^-13;
            max_range = 4.165*10^-7;
        case 'f'
            gain = 8.642*10^-14;
            max_range = 4.531*10^-8;
        case 'g'
            gain = 7.864*10^-15;
            max_range = 4.123*10^-9;
    end
    max_count = max_range/gain;
end

