% Reports back the new roll angle
function RollSlider(a,~,~)
    temp = get(a, 'value');
    x = ['Roll offset is ', num2str(temp), 'degrees.'];
    disp(x);
end