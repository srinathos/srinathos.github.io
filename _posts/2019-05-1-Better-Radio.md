---
layout: post
title: Making radio interesting again
date: 2019-05-1
---

I sometimes feel lucky to have experienced this surge in technology while I grew up -- radio, cassettes, winamp, CDs, and now streaming. Looking back, radio was always fun to listen to, with some adverts peppered in between songs. After I had purchased my first car in 2017, I decided to give the radio a listen again. The advertisements were still there, and I found myself skipping through stations for most of the drive just to hear music. After 15 years, it felt as if nothing had changed, except that there were a lot more ads. What if I could have an program that automatically tunes to a station playing music? 

## Solution

I began to explore methods that have been used and came across a method describing how to use Convolutional Neural Networks (CNNs) to classify audio signals. 
The method uses the spectrograph of the audio sample as the input image to the network and was applied to recognizing speech. 
For our problem, however, we are not dealing with differentiating between voices. 
The goal is just to differentiate between ads and music and CNNs sound overkill for this task. 
How about using a multi-layer perceptron with a set of engineered features?
Upon further exploration, I found the following audio features that could be useful:

- Spectral Slope 
- Audio Spectrum Centroid 
- Audio Spectrum Envelope 
- Audio Spectrum Flatness 
- Mel Frequency Cepstral Coefficients

Of all features, the last two seem interesting. Audio spectrum flatness tells us if a signal is noisy or harmonic. 
Normal talk and advertisements would tend to have varying modulations with very little repetition (except for [jingles](https://producer.musicradiocreative.com/why-do-radio-stations-use-jingles/), but let’s skip them for now), whereas music almost always has repeating components. 

It seems that Mel Frequency Cepstral Coefficients (MFCCs) have been widely used since the 1980s to perform speech recognition. 
The calculation of these coefficients consists of multiple steps that gather inspiration from the different stages of how humans hear. 
[This page](http://practicalcryptography.com/miscellaneous/machine-learning/guide-mel-frequency-cepstral-coefficients-mfccs/) give a comprehensive explanation of the process to those who want to read further. 
The author has also worked on a [Python library](https://github.com/jameslyons/python_speech_features) that calculates MFCCs for an audio file. 

I started planning a quick prototype. 
Given that the MFCC python library is already available, we could use that as the features and train a model! 
Sounds fairly easy. 
However, we need data. 

Almost every machine learning problem faces the issue of no labeled data being available to train a model. 
Most of the time, the data is hard to collect. In our case, the data is hard to collect. 
Fortunately, the data we want is available on the internet on YouTube in the form of music and advertisement playlists. 
To get our features, we download audio samples, process them to get the MFCC and write out to a CSV file along with the respective label.

### Creating the dataset
The first step would be to download the files. 
I used [youtube-dl](https://ytdl-org.github.io/youtube-dl/index.html), a command-line tool that can take in playlist links as command-line arguments. 
The MFCC python library uses scikit to read in audio files and support only the .wav format. 
So I adjust the arguments to youtube-dl to download only the audio and use FFmpeg internally to convert to wav. 
The script can be found [here](https://github.com/srinathos/slightlyBetterRadio/blob/master/src/data/download_dataset.py).

Once the audio files are on disk, I [calculate](https://github.com/srinathos/slightlyBetterRadio/blob/master/src/features/feature_extractor.py) the MFCC for each file and store the values with the corresponding class label into a CSV file. 
Using scikit learn, I then construct an MLP and fit the data to the model. 
The data is split into a ratio of 70 – 30 for training and testing respectively. 

## Results and possible improvements

For an MLP with 100 hidden units (single layer), the model achieves an accuracy of 91.7%. 
Increasing the number layers of 2 bumps up the accuracy to [93.25% with an f1-score of 0.93](https://github.com/srinathos/slightlyBetterRadio/blob/mlp_classifier/reports/mlp_classifier). 
Not bad for a first try!  
Note that this is only using the MFCC for the audio sample and with the default parameters for the MLP and the MFCC library. 
I expect the performance of the model to improve if the following are explored:
- Increasing the sampling window for the MFCC library. The default is 25ms; perhaps increasing it to 40-50ms would capture global context to differentiate better between advertisements and music.
- Optimizing hyperparams. Using a scikit-learn’s grid search would greatly help here.
- Using more features. I suspect the audio spectrum flatness would help improve the model. 
- I’ve seen SVMs used for audio classification. Since this is a relatively general classification problem compared to speech recognition, it might yeild a better result. 

For those who would like to pursue this further, you can find all the related code on my [Github repository](https://github.com/srinathos/slightlyBetterRadio). 
The repository readme has more information, but feel free to contact me if you have any questions!
