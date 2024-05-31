function action(hands, y, outlet)
    % Activate the robotic hand
    % hands: serialport object
    % outlet: labstreaminglayer outlet
    % y: prediction
    

    
    write(hands, 'c', "char"); % Checks if the hands are activated
    % disp(read(hands, 4, "char"));
    if nargin == 3
        outlet.push_sample(side');
    else
        disp('No outlet provided');
    end
    % left side
    if y == 1
        write(hands, '1', "char");
    % right side
    elseif y == 2
        write(hands, '2', "char");
    % rest -> nothing to do
    else    
        return
    end
end