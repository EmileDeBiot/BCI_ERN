function action(hands, y)
    % Activate the robotic hand
    % hands: serialport object
    % y: prediction

    % write(hands, 'c', "char"); % Checks if the hands are activated
    % left side
    if y == 1
        write(hands, 'l', "char");
    % right side
    elseif y == 2
        write(hands, 'r', "char");
    % rest -> nothing to do
    end
end