function output_matrix = poissonprivacy(lambda,rounds)

% A very simple privacy tester of the "random poisson delay" privacy
% feature in Bitcoin Core and Bitcoin ABC. 
% 

output_matrix = false(rounds,1);

% the number of nodes is hardcoded to 17 for convenience. Every node is
% connected to every other node.

% node 1 is the "sender" and node 2 is the "receiver".

for i = 1:rounds
    
    % fill in the random delays for each connection. Row -> Column. (i.e. delay
    % from node 1 to 2 is at (1,2)
    
    nodematrix = poissrnd(lambda,17,17);
    
    % nodes don't send to themselves!
    
    for j = 1:17
        nodematrix(j,j) = NaN;
    end
    % direct delay
    directdelay = nodematrix(1,2);
    
    % start alternative route at 999 seconds
    mindelay = 999;
    % iterate through alternative routes, go 3-deep
    
    for j = 3:17
        % one-deep
        delaytemp = nodematrix(1,j) + nodematrix(j,2);
        mindelay = min(delaytemp,mindelay);
        
        % two-deep
        for k = 3:17
            if j == k
                continue
            end
            delaytemp = nodematrix(1,j) + nodematrix(j,k) + nodematrix(k,2);
            mindelay = min(delaytemp,mindelay);
            
            % three-deep
            for l = 3:17
                if j == l || k == l
                    continue
                end
                delaytemp = nodematrix(1,j) + nodematrix(j,k) + nodematrix(k,l) + nodematrix(l,2);
                mindelay = min(delaytemp,mindelay);
            end
        end
        
        
    end
    
    % if mindelay < directdelay, obfuscation is achieved; node 2 will get
    % message from another node before node 1. 
    if mindelay < directdelay
        output_matrix(i) = true;
    end
end



