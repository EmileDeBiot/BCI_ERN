function  is_success = bandits()
    % Computes the probabilities for a bandit experience
    % The bandit has 2 arms, each with a different probability of success that change over time
    % is_success is a 2xT matrix where is_success(i, t) is 1 if arm i was successful at time t, 0 otherwise

    % Number of arms
    n = 2;

    % Number of trials
    T = 10;

    % Probability of success for each arm follows a beta distribution
    beta_1_params = [6, 14];
    beta_2_params = [14, 6];

    % Generate a T long sample for each arm
    sample = [betarnd(beta_1_params(1), beta_1_params(2), T, 1), betarnd(beta_2_params(1), beta_2_params(2), T, 1)];

    is_success = zeros(n, T);
    for t = 1:T
        r_1 = rand();
        r_2 = rand();
        if r_1 < sample(t, 1)
            is_success(1, t) = 1;
        else
            is_success(1, t) = 0;
        end
        if r_2 < sample(t, 2)
            is_success(2, t) = 1;
        else
            is_success(2, t) = 0;
        end
    end
    
end