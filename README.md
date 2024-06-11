# BCI_ERN

Measure Error-related negativity with an EEG-based BCI.

## Setup

Run set_env to setup your environment, check your dependencies and test the hands.

## Training

Run run_training to start the training when the EEG setup is done and verified with and external software (the biosemi console is harder to use and has less features).

### Usage

1. Experiment parameters

A window will open from which you can run all the necessary functions for training.

![Experiment parameter](data/README/experience_parameters.png?raw=true)

Fill the participant ID and parametrize your training session. Then click on training session to launch.

2. Training session

A new window will pop up enabling you to connect BioSemi.

![BioSemi connection](data/README/biosemi_connection.png?raw=true)

A LabRecorder window will then appear. Choose both the BioSemi and the Marker stream and click Start to record.

![Recording EEG](data/README/lab_recorder.png?raw=true)

Only then will the training paradigm start.

3. Training model

If you have created all the data files you want or if you want to make the hand move during the training (will use more computing time because there is no way to fine tune a model with a new piece of data in the toolbox used), you can click on training model. This function will concatenate all data files and train a signal processing classification model.

4. Get Online Accuracy

When a model is trained, you can test its accuracy on a given data file.

5. Feedback session

You can use this button to let the participant use freely the robotic hands.

## Experiments

Run flankers_real_hand to start the real hand experimentation. Check the parameters at the beginning of the file.

Run flankers_bci to start the real hand experimentation. Check the parameters at the beginning of the file.