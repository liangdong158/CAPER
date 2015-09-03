%4.4] Plotting Tutorial:
clear
clc
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
%%
%Find directory of Circuit:
mainFile = GUI_openDSS_Locations();
%Declare name of basecase .dss file:
master = 'Master_ckt7.dss';
basecaseFile = strcat(mainFile,master);
DSSText.command = ['Compile "',basecaseFile];
%%
%}
%Compile the circuit
%DSSText.command = 'Compile R:\00_CAPER_SYSTEM\05_OpenDSS_Circuits\Roxboro_Circuit_Opendss\Master.DSS'; 
%DSSText.command = ['Compile "', gridpvPath,'ExampleCircuit\master_Ckt24.dss"'];
%%
%Plotting Circuits:
DSSText.command = 'Set mode=snapshot';
DSSText.command = 'Set controlmode = static';
DSSText.command = 'solve loadmult=0.5';

Lines = getLineInfo_Currents(DSSCircObj);
thermal = zeros(length(Lines),3); %LINE_RATING | MAX sim PHASE CURRENT | %%THERMAL
ansi84 = zeros(length(Lines),1);  %MAX sim PHASE VOLTAGE
jj = 1;
while jj<length(thermal)
    thermal(jj,1) = Lines(jj,1).lineRating;
    jj = jj + 1;
end


%3) Setup a pointer of the active circuit:
DSSCircuit = DSSCircObj.ActiveCircuit;
%5) Obtain Component Structs:
Buses = getBusInfo(DSSCircObj);
Loads = getLoadInfo(DSSCircObj);
%%

% Initiate PV Central station:
DSSText.command = 'new loadshape.PV_Loadshape npts=1 sinterval=60 csvfile="PVloadshape_Central.txt" Pbase=0.10 action=normalize';
DSSText.command = sprintf('new generator.PV bus1=%s phases=3 kv=12.47 kVA=100.00 pf=1.00 enabled=true duty=PV_Loadshape',Buses(3,1).name);
%fprintf(fid,'new generator.PV%s bus1=%s phases=%1.0f kv=%2.2f kw=%2.2f pf=1 duty=PV_Loadshape\n',Transformers(ii).bus1,Transformers(ii).bus1,Transformers(ii).numPhases,Transformers(ii).bus1Voltage/1000,kva(ii)/totalSystemSize*totalPVSize);
% Set it as the active element and view its bus information

%DSSCircuit.SetActiveElement('generator.pv');

%---------------------------------------------
%Iterate PV bus1 location throughout EPRI Circuit

%STEP 1] Find legal buses & save names:
legal_buses = cell(200,1);
ii = 5;
j = 1;
while ii<length(Buses)
    if Buses(ii,1).numPhases == 3 && Buses(ii,1).voltage > 6000
        legal_buses{j,1} = Buses(ii,1).name;
        j = j + 1;
    end
    ii =ii + 1;
end
ii = 5;
PV_size = 100;
fDR_LD = zeros(1,3);
jj = 1;
RESULTS = zeros(200,5);%PV_size | Active PV bus | max P.U. | max %thermal | max %thermal 2
%Bus Loop.
while ii<length(Buses)
    %Skip BUS if not 3-ph & connected to 12.47:
    if Buses(ii,1).numPhases == 3 && Buses(ii,1).voltage > 6000
        %Connect PV to Bus:
        DSSText.command = sprintf('edit generator.PV bus1=%s kVA=%s',Buses(ii,1).name,num2str(PV_size));
        DSSText.command = 'solve';
        
        while PV_size < 5100
            %
            %Run powerflow with new kW(or Bus location):
            DSSText.command = 'Set mode=snapshot';
            DSSText.command = 'Set controlmode = static';
            DSSText.command = 'solve loadmult=0.5';
            
            %{
            %Run simulations every 1-minute and find max/min voltages
            simulationResolution = 60; %in seconds
            simulationSteps = 24*60*7;
            DSSText.Command = sprintf('Set mode=duty number=1  hour=0  h=%i sec=0',simulationResolution);
            DSSText.Command = 'Set Controlmode=TIME';
            %}
            %
            %Obtain Current & P.U. & select maximum of scenerio:
            %   Use this if you want to speed the process up:
            Lines = getLineInfo_Currents(DSSCircObj);
            %   OR THIS if you want to see what is available:
            %Lines = getLineInfo(DSSCircObj);
            fDR_LD(1,1) = Lines(2,1).bus1PowerReal;
            fDR_LD(1,2) = Lines(ii,1).bus1PowerReal;
            kk = 4;
            max_C = zeros(10,2);
            max_V = [0,0];
            
            while kk<length(thermal)
                %Find last Sim's phase vltgs:
                ansi84(kk,1) = max(Lines(kk,1).bus1PhaseVoltagesPU);
                %Find last Sim's line currnts:
                thermal(kk,2) = max(Lines(kk,1).bus1PhaseCurrent);

                thermal(kk,3) = (thermal(kk,2)/thermal(kk,1))*100;
                %Hold if the maximum;
                for SRCH=1:1:10
                    if thermal(kk,3) > max_C(SRCH,1)
                        max_C(SRCH,1) = thermal(kk,3);
                        max_C(SRCH,2) = kk;
                    end
                end
                

                %NOW lets check for Voltage Profile
                if ansi84(kk,1) > max_V(1,1)
                    max_V(1,1) = ansi84(kk,1);
                    max_V(1,2) = kk;
                end

                kk = kk + 1;
            end
            %fprintf('Max %%thermalrating is %3.3f %%, located at:  %s\n',max_C(1,1),Lines(max_C(1,2),1).name);  
            %fprintf('\nMax P.U. voltage is %3.3f, located at:  %s\n',max_V(1,1),Lines(max_V(1,2),1).name);
            fprintf('\t\tSolarGEN located: %s\n\t\tSIZE: %3.1f kW\n',Buses(ii,1).name,PV_size);
            %fprintf('\t\tACTIVE: %3.3f kW\n',fDR_LD(1,2)/1000);
            %fprintf('\nFeeder Real Power = %3.3f\n\n',fDR_LD(1,1)/1000);
            %Save results for this iteration:
            %RESULTS = zeros(200,4);%PV_size | Active PV bus | max P.U. | max %thermal Bus Loop.
            RESULTS(jj,1:5)=[PV_size,fDR_LD(1,2),max_V(1,1),max_C(1,1),max_C(2,1)];
            %Now increment the solar site:
            PV_size = PV_size + 1000; %kW
            jj = jj + 1;
        end
        %Reset size of PV system & move to next bus:
        PV_size = 100;
    end
    ii = ii + 1;
end








%This is to print the feeder
%figure(1);
%plotCircuitLines(DSSCircObj,'Coloring','numPhases','MappingBackground','none');
load DISTANCE.mat

      

