fs=10000 %% sampling frequency
f1=500;  %% first sinewave freq (in band)
f2=4500; %% second sinnewave freq (out band)

N=2; %% filter order
nb=9; %% number of bits

T=1/500; %% maximum period
tt=0:1/fs:10*T; %% time samples

x1=sin(2*pi*f1*tt); %% first sinewave
x2=sin(2*pi*f2*tt); %% second sinewave

x=(x1+x2)/2; %% input signal

[bi, ai, bq, aq]=myiir_design(N, nb) %% filter design

y=filter(bq, aq, x); %% apply filter

%% plots
figure (2)
plot(tt,x1,'--d');
hold on
plot(tt,x2,'r--s');
plot(tt,x, 'g--+');
legend('First sinewave', 'Second sinewave', 'Input signal', 'interpreter','latex', 'fontsize', 12)

figure (3)
plot(tt,x, 'g--+');
hold on
plot(tt, y, 'c--o');
legend('Input of the filter', 'Output of the filter', 'interpreter','latex', 'fontsize', 12)

%% quantize input and output
xq=floor(x*2^(nb-1));
idx=find(xq==2^(nb-1));
xq(idx)=2^(nb-1)-1;

yq=floor(y*2^(nb-1));
idy=find(yq==2^(nb-1));
yq(idy)=2^(nb-1)-1;

%% save input and output
fp=fopen('samples.txt','w');
fprintf(fp,'%d\n', xq);
fclose(fp);

fp=fopen('resultsm.txt', 'w');
fprintf(fp, '%d\n', yq);
fclose(fp);

%% evaluate the THD of the C implementation
fp=fopen('../C/results_c.txt', 'r');
yc = fscanf(fp, '%d\n');
yc = yc';
fclose(fp);

figure(4);
thd(yc, fs);
title('THD $-37.31 dB$','interpreter','latex', 'fontsize', 20)
xlabel('Frequency (kHz)','interpreter','latex', 'fontsize', 12)
ylabel('Power (dB)','interpreter','latex', 'fontsize', 12)
legend('Fundamental', 'Harmonics', 'DC and Noise (excluded)', 'interpreter','latex', 'fontsize', 12)