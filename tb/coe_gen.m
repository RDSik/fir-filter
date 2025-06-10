clc
clear

COE_WIDTH    = 16;
COE_NAME     = 'fir.coe';
COE_MEM_NAME = 'fir_coe.mem';

Fs          = 250e6;
Fpass       = 55e6;
Fstop       = 62.5e6;
Astop       = 50;
PASS_RIPPLE = 0.5;
DESIGN      = 'equiripple';

SIN_LUT_NAME = 'sin_lut.mem';
PHASE_WIDTH  = 16;
SAMPLE_NUM   = 2^PHASE_WIDTH;
SAMPLE_WIDTH = 16;

%% Filter coefficients generation
lpFilt = designfilt('lowpassfir', 'PassbandFrequency', Fpass, 'StopbandFrequency', Fstop, ... 
         'PassbandRipple', PASS_RIPPLE, 'StopbandAttenuation', Astop, 'SampleRate', Fs, 'DesignMethod', DESIGN);
filter_coe = round(lpFilt.Coefficients*(2^(COE_WIDTH-1)-1));
fvtool(filter_coe, 'Fs', Fs);

hq = dfilt.dffir(filter_coe); 
set(hq,'arithmetic','fixed');
set(hq, 'coeffwordlength', COE_WIDTH); 
coewrite(hq, 16, COE_NAME);


%% Coe mem generation
coe_fid = fopen(COE_MEM_NAME, 'w');
if coe_fid == -1
    error('File is not opened');
end

for i = 1:length(filter_coe)
    fprintf(coe_fid, '%s\n', dec2hex(filter_coe(i), COE_WIDTH/4));
end

%% Sin lut generation
sin_fid = fopen(SIN_LUT_NAME, 'w');
if sin_fid == -1
    error('File is not opened');
end

sin_lut = zeros(SAMPLE_NUM, 1);

for i = 1:SAMPLE_NUM
    sin_lut(i) = round((2^(SAMPLE_WIDTH-1)-1) * (1 + sin(2*pi*i/SAMPLE_NUM)));
    fprintf(sin_fid, '%s\n', dec2hex(sin_lut(i), SAMPLE_WIDTH/4));
end

fclose(sin_fid);
fclose(coe_fid);
