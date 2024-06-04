function action(hands, y, outlet)
    % Activate the robotic hand
    % hands: serialport object
    % outlet: labstreaminglayer outlet
    % y: prediction
    

    
    write(hands, 'c', "char"); % Checks if the hands are activated
    disp(readline(hands));
    if nargin == 3
        if y == 1
            side = 'left';
        elseif y == 2
            side = 'right';
        else
            side = 'rest';
        end
        outlet.push_sample(side');
    else
        disp('No outlet provided');
    end
    % left side
    if y == 1
        write(hands, 'l', "char");
    % right side
    elseif y == 2
        write(hands, 'r', "char");
    % rest -> nothing to do
    else    
        return
    end
end