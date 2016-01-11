function playCalibrationFile

fileName = '../calOneSpeaker15bps30db.wav';
[x fs] = audioread(fileName);
sound(x, fs);
