%Post_Process_3
%   Chapter 3 plots of combined results:
%Import Results:
fig = 0;

n=1;
DATA = xlsread('RESULTS_COMPILES.xlsx','01_BELL');
vio(n).SU_2S = DATA(:,1:4);
vio(n).WT_2S = DATA(:,5:8);
vio(n).SU_MN = DATA(:,9:12);
vio(n).WT_MN = DATA(:,13:16);
n = n +1;
DATA = xlsread('RESULTS_COMPILES.xlsx','02_CMNW');
vio(n).SU_2S = DATA(:,1:4);
vio(n).WT_2S = DATA(:,5:8);
vio(n).SU_MN = DATA(:,9:12);
vio(n).WT_MN = DATA(:,13:16);
n = n +1;
DATA = xlsread('RESULTS_COMPILES.xlsx','03_FLAY');
vio(n).SU_2S = DATA(:,1:4);
vio(n).WT_2S = DATA(:,5:8);
vio(n).SU_MN = DATA(:,9:12);
vio(n).WT_MN = DATA(:,13:16);
n = n +1;
DATA = xlsread('RESULTS_COMPILES.xlsx','04_ROX');
vio(n).SU_2S = DATA(:,1:4);
vio(n).WT_2S = DATA(:,5:8);
vio(n).SU_MN = DATA(:,9:12);
vio(n).WT_MN = DATA(:,13:16);
n = n +1;
DATA = xlsread('RESULTS_COMPILES.xlsx','05_HLLY');
vio(n).SU_2S = DATA(:,1:4);
vio(n).WT_2S = DATA(:,5:8);
vio(n).SU_MN = DATA(:,9:12);
vio(n).WT_MN = DATA(:,13:16);
n = n +1;
DATA = xlsread('RESULTS_COMPILES.xlsx','06_ERAL');
vio(n).SU_2S = DATA(:,1:4);
vio(n).WT_2S = DATA(:,5:8);
vio(n).SU_MN = DATA(:,9:12);
vio(n).WT_MN = DATA(:,13:16);

%Plot results:


%-------------------------Per Voltage-------------------------------------
fig = fig + 1;
figure(fig)
n = 1;
m = 1;
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'b.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'b-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'b.','LineWidth',6);
hold on
h(m+1) = plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'b--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'g.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'g-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'g.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'g--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'r.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'r-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'r.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'r--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'c.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'c-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'c.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'c--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'m.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'m-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'m.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'m--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'k.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,2),'k-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'k.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,2),'k--','LineWidth',1);
hold on
%SETTINGS----------
legend([h(1),h(3),h(5),h(7),h(9),h(11)],'Feeder 1','Feeder 2','Feeder 3','Feeder 4','Feeder 5','Feeder 6','Location','NorthWest');
axis([0 10000 0 140]);
ylabel('Percent of Locations with Voltage Violations [%]','FontWeight','bold','FontSize',12);
xlabel('PV Capacity (P_{pv }) [kW]','FontWeight','bold','FontSize',12);
%title(sprintf('Percent of PV Scenerioes with violations at 2 load levels for: %s',feeder_name),'FontWeight','bold');
set(gca,'FontWeight','bold');
grid on
%%
%-------------------------Per Conductor Rating----------------------------
fig = fig + 1;
figure(fig);
n = 1;
m = 1;
VIO = 3;

plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'b.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'b-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'b.','LineWidth',6);
hold on
h(m+1) = plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'b--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'g.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'g-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'g.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'g--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'r.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'r-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'r.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'r--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'c.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'c-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'c.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'c--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'m.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'m-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'m.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'m--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'k.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'k-','LineWidth',2);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'k.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'k--','LineWidth',1);
hold on
%SETTINGS----------
legend([h(1),h(3),h(5),h(7),h(9),h(11)],'Feeder 1','Feeder 2','Feeder 3','Feeder 4','Feeder 5','Feeder 6','Location','NorthWest');
axis([0 10000 0 140]);
ylabel('Percent of Locations with Thermal Violations [%]','FontWeight','bold','FontSize',12);
xlabel('PV Capacity (P_{pv }) [kW]','FontWeight','bold','FontSize',12);
%title(sprintf('Percent of PV Scenerioes with violations at 2 load levels for: %s',feeder_name),'FontWeight','bold');
set(gca,'FontWeight','bold');
grid on
%%
%-------------------------Per Voltage-------------------------------------
fig = fig + 1;
figure(fig)
n = 1;
m = 1;
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'b.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'b-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'b.','LineWidth',6);
hold on
h(m+1) = plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'b--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'g.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'g-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'g.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'g--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'r.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'r-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'r.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'r--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'c.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'c-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'c.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'c--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'m.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'m-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'m.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'m--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'k.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,2),'k-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'k.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,2),'k--','LineWidth',1);
hold on
%SETTINGS----------
legend([h(1),h(3),h(5),h(7),h(9),h(11)],'Feeder 1','Feeder 2','Feeder 3','Feeder 4','Feeder 5','Feeder 6','Location','NorthWest');
axis([0 10000 0 140]);
ylabel('Percent of Locations with Voltage Violations [%]','FontWeight','bold','FontSize',12);
xlabel('PV Capacity (P_{pv }) [kW]','FontWeight','bold','FontSize',12);
%title(sprintf('Percent of PV Scenerioes with violations at 2 load levels for: %s',feeder_name),'FontWeight','bold');
set(gca,'FontWeight','bold');
grid on
%%
%-------------------------Per Conductor Rating----------------------------
fig = fig + 1;
figure(fig);
n = 1;
m = 1;
VIO = 3;

plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'b.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'b-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'b.','LineWidth',6);
hold on
h(m+1) = plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'b--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'g.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'g-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'g.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'g--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'r.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'r-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'r.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'r--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'c.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'c-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'c.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'c--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'m.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'m-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'m.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'m--','LineWidth',1);
hold on

n = n + 1;
m = m + 2;
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'k.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'k-','LineWidth',2);
hold on
plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'k.','LineWidth',6);
hold on
h(m+1)= plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'k--','LineWidth',1);
hold on
%SETTINGS----------
legend([h(1),h(3),h(5),h(7),h(9),h(11)],'Feeder 1','Feeder 2','Feeder 3','Feeder 4','Feeder 5','Feeder 6','Location','NorthWest');
axis([0 10000 0 140]);
ylabel('Percent of Locations with Capacity Violations [%]','FontWeight','bold','FontSize',12);
xlabel('PV Capacity (P_{pv }) [kW]','FontWeight','bold','FontSize',12);
%title(sprintf('Percent of PV Scenerioes with violations at 2 load levels for: %s',feeder_name),'FontWeight','bold');
set(gca,'FontWeight','bold');
grid on
%%
%----------Comparison of Seasonal shift on Min. Hosting Cap---------------
fig = fig + 1;
figure(fig);
n = 1;
m = 1;
VIO = 1;%Voltage first of Feeder #1
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'r.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'r-','LineWidth',3);
hold on
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'r.','LineWidth',6);
hold on
h(m+1) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'r--','LineWidth',1);
hold on
m = m + 2;

plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'b.','LineWidth',6);
hold on
h(m) = plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'b-','LineWidth',3);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'b.','LineWidth',6);
hold on
h(m+1) = plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'b--','LineWidth',1);
hold on
%SETTINGS----------
legend([h(1),h(2),h(3),h(4)],'Summer Mean','Summer -2s','Winter Mean','Winter -2s','Location','NorthWest');
axis([4000 10000 0 100]);
ylabel('Percent of Locations with Voltage Violations [%]','FontWeight','bold','FontSize',12);
xlabel('PV Capacity (P_{pv }) [kW]','FontWeight','bold','FontSize',12);
set(gca,'FontWeight','bold');
grid on
%%
%----------Comparison of Seasonal shift on Min. Hosting Cap---------------
fig = fig + 1;
figure(fig);
n = 1;
m = 1;
VIO = 3;%Current first of Feeder #1
plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'r.','LineWidth',6);
hold on
h(m) = plot(vio(n).SU_MN(:,4),vio(n).SU_MN(:,VIO),'r-','LineWidth',3);
hold on
plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'r.','LineWidth',6);
hold on
h(m+1) = plot(vio(n).SU_2S(:,4),vio(n).SU_2S(:,VIO),'r--','LineWidth',1);
hold on
m = m + 2;

plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'b.','LineWidth',6);
hold on
h(m) = plot(vio(n).WT_MN(:,4),vio(n).WT_MN(:,VIO),'b-','LineWidth',3);
hold on
plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'b.','LineWidth',6);
hold on
h(m+1) = plot(vio(n).WT_2S(:,4),vio(n).WT_2S(:,VIO),'b--','LineWidth',1);
hold on
%SETTINGS----------
legend([h(1),h(2),h(3),h(4)],'Summer Mean','Summer -2s','Winter Mean','Winter -2s','Location','NorthWest');
axis([4000 10000 0 100]);
ylabel('Percent of Locations with Capacity Violations [%]','FontWeight','bold','FontSize',12);
xlabel('PV Capacity (P_{pv }) [kW]','FontWeight','bold','FontSize',12);
set(gca,'FontWeight','bold');
grid on
