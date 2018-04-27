function [pool] = timeStruct_timePool()
% Pool Timings of timingstruct.mat
%
%   INPUTS
%   =========================================
%   timestruct.mat
%
%   OPTIONAL INPUTS
%   =========================================
%
%   OUTPUTS
%   =========================================

%% load timestruct.mat
load('timestruct.mat');
poolingList = [];

for timestruct_at = 1 : length(timestruct);
    if isempty(timestruct(timestruct_at).startingList) == 1
        continue
    end
    for startingList_at = 1 : length(timestruct(timestruct_at).startingList(1,:))
        nonempty_crewMatch = timestruct(timestruct_at).startingList(~cellfun('isempty',timestruct(timestruct_at).startingList(:,startingList_at)),startingList_at);
        len = length(nonempty_crewMatch);
        if len > 2
            for match = 2 : len-1
                if length(nonempty_crewMatch{match,1}(1,:)) == 6
                    disp([num2str(timestruct_at),' ',num2str(startingList_at),' ',num2str(match)]);
                    for i = 1 : length(nonempty_crewMatch{match,1}(:,6))
                        if strcmp(nonempty_crewMatch{match,1}{i,6},'--')
                            nonempty_crewMatch{match,1}{i,6} = [];
                        end
                    end
                    tmp = vertcat(nonempty_crewMatch{match,1}(:,6));
                    poolingList = vertcat(poolingList,tmp);
                    tmp = [];
                end
            end
        end
    end
end
pool = poolingList(~cellfun('isempty',poolingList));
for i = 1 : length(pool)
    if length(pool{i,1}) ~= 8
        pool{i,1} = [];
    end
end
pool = pool(~cellfun('isempty',pool));
pool = cell2mat(pool);

pool_datenum = datetime(pool,'InputFormat','mm:ss,SS');
m = pool_datenum.Second + pool_datenum.Minute*60;
hist(m,30);


end

