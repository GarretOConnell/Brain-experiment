function tdbehave
%dbstop if error % for debugging: trigger a debug point when an error occurs
% input and overwrite check
subjID  = str2double(inputdlg('Enter subject ID','Input required'));
order   = str2double(inputdlg('Enter session order','Input required'));  
if isempty(subjID)||isempty(order)
    disp('Experiment aborted!')
    return    
end
filename        = [pwd '\participant data\behave\tdbehave_subj' num2str(subjID) '_' num2str(order)];
prevfilename    = [pwd '\participant data\behave\tdbehave_subj' num2str(subjID) '_' num2str(setdiff([1 2],order))];
if exist([filename '.mat'],'file')
    resp    = questdlg({['The file ' filename ' already exists.']; 'Do you want to overwrite it?'},...
        'File exists warning','Cancel','Ok','Ok');
    if ~strcmp(resp,'Ok') %abort experiment if overwriting was not confirmed
        disp('Experiment aborted!')
        return
    end
end

% if it is 2nd run then load previous variables for saving 2nd run data
if exist([prevfilename '.mat'],'file')
    load([prevfilename '.mat']);
end
    
%% Psychtoolbox
%  Here, all necessary PsychToolBox functions are initiated and the
%  instruction screens are set up.
delay               = {'1 month','3 months','6 months','9 months','12 months','18 months'}; %
socdist             = {'2nd','10th','24th','43rd'};
sd_oi               = 4;    % social distance for other identity
choiceKey           = {'left','right'};
nlevel              = length(delay);
slevel              = length(socdist);
GBP                 = '£';      % currency
fixedamount         = 100;
dblimit             = 2;        % cut off for indifference point between boundaries  
nsoc                = order;    % which social condition
% default values
varamount{2}(1:nlevel)      = 50;
varamount{1}(1:nlevel)      = 50;
maxB{2}(1:nlevel)           = 0;
minB{2}(1:nlevel)           = 0;
minT{2}(1:nlevel)           = 100;
maxT{2}(1:nlevel)           = 100;
maxB{1}(1:nlevel)           = 0;
minB{1}(1:nlevel)           = 0;
minT{1}(1:nlevel)           = 100;
maxT{1}(1:nlevel)           = 100;

% default modes
choice_index                = {'varresp','fixresp'};
KbName('UnifyKeyNames');    % required
DisableKeysForKbCheck([16]);   % disable shift key
submit = 0;
capson = 'false';

%% Main Experimental SD Loop
try
    PsychJavaTrouble;    
    HideCursor;
    Screen('Preference', 'SkipSyncTests', 1); 
    displays    = Screen('screens');
    [w, wRect]  = Screen('OpenWindow',displays(end),0);    
    scrnRes     = Screen('Resolution',displays(end));               % Get Screen resolution
    [x0 y0]		= RectCenter([0 0 scrnRes.width scrnRes.height]);   % Screen center                      
    Screen('TextFont', w, 'Helvetica');                         
    Screen('TextSize', w, 26);
catch exception
	ShowCursor;
	sca;
	warndlg(sprintf('PsychToolBox has encountered the following error: %s',exception.message),'Error');
	return    
end
FlushEvents;

try
    if order == 1       
        PsychJavaTrouble;
        %PsychDebugWindowConfiguration;
        HideCursor;
        Screen('Preference', 'SkipSyncTests', 0); 
        displays    = Screen('screens');
        [w, wRect]  = Screen('OpenWindow',displays(end),0);    
        scrnRes     = Screen('Resolution',displays(end));               % Get Screen resolution
        [x0 y0]		= RectCenter([0 0 scrnRes.width scrnRes.height]);   % Screen center                      
        Screen('TextFont', w, 'Helvetica');                         
        Screen('TextSize', w, 26);
        line1		= sprintf(['Imagine you have made a list from #1 to #100 of people you know.\n\n\n'... 
                               'At #1 is the closest person in the world to you e.g. family or close friend.\n\n\n'... 
                               'The person at #100 is a complete stranger.\n\n\n'...
                               'The person at #50 is half way between the #1 and #100 person.\n\n\n']);
        line2       = sprintf('Press spacebar to continue');
        DrawFormattedText(w, line1, 'center',wRect(4)*.1,[255 255 0]);
        DrawFormattedText(w, line2, 'center',wRect(4)*.85,[255 255 0]);  
        Screen('Flip', w);% Instructional screen is presented.
        KbWait;
        while KbCheck; end; 
        FlushEvents;
    
        for index = 1:length(socdist)
            soc_instr1      = sprintf(['The ' (socdist{index}) ' position?']);
            soc_instr2      = sprintf('Press enter when finished');
            textrect1       = Screen('TextBounds', w, soc_instr1);
            textrect2       = Screen('TextBounds', w, soc_instr2);
            % Get offset between rect center and top-left corner:
            DrawFormattedText(w, soc_instr1, 'center',wRect(4)*.1,[255 255 0]);
            DrawFormattedText(w, soc_instr2, 'center',wRect(4)*.85,[255 255 0]);
            % Tell Matlab to stop listening to keyboard input
            ListenChar(2);
            strRating = ''; 
            FlushEvents();    

            while true
                % Skip Getchar if first keypress to avoid wait with blank screen
                output = strRating;
                DrawFormattedText(w, soc_instr1, 'center',wRect(4)*.1,[255 255 0]);
                DrawFormattedText(w, soc_instr2, 'center',wRect(4)*.85,[255 255 0]);
                DrawFormattedText(w, output, 'center',wRect(4)*.5,[255 255 255]);        
                Screen('Flip', w);

                KbWait([],2)% Wait for any key.              
                [keyIsDown,secs,keyCode] = KbCheck;                        
                if find(keyCode, 1, 'first') == 16
                    % if shift get second keypress
                    FlushEvents;
                    [ch, when] = GetChar;
                end
                while ~KbCheck end;
                char = find(keyCode, 1, 'first');

                switch (abs(char))
                    case {13, 3, 10}
                        % ctrl-C, enter, or return
                        break;
                    case 8
                        % backspace
                        if ~isempty(strRating)
                            strRating = strRating(1:length(strRating)-1);
                        end
                    case 20
                        % capslock                    
                        if strcmp(capson,'true');
                            capson = 'false';
                        else
                            capson = 'true';
                        end
                    case 16
                        % shift
                        strRating = [strRating upper(KbName(ch))];
                     case 32
                        % space
                        if ~isempty(strRating)
                            strRating = [strRating ' '];
                        end
                    otherwise
                        if strcmp(capson,'true');
                           strRating = [strRating, upper(KbName(char))];
                        else 
                           strRating = [strRating, lower(KbName(char))];                      
                        end
                end
            end
            % save identity
            soc_array{index} = output;
            % Tell Matlab to start listening to keyboard input again
            ListenChar(1);
        end
        FlushEvents;

        %% social distance review choices screen.
        line1      = sprintf('To change list move the red box up or down and press enter');
        line2      = sprintf('Press spacebar to continue');  

        for index = 1:length(socdist)  
            socbox{index}      = sprintf(socdist{index});
            socrect(1:4,index)        = [x0+200 (wRect(4)*.15+wRect(4)*.1*index) x0+300 (wRect(4)*.15+70+wRect(4)*.1*index)];       
            % selection box colours
            if index > 1
                rectcol(1:3,index)        = [0 255 0];
            else    
                rectcol(1:3,index)        = [255 0 0];
            end
        end
        % Tell Matlab to stop listening to keyboard input
        ListenChar(2); 
        FlushEvents(); 
        strRating = ''; 
        capson = 'false';
        while true
            DrawFormattedText(w, line1, 'center',wRect(4)*.1,[255 255 0]);
            DrawFormattedText(w, line2, 'center',wRect(4)*.85,[255 255 0]);

            for index = 1:length(socdist)                  
                Screen('DrawText', w, socbox{index}, socrect(1,index)+10, socrect(2,index)+20, [255 255 0]);
                Screen('DrawText', w, soc_array{index}, socrect(1,index)-500, socrect(2,index)+20, [255 255 0]);
            end    
            Screen('FrameRect', w, rectcol, socrect, 5); 
            Screen('Flip', w);

            % KbCWait needed as GetChar does not record arrow keys            
            KbWait([],2)% Wait for any key.
            [keyIsDown,secs,keyCode] = KbCheck; 
            while ~KbCheck end;
            char = find(keyCode, 1, 'first');
            switch (abs(char))

                case {3, 10, 32}
                    % ctrl-C, enter, or return                    
                    break;
                case 38
                    % move box up
                [row col] = find(rectcol(1,:)>0); 
                if col == 1;
                else
                    rectcol(:,col)   = [0 255 0];
                    rectcol(:,col-1) = [255 0 0];
               end
               case 40
                    % move box down
               [row col] = find(rectcol(1,:)>0); 
               if col == length(socdist);
               else
                    rectcol(:,col)   = [0 255 0];
                    rectcol(:,col+1) = [255 0 0];                   
               end    
               case 13
                   while true
                        % Skip GetChar if first keypress to avoid wait with blank screen
                        output      = strRating;   
                        [row col]   = find(rectcol(1,:)>0); 
                        soc_instr1  = sprintf(['The ' (socdist{col}) ' position?']);

                        DrawFormattedText(w, soc_instr1, 'center',wRect(4)*.1,[255 255 0]);
                        DrawFormattedText(w, soc_instr2, 'center',wRect(4)*.85,[255 255 0]);
                        DrawFormattedText(w, output, 'center',wRect(4)*.5,[255 255 255]); 
                        Screen('Flip', w);
                        DisableKeysForKbCheck([9,17,18]) % disable special keys

                        KbWait([],2)% Wait for any key.              
                        [keyIsDown,secs,keyCode] = KbCheck;                        
                        if find(keyCode, 1, 'first') == 16
                            % if shift get second keypress
                            FlushEvents;
                            [ch, when] = GetChar;
                        end
                        while ~KbCheck end;
                        char = find(keyCode, 1, 'first');
                        switch (abs(char))
                            case {13, 3, 10}
                                % ctrl-C, enter, or return
                                break;
                            case 8
                                % backspace
                                if ~isempty(strRating)
                                    strRating = strRating(1:length(strRating)-1);
                                end
                                output = strRating;   
                            case 32
                                % space
                                if ~isempty(strRating)
                                   strRating = [strRating ' '];
                                end
                            case 16
                                % shift
                                strRating = [strRating upper(KbName(ch))];
                            case 20
                                % capslock
                                if strcmp(capson,'true');
                                    capson = 'false';
                                else
                                    capson = 'true';
                                end
                            otherwise         
                                if strcmp(capson,'true');
                                    strRating = [strRating, upper(KbName(char))];
                                else 
                                    strRating = [strRating, lower(KbName(char))];                      
                                end                                          
                        end
                    end
                    % save identity
                    soc_array{col} = output;
                    % Tell Matlab to start listening to keyboard input again
                    ListenChar(1);
                    strRating = '';
                end         
        end
        ListenChar(1);   
        FlushEvents(); 
    end
catch exception
    ShowCursor;
    sca;
    warndlg(sprintf('PsychToolBox has encountered the following error: %s',exception.message),'Error');
    return
end
FlushEvents;

%% Main Experimental Loop TD Other
ntrial(1:2)     = 0;
TDindiff{nsoc}  = zeros(nlevel,1);
rectleft        = [x0-450 y0-50 x0-220 y0+50];
rectright       = [x0+220 y0-50 x0+450 y0+50];
rectleftGBP     = [x0-500 y0-50 x0-450 y0+50];
rectrightGBP    = [x0+170 y0-50 x0+220 y0+50];
ypos_question   = rectleft(4)+50;
ypos_option     = rectleft(4)-80;
ypos_GBP        = rectleft(4)-80;
recipient       = sprintf(['for ' soc_array{sd_oi}]);
try    
    while any(TDindiff{nsoc}==0)
        if ntrial(nsoc) == 0
            Screen('TextSize', w, 26);
            if nsoc == 1
                line1		= sprintf(['Next you will be asked to choose between some money now or more later\n\n\n'...
                                       'as if you were someone you know. '...
                                       'For example:\n\n\n'...
                                       'Would ' soc_array{sd_oi} ' prefer\n\n\n'...
                                       '£50 NOW\n\n\n'...
                                       'OR\n\n\n'...
                                       '£100 in a YEAR']);
            else line1		= sprintf(['be asked to choose between some money now or more later\n\n\n'...
                                       'and asked to choose which one you would prefer. '...
                                       'For example:\n\n\n'...
                                       'Would you prefer\n\n\n'...
                                       '£50 NOW\n\n\n'...
                                       'OR\n\n\n'...
                                       '£100 in a YEAR']);
            end
            line2		= sprintf('Press spacebar to continue');       
            DrawFormattedText(w,line1,'center',wRect(4)*.1,[255 255 0]);
            DrawFormattedText(w,line2,'center',wRect(4)*.85,[255 255 0]);               
            Screen(w, 'Flip'); 
            RestrictKeysForKbCheck(KbName('space')); % allow only certain responses
            KbWait([],2); % Wait for any key.            
            ntrial(nsoc) = ntrial(nsoc) + 1;

        else
            % blank the Screen and wait a second
            Screen('FillRect',w,[0]);
            Screen(w,'Flip');
            WaitSecs(.25);

            % define task trial stimuli
            Screen('TextSize', w, 50); 
            cbside      = round(1+rand());  
            cbotherside = setdiff([1 2],cbside);
            clevel      = round(1+(nlevel-1)*rand());
            while TDindiff{nsoc}(clevel)~=0
                clevel = round(1+(nlevel-1)*rand());
            end                
            trialStart		= GetSecs;
            % assign new values.
            maximumB{nsoc}(clevel) = maxB{nsoc}(clevel);
            minimumB{nsoc}(clevel) = minB{nsoc}(clevel);
            minimumT{nsoc}(clevel) = minT{nsoc}(clevel);
            maximumT{nsoc}(clevel) = maxT{nsoc}(clevel);

            option{cbside}                      = sprintf([num2str(varamount{nsoc}(clevel))]);
            option{cbotherside}                 = sprintf([num2str(fixedamount)]);
            question{cbside}                    = sprintf('Now');
            question{cbotherside}               = sprintf(delay{clevel}); 

            fixresp                             = cbotherside;
            varresp                             = cbside;                  
            response{cbside}                    = {'varresp'};% needed to index user response
            response{cbotherside}               = {'fixresp'}; 

            % get center of text boundries in choice box
            TextcenterL1        = Screen('TextBounds', w, option{1});
            TextcenterR1        = Screen('TextBounds', w, option{2});
            TextcenterL2        = Screen('TextBounds', w, question{1});
            TextcenterR2        = Screen('TextBounds', w, question{2});
            TextcenterGBP       = Screen('TextBounds', w, GBP);

            % get offset between rect center and top-left corner
            [xoffsetL1, yoffset]            = RectCenter(TextcenterL1);
            [xoffsetR1, yoffset]            = RectCenter(TextcenterR1);
            [xoffsetL2, yoffset]            = RectCenter(TextcenterL2);
            [xoffsetR2, yoffset]            = RectCenter(TextcenterR2);
            [xoffsetGBP, yoffset]           = RectCenter(TextcenterGBP);
            [centerLx centerLy]             = RectCenter(rectleft);
            [centerRx centerRy]             = RectCenter(rectright);
            [centerLGBP centery]            = RectCenter(rectleftGBP);
            [centerRGBP centery]            = RectCenter(rectrightGBP);
            xpL1 = centerLx - xoffsetL1;
            xpR1 = centerRx - xoffsetR1;
            xpL2 = centerLx - xoffsetL2;
            xpR2 = centerRx - xoffsetR2;
            xpLGBP  = centerLGBP - xoffsetGBP;          
            xpRGBP  = centerRGBP - xoffsetGBP;  

            Screen('FillRect', w, 0);
            Screen('FillRect', w, [255], rectleft);    
            Screen('FillRect', w, [255], rectright); 
            Screen('FillRect', w, 0, rectleftGBP);
            Screen('FillRect', w, 0, rectrightGBP);

            DrawFormattedText(w, question{1}, xpL2, ypos_question,[255 255 0]);
            DrawFormattedText(w, question{2}, xpR2, ypos_question,[255 255 0]);
            DrawFormattedText(w, option{1}, xpL1, ypos_option, [0]);
            DrawFormattedText(w, option{2}, xpR1, ypos_option, [0]);                                              
            if nsoc ==1, DrawFormattedText(w, recipient, 'center', ypos_question+100,[255 0 255]); end                                              
            DrawFormattedText(w, GBP, xpRGBP, ypos_option, [255 255 0]);
            DrawFormattedText(w, GBP, xpLGBP, ypos_option, [255 255 0]);
            Screen(w, 'Flip'); 

            trialStart	= GetSecs;                              

            RestrictKeysForKbCheck(KbName(choiceKey)); % allow only certain responses
            KbWait([],2); % Wait for any key.
            [keyIsDown,secs,keyCode] = KbCheck; 
            % Wait for any key.
            while ~KbCheck end;
            ch = find(keyCode, 1, 'first');
            button = intersect([37,39], ch);

            if ~isempty(button)
                useranswer = find(ismember(choiceKey,KbName(ch)));
                TDdata{nsoc}(ntrial(nsoc),1)    = secs - trialStart;
                TDdata{nsoc}(ntrial(nsoc),2)    = clevel;
                TDdata{nsoc}(ntrial(nsoc),3)    = find(ismember(choice_index,response{useranswer}));            

                if useranswer == fixresp && varamount{nsoc}(clevel) > minimumB{nsoc}(clevel) 
                   maxB{nsoc}(clevel) = minimumB{nsoc}(clevel);
                   minB{nsoc}(clevel) = varamount{nsoc}(clevel);
                end 
                if useranswer == fixresp && varamount{nsoc}(clevel) <= minimumB{nsoc}(clevel)  
                   maxB{nsoc}(clevel) = varamount{nsoc}(clevel);
                end 
                if useranswer == fixresp && varamount{nsoc}(clevel) > minimumT{nsoc}(clevel) 
                   minT{nsoc}(clevel) = varamount{nsoc}(clevel);
                   maxT{nsoc}(clevel) = fixedamount;
                end
                if useranswer == varresp && varamount{nsoc}(clevel) < minimumT{nsoc}(clevel)  
                   maxT{nsoc}(clevel) = minimumT{nsoc}(clevel);
                   minT{nsoc}(clevel) = varamount{nsoc}(clevel);
                end	
                if useranswer == varresp && varamount{nsoc}(clevel) >= minimumT{nsoc}(clevel)
                   maxT{nsoc}(clevel) = varamount{nsoc}(clevel);
                end
                if useranswer == varresp && varamount{nsoc}(clevel) < minimumB{nsoc}(clevel) 
                   minB{nsoc}(clevel) = varamount{nsoc}(clevel);
                   maxB{nsoc}(clevel) = 0 ;
                end

                oldvaramount                = varamount{nsoc}(clevel);                        
                TDdata{nsoc}(ntrial(nsoc),4)      = varamount{nsoc}(clevel); 
                ntrial(nsoc)                = ntrial(nsoc)+1;  % trial counter                                                   

                if maxT{nsoc}(clevel)-maxB{nsoc}(clevel) <= dblimit   % indifference point check                                   
                   TDindiff{nsoc}(clevel)                 = maxT{nsoc}(clevel) - (maxT{nsoc}(clevel) - maxB{nsoc}(clevel))*.5;                    
                   continue 
                end

                while   varamount{nsoc}(clevel) == oldvaramount|| varamount{nsoc}(clevel) == 100 || varamount{nsoc}(clevel) == 0
                        varamount{nsoc}(clevel) = round(maxB{nsoc}(clevel)+(maxT{nsoc}(clevel)-maxB{nsoc}(clevel))*rand());
                end
            end
        end
       FlushEvents; 
    end
catch exception
	ShowCursor;
	sca;
	warndlg(sprintf('PsychToolBox has encountered the following error: %s',exception.message),'Error');
	return
end


%% save
if exist([prevfilename '.mat'],'file')
    save(prevfilename, 'soc_array','TDindiff','TDdata');    % save output 
else
    save(filename, 'soc_array','TDindiff','TDdata');    % save output 
end


try	   
	Screen('TextFont', w, 'Helvetica');                         
	Screen('TextSize', w, 26);
    line1		= sprintf(['Well done! Thank you']);
    DrawFormattedText(w, line1, 'center',wRect(4)*.6,[124 252 0]);  
    Screen('Flip', w);% Instructional screen is presented.
    RestrictKeysForKbCheck(KbName('space'));
    KbWait([],2) 
catch exception
	ShowCursor;
	sca;
	warndlg(sprintf('PsychToolBox has encountered the following error: %s',exception.message),'Error');
	return
end
RestrictKeysForKbCheck([]);
FlushEvents
sca; 
clear all
end
