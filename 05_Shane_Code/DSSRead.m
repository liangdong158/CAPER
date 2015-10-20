%function [NODE,SECTION,DER,DSCS] = DSSRead()
% Function to read Data from OpenDSS

%{

addpath('C:\Users\Shane\Documents\GitHub\CAPER\03_OpenDSS_Circuits');
DER_Planning_GUI_1
gui_response = STRING_0;

ckt_direct      = gui_response{1,1}; %entire directory string of where the cktfile is locatted
feeder_NUM      = gui_response{1,2};
scenerio_NUM    = gui_response{1,3}; %1=VREG-top ; 2=VREG-bot ; 3=steadystate ; 4=RR_up ; 5=RR_down
base_path       = gui_response{1,4};  %github directory based on user's selected comp. choice;
cat_choice      = gui_response{1,5}; %DEC DEP EPRI;
PV_Site         = gui_response{1,7}; %( 1 - 7) site#s;
PV_Site_path    = gui_response{1,8}; %directory to PV kW file:
timeseries_span = gui_response{1,9}; %(1) day ; (1) week ; (1) year ; etc.

%path = strcat(base_path,'\01_Sept_Code');
%addpath(path);
path = strcat(base_path,'\04_DSCADA');
addpath(path);

%}

% Find the CAPER folder location (CAPER folder must be in MATLAB path
rootlocation = textread('pathdef.m','%c')';
rootlocation = regexp(rootlocation,'C:.*?CAPER\\','match');
len = cellfun(@(x) numel(x), rootlocation);
rootlocation = rootlocation(len==min(len));
rootlocation = [cell2mat(rootlocation(1)),'03_OpenDSS_Circuits\'];

filename = 0;
while ~filename
    [filename,filelocation] = uigetfile({'*.*','All Files'},'Select DSS Master File',rootlocation);
end

% Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

% Compile and Solve the Circuit
DSSText.command = ['Compile ',[filelocation,filename]];
DSSText.command = 'solve';
DSSCircuit = DSSCircObj.ActiveCircuit;

% Get Bus and Load Names
NODE.ID = DSSCircuit.AllBusNames;
Loads = DSSCircuit.Loads.AllNames;
%Lines_Base = getLineInfo(DSSCircObj);
%Buses_Base = getBusInfo(DSSCircObj);
Loads_Base = getLoadInfo(DSSCircObj);

% Get Bus Info
N = length(NODE.ID);
for i = 1:N
    % Find Loads Associated with Node
    for phase = 1:3
        loadID = ['Load.',NODE.ID{i},'_',int2str(phase)];
        % Check for Load
        if max(strcmp(loadID,Loads))
            DSSCircuit.SetActiveElement(loadID);
            % DEMAND: Nx6 Matrix
            % phase A | phase B | phase C
            %   p  q  |   p  q  |   p  q
            NODE.DEMAND(i,2*phase-1) = 1;
        end
    end
        
    % Set Active Node
    DSSCircuit.SetActiveBus(NODE.ID{i});
    
    
    priority    = cell2mat(raw1(:,4));
    NODE.WEIGHT = 10.^priority;
    NODE.PARENT = raw1(:,7:12);
end

% Get Line Names
DSSCircuit.Lines.AllNames


NODE.ID     = raw1(:,1);
NODE.DEMAND = cell2mat(raw1(:,2:3));
priority    = cell2mat(raw1(:,4));
NODE.WEIGHT = 10.^priority;
NODE.PARENT = raw1(:,7:12);

[capacity_kva,DER.ID,~] = xlsread(filename,'Nodes',['P2:Q',num2str(n+1)]);
% Assuming a minimum power factor of 0.95
pf = 0.95;
DER.CAPACITY = [pf*capacity_kva,(1-pf^2)*capacity_kva];

[~,~,raw2] = xlsread(filename,'Sections',['B2:P',num2str(n)]);

SECTION.ID          = raw2(:,1:2);
SECTION.IMPEDANCE   = cell2mat(raw2(:,3:4));
SECTION.CAPACITY    = cell2mat(raw2(:,5));
SECTION.CHILD       = raw2(:,10:15);

% Generate DSCS
PARAM.SC = find(~cell2mat(raw2(:,6)));   % SECTION CONSTRAINED CLOSED (no switch)
PARAM.SO = [3;7;14];                     % SECTION CONSTRAINED OPEN (faulted sections)
PARAM.NC = [];                           % LOAD CONSTRAINED CLOSED
PARAM.NO = [];                           % LOAD CONSTRAINED OPEN

% Check intersection of SO & SC (remove duplicates from SC)
dup = intersect(PARAM.SC,PARAM.SO);
for i = 1:length(dup)
    PARAM.SC = PARAM.SC(PARAM.SC~=dup(i));
end

% Check intersection of SO & SC (remove duplicates from SC)
dup = intersect(PARAM.SC,PARAM.SO);
for i = 1:length(dup)
    PARAM.SC = PARAM.SC(PARAM.SC~=dup(i));
end

% Other Parameters
PARAM.VOLTAGE = [12.47,0.05];   % [Ref Voltage (kV), Tolerance]

