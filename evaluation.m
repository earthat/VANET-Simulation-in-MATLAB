function [E,pcktlossrate,total_dist,pcktloss,thrgput]=evaluation(nodtble,node_rsu)
 % take out the distance of nodes in routing table from each other
for ii=1:numel(nodtble)-1
    distnc(ii)=sqrt((node_rsu(nodtble(ii+1),3)-node_rsu(nodtble(ii),3))^2+(node_rsu(nodtble(ii+1),4)-node_rsu(nodtble(ii),4))^2);
end
total_dist=sum(distnc); % total distnace from source to destination
time_consumed=total_dist/(3*10e9);
%% Perfromance Evolution
pktsize=64;% in bytes
datarate=[4,6,8,10,12,14]; % packets/sec
Etx=1;% in joules
Eini=Etx;
Elec=50e-9; %amount of Energy consumption per bit in the transmitter or receiver circuitry
Emp=0.0015e-12;%Amount of energy consumption for multipath fading
EDA=5e-9; %Data aggregation energy.
% paraemetrs for energy calculation using raio model of message
% transmission

alpha1=50e-9; %J/bit
alpha2=0.1e-9; %J/bit/m2
alpha=2;
Ebit=0.3e-3; % energy assigned to each bit 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%radio Model for energy consumption is 
% E=alpha1+alpha2*(dist)^alpha
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hop=numel(nodtble);
for ff=1:length(datarate)
            E(ff)=(alpha1*datarate(ff)*pktsize*8)+(alpha2*datarate(ff)*pktsize*8)*(total_dist)^alpha;% energy loss calculation in transmitting packets at datarate
            Edata(ff)=Ebit*datarate(ff)*pktsize*8;
            for ll=1:datarate(ff)
                Etx=Etx-(Elec*8*pktsize+Emp*8*pktsize);
                Erx=Eini-Etx;
                Erx=Erx-(Elec+EDA)*8*pktsize;
                Eini=Etx;
                if Etx<0.98
                    pcktloss(ll)=1;
                else
                    pcktloss(ll)=0;
                end
            
            end
            if hop>4 && datarate(ff)> 6
                pcktlossrate(1,ff)=(datarate(ff)-7)/datarate(ff);
            else
                pcktlossrate(1,ff)=0;
            end
            thrgput(1,ff)= (datarate(ff)*pktsize)/time_consumed;          
 end