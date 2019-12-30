% ---------------------------------------
% Assignment 1 v2
% Tanson Wang
% Last Modified: 30/09/19
% Notes: It works but the sharing mechanism can be improved
% ---------------------------------------


function Asst1Mine(folder)
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
AngleSlider = uicontrol(s,'slider',S,'Angle Slider',p,[10,50,40,150],c,{@AngleSlider},v,55/90);

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
    depthArray = single(RR)*0.001;
    depthArraySize = size(RR);
    xPoint = single([]);            % Empty Arrays for XYZ dimensions
    yPoint = single([]);
    zPoint = single([]);
    
    xBlue = single([]);             % Empty Arrays for XYZ dimensions
    yBlue = single([]);
    zBlue = single([]);
    
    m = 1;                          % Incrementing value
    for c = 1:depthArraySize(2)     % Analysing the rows second
        for r = 1:depthArraySize(1) % Analysing the columns first
            if (depthArray(r,c) > 0)% Discarding zero depth values
                % Calculations
                xPoint(m) = depthArray(r,c);
                yPoint(m) = depthArray(r,c)*(c-80)*(4/594);
                zPoint(m) = -depthArray(r,c)*(r-60)*(4/592);
                m = m+1;
            end
        end
    end
    
    % ---------------------------------------
    % Checking GUI for inputs and acting accordingly
    RotateOn = get(RotateCheck, 'value');
    FilterOn = get(FilterCheck, 'value');
    angle = get(AngleSlider, 'value')*90-45;
    
    % Rotate the 3D plot according to the slider value
    if RotateOn
        [xPoint, yPoint, zPoint] = Rotate3D(xPoint, yPoint, zPoint, angle);
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
    pause(0.05);     % freeze for about 0.1 second
end
end

% --------------------------------------------------------
% Rotation of the 3D Plot
    function [x, y, z] = Rotate3D(x, y, z, angle)
        Rx = [1 0 0; 0 cosd(angle) -sind(angle); 0 sind(angle) cosd(angle)];
        Ry = [cosd(angle) 0 sind(angle); 0 1 0; -sind(angle) 0 cosd(angle)];
        Rz = [cosd(angle) -sind(angle) 0; sind(angle) cosd(angle) 0; 0 0 1];

        length = size(z);
        xDim = single([]);           % Empty Arrays for XYZ dimensions
        yDim = single([]);
        zDim = single([]);
        for a = 1:length(2)
           xDim(a) = x(a)*Ry(1,1) + y(a)*Ry(1,2)+ z(a)*Ry(1,3);
           yDim(a) = x(a)*Ry(2,1) + y(a)*Ry(2,2)+ z(a)*Ry(2,3);
           zDim(a) = x(a)*Ry(3,1) + y(a)*Ry(3,2)+ z(a)*Ry(3,3)+0.2;
        end
        
        z = zDim;
        y = yDim;
        x = xDim;
    end

% -----------------------------------------
% Filtering Z High and Low
    function [x, y, z] = FilterZ(x, y, z)
        xHLz = single([]);         % Empty Arrays for XYZ dimensions
        yHLz = single([]);
        zHLz = single([]);
        length = size(z);
        n = 1;
        for c = 1:length(2)
           if (z(c) > -0.05 && z(c) < 1)
               zHLz(n) = z(c);
               yHLz(n) = y(c);
               xHLz(n) = x(c);
               n = n+1;
           end
        end
        x = xHLz;
        y = yHLz;
        z = zHLz;
    end
    
% -----------------------------------------
% Filtering Cylindrical Ring
    function [xIn, yIn, zIn, xOut, yOut, zOut] = Ring(x, y, z, Inner, Outer)
        xRing = single([]);         % Empty Arrays for XYZ dimensions
        yRing = single([]);
        zRing = single([]);
        
        xNot = single([]);          % Empty Arrays for XYZ dimensions
        yNot = single([]);
        zNot = single([]);
        
        length = size(z);
        n = 1;
        m = 1;
        for c = 1:length(2)
           cheese = (sqrt(y(c)^2 + x(c)^2));
           if (z(c) > 0.15 && cheese > Inner && cheese < Outer)
               zRing(n) = z(c);
               yRing(n) = y(c);
               xRing(n) = x(c);
               n = n+1;
           else
               zNot(m) = z(c);
               yNot(m) = y(c);
               xNot(m) = x(c);
               m = m+1;
           end
        end
        xIn = xRing;
        yIn = yRing;
        zIn = zRing;
        xOut = xNot;
        yOut = yNot;
        zOut = zNot;
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

% Reports back the new angle
function AngleSlider(a,~,~)
    temp = get(a, 'value')*90-45;
    x = ['Rotational offset is ', num2str(temp), 'degrees.'];
    disp(x);
end

% Does nothing only check by others
function ACorrectCheck(~,~,~)
    
end

% Does nothing only check by others
function UsefulCheck(~,~,~)
    
end

% Creates a dialogue box to allow for input of inner and outer ring sizes
function FilterEntry(hObject,~,~)
    prompt = {'Enter Size of Inner Ring (m)','Enter Size of Outer Ring (m)'};
    dlgtitle = 'Ring Filter Entry';
    dims = [1 35];
    definput = {'0.5','2'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    % changes the data struct to store the info entered
    hObject.UserData.Inner = str2double(convertCharsToStrings(answer(1)));
    hObject.UserData.Outer = str2double(convertCharsToStrings(answer(2)));
end

% Ring Filter lines
function out = DrawRings(hp)
    r=hp;
    teta=-pi:0.01:pi;
    x=r*cos(teta);
    y=r*sin(teta);
    out = plot3(x,y,zeros(1,numel(x)),'--g');
end
    



