% Reports back the new pitch angle
function PitchSlider(a,~,~)
    temp = get(a, 'value');
    x = ['Pitch offset is ', num2str(temp), 'degrees.'];
    disp(x);
end