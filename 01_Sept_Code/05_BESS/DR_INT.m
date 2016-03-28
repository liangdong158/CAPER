function [ peak ] = DR_INT( t_max,P_DAY1,bat_en,sigma )
%Steps:
%   1] Set initital position of t_A & t_B
%   2] while  error > sigma
    
    j=1;
    t_A = t_max-1;
    t_B_o = t_max+1;
    end_loop = 0;
    
    DAY = 1;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY)
    
    while end_loop ~= 1
        t_B = t_B_o;
        while t_B <= 1440
            %Save scenerio:
            peak(j).t_A = t_A;
            peak(j).t_B = t_B;
            time=t_A:1:t_B;
            %Find energy under curve (discrete)
            %peak(j).top = trapz(time,P_DAY1(time))/60;
            %--------------------------
            %Now find bottom energy:
            P_DAY1_bot(1,1)=P_DAY1(t_A); %P_A
            P_DAY1_srt = P_DAY1_bot(1,1);
            P_DAY1_bot(1,2)=t_A;
            for i=2:1:(t_B-t_A+1)
                %P_DAY1_bot(i,1)=P_DAY1_bot(i-1)+(P_DAY1(t_B)-P_DAY1(t_A))/(t_B-t_A+1);
                if P_DAY1_srt > P_DAY1(t_A+i-1)
                    %this means the actual load dipped below starting kW:
                    P_DAY1_bot(i,1) = P_DAY1(t_A+i-1);
                else
                    P_DAY1_bot(i,1) = P_DAY1_srt;
                end
                P_DAY1_bot(i,2)=t_A+i-1;
            end
            KW=P_DAY1(time);
            KD=P_DAY1_bot(:,1);
            length(KW);
            length(P_DAY1_bot(:,1));
            peak(j).en = trapz(P_DAY1_bot(:,2),KW-KD)/60; %kWh    
            %--------------------------
            %Find energy that will be covered:
            %peak(j).en = peak(j).top - peak(j).bot;
            peak(j).error = peak(j).en - bat_en;
            %Check to see if energy covered is enough:
            if peak(j).error > -1*bat_en*sigma && peak(j).error < bat_en*sigma
                end_loop = 1;
                t_B = 1440;
                %save optimum position info.
                peak(j).P_DAY1_bot = [P_DAY1_bot];
                peak(j).time = time;
                peak(j).P_DAY1_top = [P_DAY1(time)];
                peak(j).P_BESS = [KW-KD];
            else
                
                %to make faster, check to see if error is constant:
                
                if t_B == 600
                    if peak(j).error == peak(j-1).error
                        t_B = 1440; %skip all remaining options b/c kw is not above anymore
                    else
                        t_B = t_B + 1;
                    end
                else
                    %only for j = 1 case
                    t_B = t_B + 1;
                end 
                j = j + 1;
                %}
            end
            %move onto next scenerio:
            t_B = t_B + 1;
            %j = j + 1; 
        end
        t_A = t_A - 1; %find new P_A
        clear P_DAY1_bot
    end
        


end
