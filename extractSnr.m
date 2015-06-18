function status = extractSnr(inDir, outDir, overwrite)

% Use snrseg from Mike Brooke's voicebox toolbox
% http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/doc/voicebox/snrseg.html

if ~exist('overwrite', 'var') || isempty(overwrite), overwrite = 0; end

nJobs = 1;
part = [1 1];
ignoreErrors = 0;

wavFiles = findFiles(inDir, '.*.wav');

noisyToCleanFn = findNoisyToCleanFn(fullfile(inDir, wavFiles{1}));

effn = @(ip,op,f) ef_snr(ip, op, noisyToCleanFn);
status = extractFeatures(inDir, outDir, 'mat', wavFiles, ...
    effn, nJobs, part, ignoreErrors, overwrite);


function ef_snr(ip, op, noisyToCleanFn)
cleanWavFile = noisyToCleanFn(ip);

[mix fsm] = wavread(ip);
[cln fsc] = wavread(cleanWavFile);
assert(fsm == fsc);

opts = 'Vz';
[segmentalSnr globalSnr] = snrseg(mix, cln, fsm, opts);
[segmentalSnrA globalSnrA] = snrseg(mix, cln, fsm, [opts 'a']);
save(op, 'segmentalSnr', 'globalSnr', 'segmentalSnrA', 'globalSnrA')
