% ---------------------------------------
% Assignment 1 v3
% Tanson Wang
% Last Modified: 30/09/19
% Notes: Uses Global instead of struct for ring size
% ---------------------------------------


function Asst1v3Simple(folder)
clc();
if ~exist('folder','var')
    disp('YOU must specify the folder, where the files are located!');
    disp('We assume some default folder:');
    folder = '.\data\HomeC002\';
end
disp('Using data from folder:');
disp(folder);
 
% load Depth and RGB images.
A = load([folder,'\PSLR_C01_120x160.mat']); CC=A.CC ; A=[];
A = load([folder,'\PSLR_D01_120x160.mat']); CR=A.CR ; A=[];

% length
L  = CR.N;

% Some global variable, for being shared (you may use nested functions, 
% in place of using globals).
global CCC; 
CCC=[]; CCC.flagPause=0; 
global Inner;
Inner = 0.5;
global Outer
Outer = 2;

%--------------------------------------------------------
figure(1); clf();

% Depth Subplot
subplot(2,1,1) ; 
RR=CR.R(:,:,1);                 % RR is used in other locations as well
hd = imagesc(RR);
title('Depth');
colormap gray;
set(gca(),'xdir','reverse');

% RGB Subplot
subplot(212) ; 
hc = image(CC.C(:,:,:,1));
title('RGB');
set(gca(),'xdir','reverse');

% 3D Plot
figure(2) ; clf() ; 
ha=axes('position',[0.20,0.1,0.75,0.85]); 
hp2 = 0;                                     % Used for filtered sight
hp = plot3(ha,0,0,0,'.b','markersize',2);    % General use
axis([0,3,-1.5,1.5,-0.4,1.2]);
title('My 3D');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
grid on;
rotate3d on ;

% Buttons x2, Slider x1 & CheckBox
s = 'Style';
S = 'String';
p = 'Position';
c = 'CallBack';
v = 'Value';

uicontrol(s,'togglebutton',S,'Pause/Cont.',p,[10,1,80,20],c,{@PauseButton});

% A button that brings up a dialogue box for the ring sizes
uicontrol(s,'push',S,'Ring Filter',p,[10,21,80,20],c,{@FilterEntrySimple});

% Starts at 10 degrees with limits from -45 to 45
PitchValue = uicontrol(s,'slider',p,[10,50,40,100],c,{@PitchSlider},...
v,-10,'Max',45,'Min',-45,'tooltip','Pitch Slider');
% Starts at 0 degrees with limits from -45 to 45
RollValue = uicontrol(s,'slider',p,[50,50,40,100],c,{@RollSlider},...
v,0,'Max',45,'Min',-45,'tooltip','Roll Slider');

% Starts checked so the image is flat
RotateCheck = uicontrol(s,'checkbox',S,'Rotation',p,[100,1,100,10],v,1);

% Starts unchecked
FilterCheck = uicontrol(s,'checkbox',S,'Filter',p,[200,1,100,10]);


% --------------------------------------------
% All actual Processes
i = 0;
while 1
    while (CCC.flagPause)
        pause(0.3); 
    end       % stay here, if paused.
    i=i+1;
    
    if i>L                          % Check for the video ending
        break; 
    end
    
    % Load and set new RGB and Depth images
    set(hc,'cdata',CC.C(:,:,:,i));  % Show RGB image
    RR=CR.R(:,:,i);                 % Load depth image
    set(hd,'cdata',RR);             % Show depth image.

    %---------------------------------------
    % Depth to 3D
    xRed = single([]);             % Empty Arrays for XYZ dimensions
    yRed = single([]);
    zRed = single([]);
    
    [xPoint, yPoint, zPoint] = Depthto3D(RR);
    
    % ---------------------------------------
    % Checking GUI for inputs and acting accordingly
    RotateOn = get(RotateCheck, 'value');
    FilterOn = get(FilterCheck, 'value');
    Pitch = get(PitchValue, 'value');
    Roll = get(RollValue, 'value');
    
    % Rotate the 3D plot according to the slider value
    if RotateOn
        [xPoint,yPoint,zPoint] = Rotate3D(xPoint,yPoint,zPoint,-Pitch,1);
        [xPoint,yPoint,zPoint] = Rotate3D(xPoint,yPoint,zPoint,Roll,2);
    end
    zPoint = zPoint +0.2;           %Z value adjustment
    
    % Filter the 3D plot after locating and getting values from the 'Ring
    % Filter' button's data struct
    if FilterOn
        [xPoint, yPoint, zPoint] = FilterZ(xPoint, yPoint, zPoint);
        [xRed, yRed, zRed, xPoint, yPoint, zPoint] = ...
        Ring(xPoint, yPoint, zPoint, Inner, Outer);
    end
    
    % ------------------------------------------------
    % Set the 3D plots
    % Delete any prexisting plots
    hold on                         % Used to allow for filtered layers
    set(hp,'xdata',-10,'ydata',-10,'zdata',-10);
    if (hp2 ~= 0)
        reset(hp2)
        reset(hp3)
        reset(hp4)
    end
    
    % Print the general plot
    % if the filter is on then print the useful points
    set(hp,'xdata',xPoint,'ydata',yPoint,'zdata',zPoint);
    if FilterOn
        hp2 = plot3(ha,0,0,0,'.r','markersize',2);
        set(hp2,'xdata',xRed,'ydata',yRed,'zdata',zRed);
        hp3 = DrawRings(Inner);
        hp4 = DrawRings(Outer);
    end
    hold off                        % Filtered layers end
    pause(0.05);     % freeze for about 0.1 second
    
end
end

% -----------------------------------------
% Function Callback A.K.A Gui
% Changes the Global CCC flag to Pause and Continue
function PauseButton(~,~,~)
    global CCC
    CCC.flagPause = ~CCC.flagPause;
    if (CCC.flagPause == 0)
       disp('You continued it~~~') 
    end
    if (CCC.flagPause == 1)
       disp('You paused it~~~') 
    end
end

% Ring Filter lines
function out = DrawRings(hp)
    r=hp;
    teta=-pi:0.01:pi;
    x=r*cos(teta);
    y=r*sin(teta);
    out = plot3(x,y,zeros(1,numel(x)),'--g');
end


