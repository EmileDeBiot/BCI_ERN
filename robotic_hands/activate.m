function activate(hands)
    % Activate the fingers (servomotors)
    % hands: serialport object
    
    write(hands, 'a', "char");
    disp(readline(hands));
end
