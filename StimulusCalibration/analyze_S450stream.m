%analyze_S450stream.m
%
clear; close all;
measure_date = '2015_0131';
dat_root = '/Users/dtakeshi/Documents/Data/StimulusCalibration/Photodiode/SuctionRig/';

[filenames, dat_fullpath] = uigetfile(fullfile(dat_root,...
                                                measure_date,'*.mat'),'Multiselect','on');
%LEDparameters_2015_0108();%s is a parameter
%v_static = load('FlashFamily_Static.txt');
dt = 1/53;%53 Hz sampling rate
%gain = 7.864*10^-12;%for gain D
res = 2.070E-01;%Amp/Watt-Check if this depends on lambda on the instrument
th_value = 10000;%To remove jumps in baseline (this is strange, but seems to work)
%t_stim = 20/1000;%sec
if ~iscell(filenames)
    filenames = {filenames};
end
cd(dat_fullpath)
V_set_all = []; 
I_mean_all=V_set_all;
I_std_all =V_set_all;
signal_all ={};
for nf=1:length(filenames)
    fname = filenames{nf};
    load(fname);%data & stimParameters are loaded
    s = cellfun(@(s)s(2:end),data(2:end),'uniformoutput',false);%avoid first line & first letter in each line (='x')
    v_orig = hex2dec(s);%Original data
    v0 = v_orig;
    %% Remove jumping basline
    v0(v0 <= th_value)=NaN;
    v = v0(v0 > th_value);
    %% Change polarity & subtract baseline
    
    v = -(v-mode(v));%Subtract baseline and change polarity
    v_log = log10(abs(v));
    th = 0.6*max(v_log);
    idx_above = find(v_log > th);
    idx_below = find(v_log <= th);
    %th = 7*std_Quiroga(v);
%     idx_above = find(v > th);
%     idx_below = find(v <= th);
    %% Detect peaks
    [idx_st0, idx_ed0] = pick_consecutive(idx_above);
    %% Extend points for detected peaks
    try
    [idx_st, idx_ed] = arrayfun(@(i1,i2)extendPeak(v, i1, i2), idx_st0, idx_ed0);
    catch
        2;
    end
    %% conversion
    gain = gain_S450stream( stimParameters.Gain );
    v = gain*v;
    %% Calculate area
    try
        %area = arrayfun(@(i1,i2)sum(v(i1:i2)),idx_st,idx_ed);
        area = arrayfun(@(i1,i2)trapz(v(i1:i2)),idx_st,idx_ed);
        signal = arrayfun(@(i1,i2)v(i1:i2),idx_st,idx_ed,'uniformoutput',false);
    catch
       2; 
    end
    [V_all, V_back, msg, problem] = stimParams2LEDamplituedes(stimParameters,length(area));
    if problem
        figure
        plot(v,'x-')
        hold on
        arrayfun(@(i1,i2)plot(i1:i2,v(i1:i2),'ko-'),idx_st0,idx_ed0);
        arrayfun(@(i1,i2)plot(i1:i2,v(i1:i2),'rx-'),idx_st,idx_ed);
        title(sprintf('%s %s',fname,msg),'interpreter','none')
    end
    V_set = unique(V_all);
    
    try
    area_mean = arrayfun(@(x)mean(area(V_all==x)),V_set);
    area_std = arrayfun(@(x)std(area(V_all==x)),V_set);
    signal_eachV = arrayfun(@(x)signal(V_all==x),V_set,...
                            'UniformOutput',false);
    catch
       2; 
    end
    %I = gain*area_mean/res*dt;
    I_all = area*dt;
    I_mean = arrayfun(@(x)mean(I_all(V_all==x)),V_set);
    I_std = arrayfun(@(x)std(I_all(V_all==x)),V_set);
    V_set_all = [V_set_all V_set];
    I_mean_all = [I_mean_all I_mean];
    I_std_all = [I_std_all I_std];
    signal_all = {signal_all{:} signal_eachV{:}}
    
end
[V_sort, idx_sort]=sort(V_set_all);
I_mean_sort = I_mean_all(idx_sort);
I_std_sort = I_std_all(idx_sort);
signal_sort = signal_all(idx_sort);
V_ref = 980;
linearity = (I_mean_sort./V_sort)/(I_mean_sort(V_sort==V_ref)/V_ref);
subplot(2,3,1)
%plot(V_sort, I_mean_sort,'x-')
errorbar(V_sort, I_mean_sort, I_std_sort)
xlabel('LED voltage (mV)');ylabel('Charge');
set(gca,'xscale','log','xlim',[1 10^4]);
set(gca,'yscale','log');
subplot(2,3,2)
plot(V_sort, linearity,'x-')
set(gca,'xscale','log','xlim',[1 10^4])
xlabel('LED voltage (mV)');ylabel('Linearity');

plcl = 'bkrgc';
n_clr = length(plcl);
n_vol = length(signal_sort);
idx_clr = repmat(1:n_clr,[1 ceil(n_vol/n_clr)]);

idx_splot = floor(log10(V_sort));
LHset = zeros(size(V_sort));
leg_set = cellstr(num2str(V_sort(:)));
for n=1:n_vol
   for m=1:length(signal_sort{n})
       y_tmp = signal_sort{n}{m};
       [~,idx_max] = max(y_tmp);
       x_tmp = ((1:length(y_tmp))-idx_max)*dt*1000;    
       subplot(2,3,3+idx_splot(n))
       LH = plot(x_tmp,y_tmp,[plcl(idx_clr(n)),'-']);
       hold on
       if m==1
           LHset(n) = LH;
       end
   end
end
%% set legend
idx = unique(idx_splot);
for n=1:length(idx)
    ah = subplot(2,3,3+idx(n));
    legend(ah,LHset(idx_splot==idx(n)), leg_set(idx_splot==idx(n)));
    yl = get(ah,'ylim');
    set(ah,'ylim',[0 yl(2)],'xlim',[-5 10]*dt*1000)
    xlabel('Time (ms)'); ylabel('Current (A)')
end

axis_prop.fontsize = 14;
line_prop.markersize = 10;
txt_prop.fontsize = axis_prop.fontsize;
plot_format(axis_prop, line_prop,gcf,'',txt_prop)