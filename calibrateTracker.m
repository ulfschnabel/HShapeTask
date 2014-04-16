function calibrateTracker()
    screenNumber=max(Screen('Screens'));
    window=Screen('OpenWindow', 0, [0.5 0.5 0.5], [0 0 1024 768]);
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    [width, height]=Screen('WindowSize', window);
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
    % setup the proper calibration foreground and background colors

    % STEP 4
    el.backgroundcolour = 0.5;
    el.foregroundcolour = 0.5;   
    el=EyelinkInitDefaults(window);
    EyelinkDoTrackerSetup(el);
    Screen('closeall')
    Eyelink('StartRecording')
end
 