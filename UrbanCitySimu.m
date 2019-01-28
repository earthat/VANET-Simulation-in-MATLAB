function [distance,energy,nw_liftime,throughput]=UrbanCitySimu(NumOfNodes,src_node,dst_node)



citysize=100;
axis([0 citysize+1 0 citysize+1]);
hold on
blksiz=30;
Eini=1;% in joules
% Range=(3*(blksiz/2))/2;
Range=20;
breadth = 0; 
display_node_numbers = 1;
% src_node=5;
% src_node=round(1+(NumOfNodes-1).*rand);
src_node1=src_node;
% dst_node=round(1+(NumOfNodes-1).*rand);
% dst_node=35;
%% uicontrol
                H = uicontrol('Style', 'listbox', ...
                    'Units', 'normalized', ...
                    'Position', [0.6 0.2 0.3 0.68], ...
                    'String', {'Path Establishing...'});
                drawnow;
%                 pause(1.0);
%%
%%%%%%%%%%%%creating road network%%%%%%%%%
for len = 0:citysize
    if(rem(len,10)~=0)
        for breadth = 0:citysize
            if(rem(breadth,10)~=0)
                h1 = plot(len,breadth,':g');
            end
        end   
    end
    breadth = breadth+1; 
end
%%%%%%%%%%%%%%%%END1%%%%%%%%%%%%%%%%%%%%%%%%%%
Node = zeros(NumOfNodes,6); % 1:X, 2:Y, 3:updatedX, 4:updatedY, 5:direction
%%%%%%%%%%%%%%%%%%%%%get random nodes%%%%%%%%%%%%%%%%%
for node_index = 1:NumOfNodes
    TempX = randi([0,citysize],1,1); 
    if (rem(TempX,10)==0)
        %sprintf('TempX = %d\n',TempX);
        Node(node_index,1) = TempX;       %X co-ordinate in 1st column
        Node(node_index,2) = randi([0,citysize],1,1); %Y co-ordinate in 2nd column
        %sprintf('%d IF: X=%d Y=%d',node_index, Node(node_index,1),Node(node_index,2))
    else
        Node(node_index,2) = 10*(randi([0,citysize/10],1,1)); %Y co-ordinate in 2nd column 
        Node(node_index,1) = randi([0,citysize],1,1); %X co-ordinate
        %sprintf('%d ELSE: X= %d Y= %d',node_index, Node(node_index,1),Node(node_index,2))
    end
end
%% Assign Positions to RSUs
m=1;
temp=1472014;
for ii=blksiz/2:2*blksiz:citysize
    n=1;
    for jj=blksiz/2:2*blksiz:citysize
        rsu.position{m,n}=[ii,jj]; % RSU's Position
        rsu.ID{m,n} =  temp;% RSU's ID
        plot(ii,jj,'xr','Linewidth',2)
        text(ii+1,jj, num2str(rsu.ID{m,n}))
        n=n+1;
        temp=temp+1;
    end
    m=m+1;    
end
m=round((citysize/(2*blksiz))+1);
for ii=blksiz/2+blksiz:2*blksiz:citysize
    n=1;
    for jj=blksiz/2+blksiz:2*blksiz:citysize
        rsu.position{m,n}=[ii,jj];% RSU's Position
        rsu.ID{m,n} =  temp;% RSU's ID
        plot(ii,jj,'xr','Linewidth',2)
        text(ii+1,jj, num2str(rsu.ID{m,n}))
        n=n+1;
        temp=temp+1;
    end
    m=m+1;    
end
rsu.origID=rsu.ID;
% combine nodes position and RSU positions in a single matrix
temp=reshape(rsu.position,numel(rsu.position),1);
temp=temp(~cellfun(@isempty, temp)); % delete empty cell in the matrix
for ii=1:numel(temp)
    temp1(ii,:)=temp{ii};
end
node_rsu=[Node;repmat(temp1,1,3)]; % combined matrix for rsu and nodes location
clear temp temp1

%%
%sprintf('Number of Nodes %d',NumOfNodes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%labels = cell2str(num2str([1:NumOfNodes]'));
%h1 = ones(NumOfNodes,1);
h2 = ones(NumOfNodes,1);
h4 = ones(1,1);
counter=1;
for n = 0:citysize
    for node_index = 1:NumOfNodes
        
        if(rem(Node(node_index,1),10)~=0)
            h2(node_index) = plot(Node(node_index,1)+n*(2*(rem(node_index,2))-1), Node(node_index,2),'.k');
               
            node_rsu(node_index,3) = Node(node_index,1)+n*(2*(rem(node_index,2))-1); 
            node_rsu(node_index,4) = Node(node_index,2);
            node_rsu(node_index,5) = rem(node_index,2)+2;
            if node_index==src_node1
                plot(node_rsu(node_index,3), node_rsu(node_index,4),'og');
                h7=text(node_rsu(node_index,3), node_rsu(node_index,4)+1,num2str(src_node1));
%                 hold on
            end
            if node_index==dst_node
                plot(node_rsu(node_index,3), node_rsu(node_index,4),'dm');
                h9=text(node_rsu(node_index,3), node_rsu(node_index,4)+1,num2str(dst_node));
%                 hold on
            end
        else
            h2(node_index) = plot(Node(node_index,1),Node(node_index,2)+n*(2*(rem(node_index,2))-1),'.k');
           
            node_rsu(node_index,3) = Node(node_index,1);
            node_rsu(node_index,4) = Node(node_index,2)+n*(2*(rem(node_index,2))-1);
            node_rsu(node_index,5) = rem(node_index,2);
            if node_index==src_node1
                plot(node_rsu(node_index,3), node_rsu(node_index,4),'og');
                h7=text(node_rsu(node_index,3), node_rsu(node_index,4)+1,num2str(src_node1));
%                 hold on
            end
             if node_index==dst_node
                plot(node_rsu(node_index,3), node_rsu(node_index,4),'dm');
                 h9=text(node_rsu(node_index,3), node_rsu(node_index,4)+1,num2str(dst_node));
%                 hold on
            end
        end
    end
    %%%%%%%%%AODV%%%%%%%%%%%%%%%5
    % find all nodes which are in range of each other
    for p = 1:size(node_rsu,1)
        for q = 1:size(node_rsu,1)
            dist=sqrt((node_rsu(p,3)-node_rsu(q,3))^2+(node_rsu(p,4)-node_rsu(q,4))^2);
            if dist<=Range
                inrange(p,q)=1;
            else
                inrange(p,q)=0;
            end
            
        end
    end
    src_node=src_node1; % to reset teh src_node to original source node after every iteration of n=1:citysize
    rtngtble=src_node;% initialise
    tble1=src_node;% initialise
    tble=src_node;% initialise
    cnt=1;% initialise
    cnt1=1;% initialise
    dimnsn(cnt)=numel(rtngtble);
    while rtngtble~=dst_node
       
            for ii=1:numel(tble1)
                src_node=tble1(ii);
                temp=find(inrange(src_node,:));
                temp=temp(find(ismember(temp,tble)==0));
                str{cnt1}=[src_node,temp];
                tble=[tble, temp];
                cnt1=cnt1+1;
            end
            tble1=tble(find(ismember(tble,rtngtble)==0));% seprate nodes which are not present in routing table
            rtngtble=[rtngtble,tble];
            % remove the repeated node in table
            [any,index]=unique( rtngtble,'first');
            rtngtble=rtngtble(sort(index));
            
            if ismember(dst_node,rtngtble)
                dst_cell=find(cellfun(@equal, str,repmat({dst_node},1,length(str)))); % find out whihch structre cell has destination node
                dst=dst_cell;
                nodtble=dst_node;
                frst_node=dst;
                while frst_node~=src_node1
                    frst_node=str{dst(1)}(1);
                    dst=find(cellfun(@equal, str,repmat({frst_node},1,length(str)))); 
                    nodtble=[nodtble, frst_node];
                end
%                 msgbox('path found')
                nodtble=fliplr(nodtble) % final routing table
                %% uicontrol setting
                set(H, 'String', cat(1, get(H, 'String'), {['Path ' num2str(nodtble)]}));
                drawnow;
                pause(0.25);
                
%                 set(H, 'String', cat(1, get(H, 'String'), {'End'}));
%                 drawnow;
%                 pause(1.0);
                %%
                route{counter}=nodtble; % save all AODV paths for each change in vehicle position into a structure
                h4= plot(node_rsu(nodtble,3),node_rsu(nodtble,4)); 
                pause(0.01); 
                 set(h4,'Visible','off');
                 [E,pcktlossrate,total_dist,pcktloss,thrgput]=evaluation(nodtble,node_rsu); % parameters calculation 
                 energy(counter,:)=E; % energy consumption
                 distance(counter)=total_dist;% Total Distance between hops in AODV path
                 throughput(counter,:)=thrgput; % throughput
                 counter=counter+1;
             end

            cnt=cnt+1;
            dimnsn(cnt)=numel(rtngtble);
            if numel(rtngtble)==1           
                msgbox('1-No Node in range, Execute again')
                return
            end
            if cnt>=5
%                 h8=msgbox('No path found');
                break
            end
         
    end
    pause(0.0001); 
    set(h2,'Visible','off');
    set(h7,'Visible','off');
    set(h9,'Visible','off');
end
%% plot results
figure(2)
plot(distance,'r','linewidth',2)
xlabel('Number of times path found during simulation of VANET')
ylabel('Dsiatnce in a path for each source and destination vehicles position')
title(['Total Distnace in each linked path with hops=', num2str(cellfun('ndims',route(1)))])
grid on

figure(3)
plot(energy,'Linewidth',1.5)
xlabel('Number of times path found during simulation of VANET')
ylabel('Energy in Joules')
title('Energy Consumption')
legend('Data Rate=4 pckts/sec','Data Rate=6 pckts/sec','Data Rate=8 pckts/sec','Data Rate=10 pckts/sec','Data Rate=12 pckts/sec','Data Rate=14 pckts/sec')
grid on

nw_liftime=Eini./energy; % netwrok life time
figure(4)
plot(nw_liftime,'Linewidth',1.5)
xlabel('Number of times path found during simulation of VANET')
ylabel('Netwrok Life time')
title('Netwrok life time plot for different data rates')
legend('Data Rate=4 pckts/sec','Data Rate=6 pckts/sec','Data Rate=8 pckts/sec','Data Rate=10 pckts/sec','Data Rate=12 pckts/sec','Data Rate=14 pckts/sec')
grid on

figure(5)
plot(throughput/10e6,'Linewidth',1.5)
xlabel('Number of times path found during simulation of VANET')
ylabel('Throughput in MBps ')
title('Throughput plot for different data rates')
legend('Data Rate=4 pckts/sec','Data Rate=6 pckts/sec','Data Rate=8 pckts/sec','Data Rate=10 pckts/sec','Data Rate=12 pckts/sec','Data Rate=14 pckts/sec')
grid on
end


    
