function run

PsychDefaultSetup(1);
EyelinkInit(0, 1)
global Par
logon = 0;
pixperdeg = 37;
nts = [];
session = [];
logchoice = 0;
while ~logchoice
    answer = inputdlg({'Name', 'Session number'},'Please enter your details',1);
    nts = answer{1};
    session = answer{2};
    logon = 1;
    if isempty(nts) || isempty(session)
        choice = questdlg('Are you sure you dont want a log?', 'Confirm', 'Yes','No','No');
        if strcmp(choice, 'Yes')
            logchoice = 1;
            choice = questdlg('Do you want to go through training?', 'Training', 'Yes','No','No');
            if strcmp(choice, 'Yes')
                session = '1';
            else
                session = '2';
            end
        end
    else
        logchoice = 1;
    end
end
calibrateTracker
if ~isempty(nts); logon = 1; end
grey = .5;
cgopen(1024, 768, 32,60 ,0)
cgflip(grey, grey, grey)
cgpenwid(1)
cgpencol(1,0,0)
cgfont('Arial',30)
cgflip(grey,grey,grey)
targets = [7, 45];

distractors = [35, 48];

targetpos = [1 3 5];


if str2num(session) == 1
    %Learn targets
    
    cgpencol(0,1,0)
    cgtext('Use y and m to indicate which object is on the screen.' ,0 ,50)
    cgtext('You will quickly learn the mapping by trial and error.' ,0,0)
    cgtext('Press any key to continue' ,0,-50)
    cgflip(grey,grey,grey)
    cgpencol(1,0,0)
    pause
    
    hits = [0 0];
    stage = 0;
    n = 0;
    Par.Ndistract = 0;
    while Par.Ndistract < n
        ESC = 0;
        if stage == 0 && hits(1) > 5 && hits(2) > 5
            stage = 1;
            hits = [0 0];
            Par.Ndistract = 1;
            cgpencol(0,1,0)
            cgtext('Well done, now a distractor is added to the display.',0,0)
            cgtext('Press any key to continue' ,0,-50)
            cgflip(grey,grey,grey)
            cgpencol(1,0,0)
            pause
        elseif stage > 0 && hits(1) > 5 && hits(2) > 5 && Ndistract < n
            hits = [0 0];
            Ndistract = Ndistract + 2;
            cgpencol(0,1,0)
            cgtext('Well done, now two more distractors are added to the display.',0,0)
            cgtext('Press any key to continue' ,0,-50)
            cgflip(grey,grey,grey)
            cgpencol(1,0,0)
            pause
        end
        
        cgellipse(0,0, 15, 15, [0 0 0], 'f')
        cgflip(grey,grey,grey)
        fixstart = tic;
        fixtime = tic;
        fixation = 0;
        %wait for fixation
        eye_used = 0;
        while ~fixation
            if Eyelink( 'NewFloatSampleAvailable') > 0
                % get the sample in the form of an event structure
                evt = Eyelink( 'NewestFloatSample');
                if eye_used ~= -1 % do we know which eye to use yet?
                    % if we do, get current gaze position from sample
                    x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = evt.gy(eye_used+1);
                    % do we have valid data and is the pupil visible?
                    if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                        mx=x;
                        my=y;
                    end
                end
            end
            if abs(mx - 512) < 30 && abs(my - 768/2) < 30
                fixation = 1;
            end
        end
        disp('Good')
        %check if fixation is kept
        fixtime = tic;
        while toc(fixtime) < 2
            if Eyelink( 'NewFloatSampleAvailable') > 0
                % get the sample in the form of an event structure
                evt = Eyelink( 'NewestFloatSample');
                if eye_used ~= -1 % do we know which eye to use yet?
                    % if we do, get current gaze position from sample
                    x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = evt.gy(eye_used+1);
                    % do we have valid data and is the pupil visible?
                    if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                        mx=x;
                        my=y;
                    end
                end
            end
            if ~(abs(mx - 512) < 30 && abs(my - 768/2) < 30)
                cgpencol(1,0,0)
                cgtext('Please keep fixating.',0,0)
                cgflip(grey,grey,grey)
                cgpencol(1,0,0)
                pause(0.5)
                cgflip(grey,grey,grey)
                abort = 1;
            end
        end
        disp('Done')
        abort = 1;
        %Draw display
        if ~abort
            Par.Target = trials(1, 1);
            Par.Distractor = trials(1, 2);
            Par.Targetpos = trials(1, 3);
            Par.Distractorpos = trials(1, 4);
            if isempty(trials)
                details = filldetails();
                order = randperm(length(details(:,1)));
                trials = details(order, :);
            end
            
            cgdrawsprite(1, 0, 0)
            cgellipse(0,0, 15, 15, [0 0 0], 'f')
            cgflip(grey,grey,grey)
            tic
            %Wait for response and check if fixation is being kept
            while ~ESC && ~abort
                [~,kp] = cgkeymap;
                if length(find(kp)) == 1
                    if find(kp) == 50;
                        ESC = 1;
                        if target ~= 2
                            cgtext('Wrong',0,0)
                            cgflip(grey,grey,grey)
                            pause(1)
                            cgflip(grey,grey,grey)
                            hits(2) = 0;
                        else
                            hits(2) = hits(2) + 1;
                        end
                    elseif find(kp) == 44;
                        ESC = 1;
                        if target ~= 1
                            cgtext('Wrong',0,0)
                            cgflip(grey,grey,grey)
                            pause(1)
                            cgflip(grey,grey,grey)
                            hits(1) = 0;
                        else
                            hits(1) = hits(1) + 1;
                        end
                    end
                else
                    if Eyelink( 'NewFloatSampleAvailable') > 0
                        % get the sample in the form of an event structure
                        evt = Eyelink( 'NewestFloatSample');
                        if eye_used ~= -1 % do we know which eye to use yet?
                            % if we do, get current gaze position from sample
                            x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                            y = evt.gy(eye_used+1);
                            % do we have valid data and is the pupil visible?
                            if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                                mx=x;
                                my=y;
                            end
                        end
                    end
                    if ~(abs(mx) < 15 && abs(my) < 15)
                        cgpencol(1,0,0)
                        cgtext('Please keep fixating.',0,0)
                        cgflip(grey,grey,grey)
                        cgpencol(1,0,0)
                        pause(0.5)
                        abort = 1;
                    end
                end
                
                
            end
            RT = toc;
            cgflip(grey,grey,grey)
        end
    end
end
%% Actual Experiment
cgpencol(0,1,0)
cgtext('Good job, training is over.',0,0)
cgtext('Press any key to continue' ,0,-50)
cgflip(grey,grey,grey)
cgpencol(1,0,0)
pause
tc = 0;
while tc < 20
    tc = tc + 1;
    cgellipse(0,0, 15, 15, [0 0 0], 'f')
    cgflip(grey,grey,grey)
    
    cgdrawsprite(1, 0, 0)
    cgellipse(0,0, 15, 15, [0 0 0], 'f')
    cgflip(grey,grey,grey)
    tic
    while ~ESC
        [kd,kp] = cgkeymap;
        if length(find(kp)) == 1
            if find(kp) == 50;
                ESC = 1;
                if target ~= 2
                    cgtext('Wrong',0,0)
                    cgflip(grey,grey,grey)
                    pause(1)
                    cgflip(grey,grey,grey)
                    hit = 0;
                else
                    hit = 1;
                end
            elseif find(kp) == 44;
                ESC = 1;
                if target ~= 1
                    cgtext('Wrong',0,0)
                    cgflip(grey,grey,grey)
                    pause(1)
                    cgflip(grey,grey,grey)
                    hit = 0;
                else
                    hit =  1;
                end
            end
        end
    end
    RT = toc;
    Log.Trial(tc) = tc;
    Log.Target(tc) = targets(target);
    Log.Distractor(tc) = distractors(distractor);
    Log.Display(tc) = {typevec};
    Log.Hit(tc) = hit;
    Log.RT(tc) = RT;
    if logon
        save(['log/' nts session],'Log');
    end
    cgflip(grey,grey,grey)
end

cgshut

end



function details = filldetails()
n = 0;
for t = 1:2
    for d = 1:2
        for tp = 1:3
            for dp = 1:3
                if tp ~= dp
                    n = n+1;
                    details(n, :) = [t, d, tp, dp, n];
                end
            end
        end
    end
end
end