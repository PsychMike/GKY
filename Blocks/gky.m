function [Events Parameters Stimuli_sets Block_Export Trial_Export Numtrials] = Demo(Parameters, Stimuli_sets, Trial, Blocknum, Modeflag, Events, Block_Export, Trial_Export, Demodata)
load('blockvars')
KbName('UnifyKeyNames');
if IsOSX | IsLinux; sep = '/'; else sep = '\'; end %slash direction based on OS
if strcmp(Modeflag,'InitializeBlock')
    clear Stimuli_sets
    %Fixation Cross & Instructions
    ins = 1;
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'+','At the beginning of each trial, you''ll be given a category.','Once you start the trial, a stream of images will display.','Keep your eyes on the fixation cross and','try to detect objects that fit the category.','Either one or two target objects will','appear within the stream of images.','Report the objects in the order you saw them.','If you only saw one target object,','type in "Nothing" when asked to report the second target object.','Press the Spacebar when you''re ready to begin.'};
    stimstruct.wrapat = 70;
    stimstruct.vSpacing = 3;
    stimstruct.stimsize = 25;
    Stimuli_sets(ins) = Preparestimuli(Parameters,stimstruct);
    
    %Prompts
    prompts = 2;
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'Rate this image from 1-7:','Your partner rated this image:','Rate how close you feel to your partner from 1-7','Here''s your partner''s rating of closeness to you:'};
    stimstruct.wrapat = 70;
    stimstruct.stimsize = 50;
    Stimuli_sets(prompts) = Preparestimuli(Parameters,stimstruct);
    
    %"Press Spacebar When Ready"
    spacebar = 3;
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'(Press Spacebar when ready)'};
    stimstruct.stimsize = 25;
    Stimuli_sets(spacebar) = Preparestimuli(Parameters,stimstruct);
    
    %Partner's rating
    partner_rating = 4;
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'1','2','3','4','5','6','7'};
    stimstruct.stimsize = 50;
    Stimuli_sets(partner_rating) = Preparestimuli(Parameters,stimstruct);
    
    %Picture of partner
    partner = 5;
    stimstruct = CreateStimStruct('image');
    stimstruct.stimuli = {['collegestudent1.jpg']};
    stimstruct.stimsize = 0.75;
    Stimuli_sets(partner) = Preparestimuli(Parameters,stimstruct);
    
    %TV Shows
    tv_shows = 6;
    tv_dir_name = sprintf('Stimuli%sTV Shows',sep);
    tv_stim_dir = dir(tv_dir_name);
    stimstruct = CreateStimStruct('image');
    for x = 1:length(tv_stim_dir)-2
        stimstruct.stimuli{x} = sprintf('TV Shows%s%s',sep,tv_stim_dir(x+2).name);
    end
    stimstruct.stimsize = 0.5;
    Stimuli_sets(tv_shows) = Preparestimuli(Parameters,stimstruct);
    
    Numtrials = 3;
    
elseif strcmp(Modeflag,'InitializeTrial')
    
    %%Location values%%
    
    %Center location of screen
    locx = Parameters.centerx;
    locy = Parameters.centery;
    
    %Top & bottom areas of the screen
    top = locy - 200;
    bottom = locy + 200;
    
    %Partner picture location
    partner_locx = locx;
    partner_locy = locy - 400;
    
    %Timing Variables
    start_time = 0;
    partner_rate_time = start_time + .01;
    closeness_time = partner_rate_time + 3;
    partner_closeness_time = closeness_time + .01;
    end_time = partner_closeness_time + 3;
    
    %Rate the image
    Events = newevent_show_stimulus(Events,prompts,1,locx,top,start_time,'screenshot_no','clear_yes'); %rate this image
    Events = newevent_show_stimulus(Events,tv_shows,Trial,locx,locy,start_time,'screenshot_no','clear_no'); %image
    
    %Responsestruct
    responsestruct = CreateResponseStruct;
    responsestruct.showinput = 1;
    responsestruct.x = locx;
    responsestruct.y = bottom;
    responsestruct.maxlength = 1;
    responsestruct.minlength = 1;
    responsestruct.allowbackspace = 1;
    responsestruct.waitforenter = 1;
    allowed = [];
    number = {'1!','2@','3#','4$','5%','6^','7&','1','2','3','4','5','6','7'};
    for i=1:length(number)
        allowed = [allowed KbName(number{i})];
    end
    responsestruct.allowedchars = allowed;
    [Events,item_rate] = newevent_keyboard(Events,start_time,responsestruct);
    
    partner_item_rate = randi(7); %random for now
    
    Events = newevent_show_stimulus(Events,prompts,2,locx,top,partner_rate_time,'screenshot_no','clear_yes'); %your partner's item rating
    Events = newevent_show_stimulus(Events,partner_rating,partner_item_rate,locx,bottom,partner_rate_time,'screenshot_no','clear_no'); %rating number
    %     Events = newevent_show_stimulus(Events,partner,1,partner_locx,partner_locy,partner_rate_time,'screenshot_no','clear_no'); %partner pic
    Events = newevent_show_stimulus(Events,tv_shows,Trial,locx,locy,partner_rate_time,'screenshot_no','clear_no'); %image
    
    Events = newevent_show_stimulus(Events,prompts,3,locx,locy,closeness_time,'screenshot_no','clear_yes'); %how close do you feel to your partner?
    
    %Responsestruct
    responsestruct = CreateResponseStruct;
    responsestruct.showinput = 1;
    responsestruct.x = locx;
    responsestruct.y = bottom;
    responsestruct.maxlength = 1;
    responsestruct.minlength = 1;
    responsestruct.allowbackspace = 1;
    responsestruct.waitforenter = 1;
    allowed = [];
    number = {'1!','2@','3#','4$','5%','6^','7&','1','2','3','4','5','6','7'};
    for i=1:length(number)
        allowed = [allowed KbName(number{i})];
    end
    responsestruct.allowedchars = allowed;
    [Events,partner_rate] = newevent_keyboard(Events,closeness_time,responsestruct);
    
    partner_closeness_rate = randi(7); %random for now
    
    Events = newevent_show_stimulus(Events,prompts,4,locx,top,partner_closeness_time,'screenshot_no','clear_yes'); %how close your partner feels to you
    Events = newevent_show_stimulus(Events,partner_rating,partner_closeness_rate,locx,locy,partner_closeness_time,'screenshot_no','clear_no'); %rating number
    %     Events = newevent_show_stimulus(Events,partner,1,partner_locx,partner_locy,partner_closeness_time,'screenshot_no','clear_no'); %partner pic
    
    %Ends trial
    Events = newevent_end_trial(Events,end_time);
    
elseif strcmp(Modeflag,'EndTrial')
    if Parameters.disableinput == 0
        Trial_Export.subjects_item_rate = char(Events.response{item_rate});
        Trial_Export.subjects_partner_rate = char(Events.response{partner_rate});
        Trial_Export.partners_item_rate = partner_item_rate;
        Trial_Export.partners_subject_rate = partner_closeness_rate;
    end
elseif strcmp(Modeflag,'EndBlock')
else   %Something went wrong in Runblock (You should never see this error)
    error('Invalid modeflag');
end
saveblockspace
end