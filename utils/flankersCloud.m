function trials = flankersCloud(rCongruent, rIncongruent, rRandom, rNeutral, nTrials)
    nCongruent = round(rCongruent*nTrials);
    nIncongruent = round(rIncongruent*nTrials);
    nRandom = round(rRandom*nTrials);
    nNeutral = round(rNeutral*nTrials);

    trials = [ones(1,nCongruent) 2*ones(1,nIncongruent) 3*ones(1,nRandom) 4*ones(1,nNeutral)];
    trials = trials(randperm(nTrials));