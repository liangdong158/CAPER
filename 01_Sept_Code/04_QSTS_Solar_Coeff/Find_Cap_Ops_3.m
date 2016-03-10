function [ KVAR_ACTUAL,error,op_count] = Find_Cap_Ops_3(KVAR_ACTUAL,KVAR_ACTUAL_1,sim_num,s_step,Caps,KW_ACTUAL,KW_ACTUAL_1,cap_pos,DOY)
%Goal: Find Capacitor operations based on profile
sim_num = str2num(sim_num);
%sim_num=1440
%s_step=60s

%1] Calculate delta_t=10intervals Q slope.
k = 1; %Used to loook to the next day for last 10 points
error = 0;
op_count = 0;
hit1=0;
for i=1:1:sim_num
    for ph=1:1:3
        if i <= sim_num-10
            KVAR_diff = KVAR_ACTUAL.data(i+10,ph)-KVAR_ACTUAL.data(i,ph); %Look 10 minutes in the future
            KW_diff = KW_ACTUAL(i+10,ph)-KW_ACTUAL(i,ph);
        else
            KVAR_diff = KVAR_ACTUAL_1.data(k,ph)-KVAR_ACTUAL.data(i,ph); %Look 10 minutes in the future
            KW_diff = KW_ACTUAL_1(k,ph)-KW_ACTUAL(i,ph);
        end
        KVAR_ACTUAL.data(i,ph+6)=KVAR_diff;
        KVAR_ACTUAL.dP(i,ph)=KW_diff;
    end
    if i > sim_num-10
        k = k + 1;
    end
end
instance_neg = 0;
count_neg = 0;
instance_pos = 0;
count_pos = 0;
%2] Interp dQ's.
KVAR_diff = 0;
KVAR_mag = 0;
KW_diff = 0;
for i=1:1:sim_num
    for ph=1:1:3
        %Calculate 3-Phase Terms:
        KVAR_diff = KVAR_diff + KVAR_ACTUAL.data(i,ph+6);
        KVAR_mag= KVAR_mag+ abs(KVAR_ACTUAL.data(i,ph+6));
        KW_diff = KW_diff + KVAR_ACTUAL.dP(i,ph);
        
        %Caclulate single-phase PF:
        Q=KVAR_ACTUAL.data(i,ph);
        P=KW_ACTUAL(i,ph);
        S=sqrt(Q^2+P^2);
        PF = abs(P)/S;
        KVAR_ACTUAL.PF(i,ph)=PF;
    end
    KVAR_ACTUAL.PF(i,4)=(KVAR_ACTUAL.PF(i,1)+KVAR_ACTUAL.PF(i,2)+KVAR_ACTUAL.PF(i,3))/3;
    
    KVAR_ACTUAL.data(i,10) = KVAR_diff; %3ph dQ
    KVAR_ACTUAL.data(i,11) = KVAR_mag;  % |dQ_3ph|
    KVAR_ACTUAL.dP(i,4) = abs(KW_diff); %3ph dP
    
    %KVAR_ACTUAL.sw_cap(i,ph)=cap_pos;
    KVAR_ACTUAL.data(i,4)=1;
    KVAR_ACTUAL.PF(i,5)=1;
    KVAR_diff = 0;
    KW_diff = 0;
    KVAR_mag = 0;
end

%5] generate 3ph reactive power:
for i=1:1:sim_num
    KVAR_ACTUAL.data(i,5) = KVAR_ACTUAL.data(i,1)+KVAR_ACTUAL.data(i,2)+KVAR_ACTUAL.data(i,3);
    P_3ph = KW_ACTUAL(i,1)+KW_ACTUAL(i,2)+KW_ACTUAL(i,3);
    %Find PF:
    S = sqrt((P_3ph^2)+(KVAR_ACTUAL.data(i,5)^2));
    PF = abs(P_3ph)/S;
    KVAR_ACTUAL.data(i,6) = PF;
end
KVAR_ACTUAL.datanames={'phA','phB','phC','Cap_Status','3ph_Q','3ph,PF','dQA','dQB','dQC','dQ3ph','|dQ3ph|'};

%6] generate reactive power for DSS loads:
KVAR_ON=[2.173495346357307e+02,1.976303522549747e+02,2.802254460650596e+02];
KVAR_OFF=[5.773752746613869e+02,5.602529605242753e+02,6.308542533514893e+02];
DIFF=KVAR_OFF-KVAR_ON;
%ph_perc=350./DIFF;
%ph_perc=[.925,.9698,.9];
ph_perc=[1,1,1];
%Find actual reactive power being consumed by loads:
%fprintf('%d\n',KVAR_ACTUAL.data(1,1));
KVAR_ACTUAL.DSS(:,1)=KVAR_ACTUAL.data(:,1)+(Caps.Fixed(1)+Caps.Fixed(2)+Caps.Fixed(3))*ph_perc(1,1);
KVAR_ACTUAL.DSS(:,2)=KVAR_ACTUAL.data(:,2)+(Caps.Fixed(1)+Caps.Fixed(2)+Caps.Fixed(3))*ph_perc(1,2);
KVAR_ACTUAL.DSS(:,3)=KVAR_ACTUAL.data(:,3)+(Caps.Fixed(1)+Caps.Fixed(2)+Caps.Fixed(3))*ph_perc(1,3);

end
