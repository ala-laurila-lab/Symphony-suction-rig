clear; close all;
[filenames, dat_root, dat_dir, dat_fullpath] = my_uigetfiles('.txt','photodiode');
%LEDparameters_2015_0108();%s is a parameter
%v_static = load('FlashFamily_Static.txt');
dt = 1/53;%53 Hz sampling rate
%gain = 7.864*10^-12;%for gain D
res = 2.070E-01;%Amp/Watt-Check if this depends on lambda on the instrument
t_stim = 20/1000;%sec
for nf=1:length(filenames)
    fname = filenames{nf};
    [v,v0] = read_S450output(dat_fullpath,fname);
    v = -(v-mode(v));%Subtract baseline and change polarity
    th = 4*std_Quiroga(v);
    idx_above = find(v > th);
    [idx_st, idx_ed] = pick_consecutive(idx_above);
    area = arrayfun(@(i1,i2)sum(v(i1:i2)),idx_st,idx_ed);
    [V_all, V_back, msg] = getLEDstimparams(s,length(area));
    V_set = unique(V_all);
    area_mean = arrayfun(@(x)mean(area(V_set==x)),V_set);
    gain = gain_S450stream( pick_str(fname,'_g','.txt',1,1) );
    energy = gain*area_mean/res*dt;
    linearity = area_mean./V_set;
    energy_static = v_static(:,2)*t_stim;
    p = polyfit(energy, energy_static',1);
    y_fit = p(1)*energy + p(2);
    
    v_above = v;
    v_above(v < th) = NaN;
    subplot(2,2,1)
    plot(v,'x')
    hold on
    plot(v_above,'rx-')
    xlabel('Data point'); ylabel('PhDiode reading via serial port')
    subplot(2,2,2)
    %plot(V_set, area/area(end),'rx')
    plot(V_set, energy,'rx')
    hold on
    %plot(v_static(:,1),v_static(:,2)/v_static(end,2),'o')
    plot(v_static(:,1),v_static(:,2)*t_stim,'o')
    %set(gca,'xscale','log')
    xlabel('Voltage (mV)'); ylabel('Energy (J)')
    legend({'Dynamic','Static'},'location','northwest')
    subplot(2,2,3)
    plot(energy, energy_static,'x')
    hold on
    plot(energy, y_fit,'r')
    xlabel('Energy/Pulse (Dynamic)'); ylabel('Energy/Pulse (Static)');
    eq_txt = sprintf('y=%gx + %g',p(1),p(2));
    title(eq_txt)
    subplot(2,2,4)
    plot(V_set, linearity/52,'x')
    set(gca,'xscale','log')
    xlabel('Voltage (mV)'); ylabel('linearity');
    %set(gcf,'position',[70 700 1000 400])
    myannotation(fname)
end
axis_prop.fontsize = 14;
line_prop.markersize = 10;
txt_prop.fontsize = axis_prop.fontsize;
plot_format(axis_prop, line_prop,gcf,'',txt_prop)
