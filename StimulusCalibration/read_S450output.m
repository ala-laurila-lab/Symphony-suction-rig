function [v, v0] = read_S450output(varargin)
%This code reads a file with HEX format obtained through serial port of
%S450 (using the command "stream")

%% test purpose
% clear;close all;
if nargin == 0
    measure_date = '2015_0108';
    %dat_path = 'C:\Users\labadmin\Documents';
    dat_path = '/Users/dtakeshi/Documents/Data/StimulusCalibration';
    [fname,dat_path] = uigetfile(fullfile(dat_path,'*.txt'));
elseif nargin == 1
    dat_path = varargin{1};
    [fname,dat_path] = uigetfile(fullfile(dat_path,'*.txt'));
else
    dat_path = varargin{1};
    fname = varargin{2};
end

%% function main
f = fopen(fullfile(dat_path,fname));
c0 = textscan(f,'%s','HeaderLines',10);%skipe first 10 lines
c = c0{1}(1:end-1);%avoid last line
s = cellfun(@(s)s(2:end),c,'uniformoutput',false);
v0 = hex2dec(s);

v = v0(v0>500);%remove jumps(possibly due to automatic change of gain)
v_max = max(v);
v_min = min(v);

% t_txt = sprintf('%s min:%d,max:%d,diff:%d',fname,v_min,v_max,v_max-v_min);
% figure(3);
% plot(v0,'x-')
% title(t_txt,'interpreter','none')
% min(v0)
% fclose(f);
