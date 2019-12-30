% Creates a dialogue box to allow for input of inner and outer ring sizes
function FilterEntry(hObject,~,~)
    ValidAnswer = 1;
    while ValidAnswer
        prompt = {'Enter Size of Inner Ring (m)','Enter Size of Outer Ring (m).'};
        dlgtitle = 'Ring Filter Entry';
        dims = [1 35];
        definput = {'0.5','2'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        
        Inner = str2double(convertCharsToStrings(answer(1)));
        Outer = str2double(convertCharsToStrings(answer(2)));
        if (Inner < 0 || Inner > 5 || Outer < 0 || Outer > 5)
            msgbox('Value of Inner/Outer Ring must be between 0m and 5m.');
            pause(2);
        elseif(Inner > Outer)
            msgbox('Value of Outer must be greater than value of Inner.');
            pause(2);
        else
            ValidAnswer = 0;
        end
        
        % changes the data struct to store the info entered
        hObject.UserData.Inner = Inner;
        hObject.UserData.Outer = Outer;
    end
end