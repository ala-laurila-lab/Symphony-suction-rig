%% Note for future
% for improvement, one can add start & stop button-GUI like below
function start_stop_recording()
    global flag
    flag = false;
    g = 0;
    FH = figure('Visible','on','Position',[360,500,450,285]);
    h_start = uicontrol('style','push','string','start','Position',[315,220,70,25],...
        'callback',{@start});
    h_stop = uicontrol('style','push','string','stop','Position',[315,180,70,25],...
        'callback',{@stop});
end

function start(hObject,callbackdata)
    global flag
    flag = true;
    go_loop();
end

function stop(hObject,callbackdata)
    global flag
    flag = false;
    go_loop();
end

function go_loop()
    global flag
    while flag
          drawnow
          disp('looping...')
    end
end