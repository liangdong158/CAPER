%plot functions only for feedback of how Energy Controller is doing...
% 
clear
clc
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\05_BESS');
load M_MOCKS.mat
load M_MOCKS_SC.mat
M_PVSITE_SC_1 = M_MOCKS_SC;
%
for i=1:1:12
    M_PVSITE(i).GHI = M_MOCKS(i).GHI;
    M_PVSITE(i).kW = M_MOCKS(i).kW;
end
load P_Mult_60s_Flay.mat

DAY = 3;
MNTH = 2;
%{
DAY = 1;
MNTH = 1;
%}
DOY=calc_DOY(MNTH,DAY);


%-----------------
%Variables:
CSI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
BncI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
GHI=M_PVSITE(MNTH).kW(time2int(DAY,0,0):time2int(DAY,23,59),1)/4600; %PU


%Constants:
CSI_TH=0.1;
BESS.Prated=1000;   %kWh
BESS.Crated=12121; %4000kWh
BESS.DoD_max=0.33;
BESS.Eff_DR=.967;
BESS.Eff_CR=.93;
C_r=BESS.Crated;
DoD_max=BESS.DoD_max;

PV_pmpp=3000; %kW
%%
for n=1:1:3
    P_DAY1=CAP_OPS_STEP2(DOY).kW(:,1)+CAP_OPS_STEP2(DOY).kW(:,2)+CAP_OPS_STEP2(DOY).kW(:,3);
    P_DAY2=CAP_OPS_STEP2(DOY+1).kW(:,1)+CAP_OPS_STEP2(DOY+1).kW(:,2)+CAP_OPS_STEP2(DOY+1).kW(:,3);
    P_PV=M_PVSITE(MNTH).kW(time2int(DAY,0,0):time2int(DAY,23,59),1)/4600; %PU
    
    %MEC-F3:
    [t_max,DAY_NUM,P_max,E_kWh]=Peak_Estimator_MSTR(P_DAY1,P_DAY2);
    DoD_tar = DoD_tar_est( M_PVSITE_SC_1(DOY+1,:),BESS,PV_pmpp);
    fprintf('>>>DoD_tar for NEXT DAY=%0.3f\n',DoD_tar);
    %MEC-F3:
    SOC_n=1; %  100%
    [peak,P_DR_ON,T_DR_ON,T_DR_OFF] = DR_INT(t_max,P_DAY1,DoD_tar,BESS,SOC_n);
    fprintf('Battery will begin Discharging...\n');
    fprintf('T_ON=%0.3f \t T_OFF=%0.3f\n',peak(n).t_A,peak(n).t_B);
    fprintf('Target kW=%0.3f \n',P_DR_ON);
    
    if DAY_NUM == 2
        %Do not carryon with DR:
        T_DR_ON = 0;
    end
    DAY_SAVE(n).P_DAY1 = P_DAY1;
    DAY_SAVE(n).peak = peak;
    DAY_SAVE(n).DoD_tar = DoD_tar;
    DAY_SAVE(n).T_DR_ON = T_DR_ON;
    DAY_SAVE(n).P_DR_ON = P_DR_ON;
    DAY_SAVE(n).t_max = t_max;
    DAY_SAVE(n).P_PV = P_PV;
    DOY = DOY + 1;
    DAY = DAY + 1;
end

%%
close all
fig = 0;

%{
fig = fig + 1;
figure(fig);
subplot(1,3,1);

%t=[T_ON,t_1,t_2,t_3,t_4,t_5];
tt=[1/3600:1/3600:24]';
figure(1);
plot(tt,-1*CR_ref,'b-')
axis([0 24 -1000 0]);

hold on
%{
plot(t,1*DR,'r-')
%}
grid on
xlabel('Hour of Day');
ylabel('Charge/Discharge Rate (kW)');

subplot(1,3,2);
plot(P_DAY1_bot(:,2)/60,P_BESS,'r-','LineWidth',3)
subplot(1,3,3);

plot(tt,SOC_ref,'b-','LineWidth',2)
axis([0 24 0.65 1]);
%}
%%
% Load Forecasting (kW) & Energy profile:
fig = fig + 1;
figure(fig);
%subplot(1,3,1);
X=1:1:1440;
if DAY_NUM == 1
    plot(X,P_DAY1,'b-','LineWidth',3);
    hold on
    plot(t_max,P_max(1,1),'bo','LineWidth',3);
    hold on
    P_DAY1_bot=[peak(n).P_DAY1_bot];
    %Show DR period:
    plot(P_DAY1_bot(:,2),P_DAY1_bot(:,1),'c-','LineWidth',1.5);
    hold on
    plot([peak(n).t_A],P_DAY1([peak(n).t_A],1),'c.','LineWidth',6);
    hold on
    plot([peak(n).t_B],P_DAY1([peak(n).t_B],1),'c.','LineWidth',6);
    hold on
elseif DAY_NUM == 2
    %X=X+1440;
    plot(X,P_DAY2,'r-');
    hold on
    %plot(P_max(2,2)+1440,P_max(1,2),'ro','LineWidth',3);
    hold on
    %Settings:
    xlabel('Minute of Day');
    ylabel('3PH KW');
    %axis([1 2880 900 2500])
end

fig = fig + 1;
figure(fig);
%----- DAY 1 -----
plot(X,[DAY_SAVE(1).P_DAY1],'b-','LineWidth',2.5);
hold on
%   Show DR shaving kW:
n=1;
m=length(DAY_SAVE(n).peak);

P_DAY1_bot=[DAY_SAVE(n).peak(m).P_DAY1_bot];
mm =length(P_DAY1_bot);
t_OFF = P_DAY1_bot(mm,2);
P_DAY1_bot(mm+1,2) = t_OFF + 1;
P_DAY1_bot(mm+1,1) = DAY_SAVE(1).P_DAY1(t_OFF+1);


plot(P_DAY1_bot(:,2),P_DAY1_bot(:,1),'r-','LineWidth',2.5);
hold on
plot([DAY_SAVE(n).peak(m).t_A],DAY_SAVE(n).P_DAY1([DAY_SAVE(n).peak(m).t_A],1),'r.','LineWidth',6);
%hold on
%plot([peak(n).t_B],P_DAY1([peak(n).t_B],1),'c.','LineWidth',6);
hold on
plot([1440 1440],[0 3500],'k-','LineWidth',3);
hold on
plot(X,[DAY_SAVE(n).P_PV]*3000,'g-','LineWidth',1.5);
hold on
text(1500,1300,sprintf('DoD Target=%0.3f %%',DAY_SAVE(n).DoD_tar*100),'FontWeight','bold','FontSize',12,'Color','r');

%----- DAY 2 -----
n = n + 1;
m=length(DAY_SAVE(n).peak);
hold on
plot(X+1440,[DAY_SAVE(n).P_DAY1],'b-','LineWidth',2.5);
hold on
plot(X+1440,[DAY_SAVE(n).P_PV]*3000,'g-','LineWidth',1.5);
hold on
%P_DAY1_bot=[DAY_SAVE(2).peak(length(DAY_SAVE(2).peak)).P_DAY1_bot];
%plot(P_DAY1_bot(:,2)+1440,P_DAY1_bot(:,1),'c-','LineWidth',1.5);
%hold on
%----- DAY 3 -----
n = n + 1;
m=length(DAY_SAVE(n).peak);
plot([2880 2880],[0 3500],'k-','LineWidth',3);
hold on
h(1)=plot(X+1440*2,[DAY_SAVE(3).P_DAY1],'b-','LineWidth',2.5);
hold on
h(2)=plot(X+1440*2,[DAY_SAVE(n).P_PV]*3000,'g-','LineWidth',1.5);
hold on
P_DAY1_bot=[DAY_SAVE(3).peak(length(DAY_SAVE(3).peak)).P_DAY1_bot];
mm =length(P_DAY1_bot);
t_OFF = P_DAY1_bot(mm,2);
P_DAY1_bot(mm+1,2) = t_OFF + 1;
P_DAY1_bot(mm+1,1) = DAY_SAVE(3).P_DAY1(t_OFF+1);
h(3)=plot(P_DAY1_bot(:,2)+1440*2,P_DAY1_bot(:,1),'r-','LineWidth',2.5);
hold on
plot([DAY_SAVE(n).peak(m).t_A]+1440*2,DAY_SAVE(n).P_DAY1([DAY_SAVE(n).peak(m).t_A],1),'r.','LineWidth',6);
hold on
text(2900,1300,sprintf('DoD Target=%0.3f %%',DAY_SAVE(n).DoD_tar*100),'FontWeight','bold','FontSize',12,'Color','r');
%   Settings -------<<<<<<<<<<<<<<<<<<<
set(gca,'XTick',[0:240:1440*3]);
axis([0 3*1440 0 3500])
xlabel('Minute of Day','FontWeight','bold','FontSize',12);
ylabel('Three Phase Real Power ( P ) [ kW ]','FontWeight','bold','FontSize',12);
legend([h(1) h(2) h(3)],'Base Load','3MW DER-PV Generation','Load with BESS in Peak Shaving Mode');
set(gca,'FontWeight','bold','FontSize',14);
grid on
%{
subplot(1,3,2);
X=1:1:24;
bar(X,E_kWh(:,1),'b')
X=X+24;
hold on
bar(X,E_kWh(:,2),'r')
xlabel('Hour of Day');
ylabel('Energy (kWh)');
axis([1 49 900 2500]);
title('Next Day load');
%}

%subplot(1,3,3);

%{
X=1:1:1440;
%X=X/60;
plot(X,CSI,'b-')
hold on
T_ON=t_CR(1,1);
T_OFF=t_CR(1,7);
%plot(T_ON,CSI(T_ON*60),'bo','LineWidth',2.5);
%hold on
%plot(T_OFF,CSI(T_OFF*60),'bo','LineWidth',2.5);
%hold on
plot(X,BncI,'r-');
hold on
plot(X,GHI,'c-');
hold on
t3=tt*60;
plot(t3,CR_ref,'g-')
%}