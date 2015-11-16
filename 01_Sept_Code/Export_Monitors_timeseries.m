%%
%clear
%clc
%close all
%Lets create the needed monitors:
%feeder_NUM = 1;
if feeder_NUM == 0
    %Bellhaven --
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Bellhaven_Circuit_Opendss';
    addpath(temp_dir)
elseif feeder_NUM == 1
    %Commonwealth --
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss';
    addpath(temp_dir)
    load Lines_Monitor.mat %Lines_Distance
    %For export .txt file --
    filename = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss\TIME_RESULTS';
    
elseif feeder_NUM == 2
    %Flay --
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss';
    addpath(temp_dir)
    addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\Result_Analysis');
    load config_LOADSBASE_FLAY.mat %Loads_Base
    
    load Lines_Monitor.mat %Lines_Distance
    %For export .txt file --
    filename = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\TIME_RESULTS';
    
end

%%
n = length(Lines_Distance(:,1));
k = 26;
j = 1;
COUNT = 1;
%Pull PCC monitors:
    DSSText.Command = sprintf('export mon fdr_%s_Mon_PQ',root1);
    monitorFile = DSSText.Result;
    MyCSV = importdata(monitorFile);
    delete(monitorFile);
    subPowers = MyCSV.data(:,3:2:7);
    subReact = MyCSV.data(:,4:2:8);
    %
    DATA_SAVE(j,1).phaseP = subPowers;
    DATA_SAVE(j,1).phaseQ = subReact;
    j = j + 1;
    
%Now do general pull:

while k <= 90 %n
    numPh = Lines_Distance(k,1).numPhases; 
    if numPh == 3
        for i=1:1:2
            %line = Lines_Distance(k,1).name;
            %Save info in the following fashion:
            %[bus1]  [numPhases] [monitor name] [phaseCurrents] [
            %[2]  
            Monitor{j,1} = Lines_Distance(k,1).numPhases;   
            Monitor{j,2}= Lines_Distance(k,1).bus1Distance;
            B1 = Lines_Distance(k,1).bus1;
            %take off node #'s (.1.2.3):
            bus1=regexprep({B1},'(\.[0-9]+)','');
            Monitor{j,3} = Lines_Distance(k,1).name;
            DATA_SAVE(j,1).Name = Monitor{j,3};
            DATA_SAVE(j,1).Bus1 = B1;
            %Find V,I,P,Q ----
            if i==1
                Monitor{j,3}=strcat(Monitor{j,3},'_Mon_VI');
                DSSText.Command = sprintf('export mon %s',char(Monitor{j,3}));
                monitorFile = DSSText.Result;
                MyCSV = importdata(monitorFile);
                %Find static  ----
                if COUNT == 1
                    Hour = MyCSV.data(:,1); Second = MyCSV.data(:,2);
                    COUNT = COUNT + 1;
                    DATA_SAVE(j,1).Hour = Hour;
                    DATA_SAVE(j,1).Sec = Second;
                end
                delete(monitorFile);
                %subVoltages = MyCSV.data(:,3:2:7);
                subVoltages = MyCSV.data(:,3:1:5);
                if subVoltages(1,1)> 6480 || subVoltages(1,2) > 6480 || subVoltages(1,3) > 6480
                    DATA_SAVE(j,1).Vbase = (12.47e3)/sqrt(3);
                else
                    DATA_SAVE(j,1).Vbase = 0;
                end
                    
                %subCurrents = MyCSV.data(:,11:2:15);
                subCurrents = MyCSV.data(:,6:1:8);
                %
                DATA_SAVE(j,1).phaseV = subVoltages;
                DATA_SAVE(j,1).phaseI = subCurrents;
            elseif i==2
                Monitor{j,3}=strcat(Monitor{j,3},'_Mon_PQ');
                DSSText.Command = sprintf('export mon %s',char(Monitor{j,3}));
                monitorFile = DSSText.Result;
                MyCSV = importdata(monitorFile);
                delete(monitorFile);
                subPowers = MyCSV.data(:,3:2:7);
                subReact = MyCSV.data(:,4:2:8);
                %
                DATA_SAVE(j,1).phaseP = subPowers;
                DATA_SAVE(j,1).phaseQ = subReact;
            end  
        end
        %Add other info:
        %12.47 0.480, 0.208, 0.24, 0.12
        
        DATA_SAVE(j,1).distance = Monitor{j,2};
        
        j = j + 1; 
    end
    k = k + 1;
end
%{
c_j = j;
k=1;
while k<=100%length(Loads_Base)
    %Assign new monitor name:
    Monitor{j,1}=strcat(num2str(k),'_Mon_VI');
    %Export monitor:
    DSSText.Command = sprintf('export mon %s',char(Monitor{j,1}));
    monitorFile = DSSText.Result;
    MyCSV = importdata(monitorFile);
    delete(monitorFile);
    %subVoltages = MyCSV.data(:,3:2:7);
    m = size(MyCSV.data);
    if m(1,2)==8 %3ph
        subVoltages = MyCSV.data(:,3:1:5);
        subCurrents = MyCSV.data(:,6:1:8);
    elseif m(1,2)==6 %2ph
        subVoltages = MyCSV.data(:,3:1:4);
        subCurrents = MyCSV.data(:,5:1:6);
    elseif m(1,2)==4 %1ph
        subVoltages = MyCSV.data(:,3);
        subCurrents = MyCSV.data(:,4);
    end
    %
    DATA_SAVE(j,1).phaseV = subVoltages;
    DATA_SAVE(j,1).phaseI = subCurrents;
    DATA_SAVE(j,1).title = MyCSV.textdata(1,:);
    DATA_SAVE(j,1).loadnum = k;
    
    k = k + 1;
    j = j + 1;
end
%}
%Now lets export LTC tap changes:
DSSText.Command = 'export mon LTC';
monitorFile = DSSText.Result;
MyLTC = importdata(monitorFile);
delete(monitorFile);
%%
%Now lets export LTC voltages:
DSSText.Command = 'export mon subVI';
monitorFile = DSSText.Result;
MySUBV = importdata(monitorFile);
delete(monitorFile);
%%
save(filename,'DATA_SAVE');
%%
%Plot results --
%{
figure(1)
for k=1:1:100%length(Loads_Base)
    if Loads_Base(k,1).nodes == 1
        plot(k,DATA_SAVE(k+c_j-1).phaseV(10,1),'ro');
    elseif Loads_Base(k,1).nodes == 2
        plot(k,DATA_SAVE(k+c_j-1).phaseV(10,1),'go');
    elseif Loads_Base(k,1).nodes == 3
        plot(k,DATA_SAVE(k+c_j-1).phaseV(10,1),'bo');
    end
    hold on
    %k+c_j
end
%}
%%
figure(2)
title('Command vs. actual CHECK');
plot(DATA_SAVE(1).phaseP,'r-')
hold on
plot(LOAD_ACTUAL,'b-')
%%

        