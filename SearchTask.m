function run

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

if ~isempty(nts); logon = 1; end
grey = .5;
cgopen(1024, 768, 32,60 ,0)
cgflip(grey)
cgpenwid(1)
cgpencol(1,0,0)
cgfont('Arial',30)
cgflip(grey,grey,grey)
stimuli = {};
load('GoodHalfCircle');

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
    Par.Ndistract = 0;
    while Par.Ndistract < n
        cgellipse(0,0, 15, 15, [0 0 0], 'f')
        cgflip(grey,grey,grey)
        pause(0.5)
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
            end
        end
        RT = toc;
        cgflip(grey,grey,grey)
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

