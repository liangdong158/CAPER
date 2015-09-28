%Data from DEP_CAPER_FEEDER_LOADS IN THE 04_DSCADA FOLDER

clear
clc
addpath('C:\Users\Brian\Documents\GitHub\CAPER\04_DSCADA')
addpath('C:\Users\Brian\Documents\GitHub\CAPER\04_DSCADA\Feeder_Data')


load('ROX.mat');


%{
%Import data from Excel file
[RidgeRd, ~, ~] = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'RidgeRd');


% Organize into structs
ROX.Voltage.A = RidgeRd(:, 6);
ROX.Voltage.B = RidgeRd(:, 8);
ROX.Voltage.C = RidgeRd(:, 10);
ROX.Amp.A = RidgeRd(:, 7);
ROX.Amp.B = RidgeRd(:, 9);
ROX.Amp.C = RidgeRd(:, 11);
ROX.kW.A = RidgeRd (:, 13);
ROX.kW.B = RidgeRd (:, 15);
ROX.kW.C = RidgeRd (:, 17);
ROX.kVAR.A = RidgeRd (:, 14);
ROX.kVAR.B = RidgeRd (:, 16);
ROX.kVAR.C = RidgeRd (:, 18);

ROX.PI_time = RidgeRd(:,3);
%}
n = length(ROX.Voltage.A);

%%

%NAME = cell(9,1);
NAME = ({'Voltage.A'; 'Voltage.B'; 'Voltage.C'; 'Amp.A'; 'Amp.B';...
        'Amp.C'; 'kW.A'; 'kW.B'; 'kW.C'; 'kVAR.A'; 'kVAR.B'; 'kVAR.C'});

months = [31,28,31,30,31,30,31,31,30,31,30,31,31,28,31];

ref = zeros(n,5);
Y = 2014;
M = 1;
D = 1;
H = 0;
MIN = 0;
tic
% loop runs through entire set of data
for i = 1:1:n
    ref(i,1) = M;       % updates to reference matrix
    ref(i,2) = D;
    ref(i,3) = H;
    ref(i,4) = MIN;
    ref(i,5) = datenum(Y,M,D,H,MIN,0);
   MIN=MIN+15;          % increment minute for every 15
   
   if MIN ==60
       MIN = 0;
       H = H + 1;           % increment hour every 60 mins
       if H == 24
           H = 0;
           D = D + 1;       % increment day every 24 hours
           if D > months(M);
               D =1 ;
               M = M + 1;   % increment month 
           end
       end
   end
end
toc
%FV = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'feltonsville');
%WilmSt = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'WilmingtonSt');
%ROX.PI_time
%%
%T.Date = datetime(ROX.PI_time,'ConvertFrom','excel');

DateTime = sum(ROX.PI_time,2);
diff = zeros(n,1);
str = datestr(DateTime+datenum('30-Dec-1899'));
for i=1:1:length(ROX.PI_time);
    ROX.excel_time{i,1} = cellstr(str(i,1:20));
    ROX.NUM_time(i,1) = datenum(ROX.excel_time{i,1});
    ROX.ref_time{i,1} = datestr(ref(i,5));
    if ROX.NUM_time(i,1) ~= ref(i,5)
        diff(i,1) = ROX.NUM_time(i,1) - ref(i,5);
    end
end
%%
%Preprocess of Filtering out Data Errors:

HOLD = zeros(2,10); %A cache of troubled datapoints
i = 1;
j = 1;
k = 1;
POS = 1;
struct = 1;
E_hold = 0;
E_count = 0;
Errors = zeros(3,2); 

while struct < length(NAME)+1
    if struct == 1
        data = ROX.Voltage.A(:,1);
    elseif struct == 2
        data = ROX.Voltage.B(:,1);
    elseif struct == 3
        data = ROX.Voltage.C(:,1);
    elseif struct == 4
        data = ROX.Amp.A(:,1);
    elseif struct == 5
        data = ROX.Amp.B(:,1);
    elseif struct == 6
        data = ROX.Amp.C(:,1);
    elseif struct == 7
        data = ROX.kW.A(:,1);
    elseif struct == 8
        data = ROX.kW.B(:,1);
    elseif struct == 9
        data = ROX.kW.C(:,1);
    elseif struct == 10
        data = ROX.kVAR.A(:,1);
    elseif struct == 11
        data = ROX.kVAR.B(:,1);
    elseif struct == 12
        data = ROX.kVAR.C(:,1);
    end
    while i < n+1
       
        if isnan(data) == 1
            if i ~= 1
                HOLD(1,j+1) = j;
                if j ==1
                    HOLD(2,j) = data(i-1,POS); %grab last real value.
                    BEGIN = HOLD(2,j);
                end
                j = j + 1;
            end    
        %Change  to actual reading.
        elseif data(i,POS) < -20 && struct < 10
            HOLD(1,j+1) = j;
            if j == 1
                HOLD(2,j) = data(i-1,POS); %grab last real value.
                BEGIN = HOLD(2,j);
            end
            j = j + 1;
        elseif data(i,POS) > 3e5
            HOLD(1,j+1) = j;
            if j == 1
                HOLD(2,j) = data(i-1,POS); %grab last real value.
                BEGIN = HOLD(2,j);
            end
            j = j + 1;
        %A string of errors was discovred.
        elseif j ~= 1 && data(i,1) >= -20
            %ERROR String ENDED!
            HOLD(2,j+1) = data(i,POS); %grabs most recent real value.
            END = HOLD(2,j+1);
            NUM = HOLD(1,j);

            DIFF = (END-BEGIN)/(NUM+1);

            %Estimate & Replace Irradiance measurements:
            while k < NUM+1
                HOLD(2,k+1) = HOLD(2,k)+DIFF;
                data(i-j+k,POS) = HOLD(2,k+1); %replace exsisting:
                k = k + 1;
            end
            
            %save in correct struct:
            if struct == 1
                ROX.Voltage.A(:,1) = data(:,1);
            elseif struct == 2
                ROX.Voltage.B(:,1) = data(:,1);
            elseif struct == 3
                ROX.Voltage.C(:,1) = data(:,1);
            elseif struct == 4
                ROX.Amp.A(:,1) = data(:,1);
            elseif struct == 5
                ROX.Amp.B(:,1) = data(:,1);
            elseif struct == 6
                ROX.Amp.CA(:,1) = data(:,1);
            elseif struct == 7
                ROX.kW.A(:,1) = data(:,1);
            elseif struct == 8
                ROX.kW.B(:,1) = data(:,1);
            elseif struct == 9
                ROX.kW.C(:,1) = data(:,1);
            elseif struct == 10
                ROX.kVAR.A(:,1) = data(:,1);
            elseif struct == 11
                ROX.kVAR.B(:,1) = data(:,1);
            elseif struct == 12
                ROX.kVAR.C(:,1) = data(:,1);
            end
   
            %Reset Variables:
            j = 1;
            k = 1;
            HOLD = zeros(2,10);
        end
        i = i+1;
    end
    i = 1;    
    
    
    struct = struct+1;
end

%%

fig = 1;
figure(fig)
subplot(2,3,1)
plot(ROX.Voltage.A,'r-');
subplot(2,3,2)
plot(ROX.Voltage.B,'g-');
subplot(2,3,3)
plot(ROX.Voltage.C,'b-');



