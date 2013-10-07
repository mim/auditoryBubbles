function playCalibrationFile

fileName = '../calOneSpeaker15bps30db.wav';
[x fs] = wavread(fileName);
sound(x, fs);
