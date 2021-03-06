
c = 340;
fs = 44e3;
dBmin = 50;

%Choose scanning angles
thetaScanningAngles = -60:0.1:60;
phiScanningAngles = 0;

%Set parameters of incoming signal(s)
f0 = 2e3;
thetaArrivalAngles = [-10 5 30];
phiArrivalAngles = [0 0 0];
thetaSteeringAngle = -10;
phiSteeringAngle = 0;
amplitudes = [0 0 0];

%Load array
load ../data/arrays/AMD128
%w = hiResWeights;

%Create signal hitting the array
inputSignal = createSignal(xPos, yPos, zPos, f0, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);

%Get MV weighting vector
w_MV = weightingVectorMinimumVariance(xPos, yPos, zPos, inputSignal, f0, c, thetaSteeringAngle, phiSteeringAngle);

%Calculate beampattern
W_MV = arrayFactor(xPos, yPos, zPos, w_MV, f0, c, thetaScanningAngles, phiScanningAngles);
W_DAS = arrayFactor(xPos, yPos, zPos, w, f0, c, thetaScanningAngles, phiScanningAngles, thetaSteeringAngle);
W_MV = 20*log10(W_MV);
W_DAS = 20*log10(W_DAS);

% Plot the beampattern at specific scanning direction
figure(1);clf
subplot(211)
plot(thetaScanningAngles,W_DAS);
ylabel('Attenuation (dB)')


for j=1:numel(thetaArrivalAngles)
    line([thetaArrivalAngles(j) thetaArrivalAngles(j)],[-dBmin 0],'LineWidth',0.1,'Color',[0.8500 0.3250 0.0980],'LineStyle','--');
end

axis([thetaScanningAngles(1) thetaScanningAngles(end) -dBmin 0])

set(gca,'YTick',[-50 -40 -30 -20 -10 0])
set(gca,'XTick',[-90 -60 -30 -10 5 30 60 90])

title('Beampattern delay-and-sum','fontweight','normal')


subplot(212)
plot(thetaScanningAngles,W_MV);
xlabel('Angle (deg)')
ylabel('Attenuation (dB)')

for j=1:numel(thetaArrivalAngles)
    line([thetaArrivalAngles(j) thetaArrivalAngles(j)],[-dBmin 0],'LineWidth',0.1,'Color',[0.8500 0.3250 0.0980],'LineStyle','--');
end

axis([thetaScanningAngles(1) thetaScanningAngles(end) -dBmin 0])

set(gca,'YTick',[-50 -40 -30 -20 -10 0])
set(gca,'XTick',[-90 -60 -30 -10 5 30 60 90])


title('Beampattern minimum variance','fontweight','normal')

%% Calculate steered response
inputSignal = createSignal(xPos, yPos, zPos, f0, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);
e = steeringVector(xPos, yPos, zPos, f0, c, thetaScanningAngles, phiScanningAngles);
R = crossSpectralMatrix(inputSignal);

dBmin = 30;
S_DAS = steeredResponseDelayAndSum(R, e, w);
S_DAS = abs(S_DAS)/max(abs(S_DAS));
S_MV = steeredResponseMinimumVariance(R, e);
S_MV = abs(S_MV)/max(abs(S_MV));

%Plot steered response
figure(2);clf;hold on
plotDAS = plot(thetaScanningAngles,10*log10(abs(S_DAS)));
plotMV = plot(thetaScanningAngles,10*log10(abs(S_MV)));
xlabel('Angle (deg)')
ylabel('Attenuation (dB)')
%grid on
axis([thetaScanningAngles(1) thetaScanningAngles(end) -dBmin 0])
yL = get(gca,'YLim');
for j=1:numel(thetaArrivalAngles)
    indx = find(thetaScanningAngles >= thetaArrivalAngles(j),1);
    line([thetaScanningAngles(indx) thetaScanningAngles(indx)],yL,'LineWidth',1,'Color',[1 1 1]*0.5,'LineStyle','--');
end
title('Steered response','FontWeight','Normal')
legend('Delay-and-sum','Minimum variance','location','northwest')
box on
set(gca,'XTick',[-90 -60 -30 -10 5 30 60 90])

%% Calculate and plot the response for DAS, MV, MUSIC

dBmin = 60;
S_DAS = steeredResponseDelayAndSum(R, e, w);
S_DAS = abs(S_DAS)/max(abs(S_DAS));
S_MV = steeredResponseMinimumVariance(R, e);
S_MV = abs(S_MV)/max(abs(S_MV));
[S_MUSIC, V, Vn] = steeredResponseMusic(R, e, 3);
S_MUSIC = abs(S_MUSIC)/max(abs(S_MUSIC));

%Plot steered response
figure(2);clf;hold on
plotDAS = plot(thetaScanningAngles,10*log10(abs(S_DAS)));
plotMV = plot(thetaScanningAngles,10*log10(abs(S_MV)));
plotMUSIC = plot(thetaScanningAngles,10*log10(abs(S_MUSIC)));
xlabel('Angle (deg)')
ylabel('Attenuation (dB)')
%grid on
axis([thetaScanningAngles(1) thetaScanningAngles(end) -dBmin 0])
yL = get(gca,'YLim');
for j=1:numel(thetaArrivalAngles)
    indx = find(thetaScanningAngles >= thetaArrivalAngles(j),1);
    line([thetaScanningAngles(indx) thetaScanningAngles(indx)],yL,'LineWidth',1,'Color',[1 1 1]*0.5,'LineStyle','--');
end
title('Steered response','FontWeight','Normal')
legend('Delay-and-sum','Minimum variance','MUSIC','location','northwest')
box on


