% ---------------------------------------
% Assignment 1 v2
% Tanson Wang
% Last Modified: 30/09/19
% Notes: Not really changed
% ---------------------------------------


function Asst1v3(folder)
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
hp4 = plot3(ha,0,0,0,'.','markersize',2);
hp3 = plot3(ha,0,0,0,'.','markersize',2);
hp2 = plot3(ha,0,0,0,'.','markersize',2);   % Used for filtered sight
hp = plot3(ha,0,0,0,'.','markersize',2);    % General use
axis([0,3,-1.5,1.5,-0.4,0.9]);
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
u = 'UserData';

uicontrol(s,'push',S,'Pause/Cont.',p,[10,1,80,20],c,{@PauseButton});

% The Filter button has an inbuilt struct that carries the data for the
% rings, hence all data regarding the size of the rings will be here.
uicontrol(s,'push',S,'Ring Filter',p,[10,21,80,20],c,{@FilterEntry},u, struct('Inner',0.5,'Outer',2),'Tag','RINGFILTER');

% Starts at 10 degrees and can go from -45 to 45
PitchSlider = uicontrol(s,'slider',p,[10,50,40,100],c,{@PitchSlider},v,35/90);
RollSlider = uicontrol(s,'slider',p,[50,50,40,100],c,{@RollSlider},v,0.5);

% Starts checked so the image is flat
RotateCheck = uicontrol(s,'checkbox',S,'Rotation',p,[100,1,100,10],c,{@ACorrectCheck},v,1);

% Starts unchecked
FilterCheck = uicontrol(s,'checkbox',S,'Filter',p,[200,1,100,10],c,{@UsefulCheck});


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
    xBlue = single([]);             % Empty Arrays for XYZ dimensions
    yBlue = single([]);
    zBlue = single([]);
    
    depthArray = single(RR)*0.001;  % Scale the depth in m from mm
    depthArraySize = size(RR);      % Get the size
    indDepth = find(depthArray>0);  % Index (all > 0 values) the depth
    % Put the indexed positions into the original array to get a vector of
    % all of the > 0 numbers.
    Not0Points = depthArray(indDepth);
    % Turn the index into two linear arrays which contain the row and the
    % column for the position stored in the index vector
    [R, C] = ind2sub(depthArraySize,indDepth);
    
    % Calculations
    xPoint = (Not0Points)';
    yPoint = (Not0Points.*(C-80)*(4/594))';
    zPoint = (-Not0Points.*(R-60)*(4/592)-0.2)';
    
    
    % ---------------------------------------
    % Checking GUI for inputs and acting accordingly
    RotateOn = get(RotateCheck, 'value');
    FilterOn = get(FilterCheck, 'value');
    Pitch = get(PitchSlider, 'value')*90-45;
    Roll = get(RollSlider, 'value')*90-45;
    
    % Rotate the 3D plot according to the slider value
    if RotateOn
        [xPoint,yPoint,zPoint] = Rotate3D(xPoint,yPoint,zPoint,-Pitch,1);
        [xPoint,yPoint,zPoint] = Rotate3D(xPoint,yPoint,zPoint,Roll,2);
    end
    
    % Filter the 3D plot after locating and getting values from the 'Ring
    % Filter' button's data struct
    if FilterOn
        [xPoint, yPoint, zPoint] = FilterZ(xPoint, yPoint, zPoint);
        h = findobj('Tag','RINGFILTER');
        Inner = h.UserData.Inner;
        Outer = h.UserData.Outer;
        [xPoint, yPoint, zPoint, xBlue, yBlue, zBlue] = Ring(xPoint, yPoint, zPoint, Inner, Outer);
    end
    
    % ------------------------------------------------
    % Set the 3D plots
    
    % Delete any prexisting plots
    delete(hp);
    if (hp2 ~= 0)
        delete(hp2)
        delete(hp3)
        delete(hp4)
    end
    
    % If the filter is on, print two plots in different colours
    % Else just print the general plot in Blue
    if FilterOn
        hold on;
        hp = plot3(ha,0,0,0,'.r','markersize',2);
        set(hp,'xdata',xPoint,'ydata',yPoint,'zdata',zPoint); 
        hp2 = plot3(ha,0,0,0,'.b','markersize',2);
        set(hp2,'xdata',xBlue,'ydata',yBlue,'zdata',zBlue);
        hp3 = DrawRings(Inner);
        hp4 = DrawRings(Outer);
        hold off;
    else
        hold on;
        hp = plot3(ha,0,0,0,'.b','markersize',2);
        set(hp,'xdata',xPoint,'ydata',yPoint,'zdata',zPoint);
        hold off;
    end
    pause(0.1);     % freeze for about 0.1 second
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

% Reports back the new pitch angle
function PitchSlider(a,~,~)
    temp = get(a, 'value')*90-45;
    x = ['Pitch offset is ', num2str(temp), 'degrees.'];
    disp(x);
end

% Reports back the new roll angle
function RollSlider(a,~,~)
    temp = get(a, 'value')*90-45;
    x = ['Roll offset is ', num2str(temp), 'degrees.'];
    disp(x);
end

% Does nothing only check by others
function ACorrectCheck(~,~,~)
    
end

% Does nothing only check by others
function UsefulCheck(~,~,~)
    
end

% Ring Filter lines
function out = DrawRings(hp)
    r=hp;
    teta=-pi:0.01:pi;
    x=r*cos(teta);
    y=r*sin(teta);
    out = plot3(x,y,zeros(1,numel(x)),'--g');
end
    



