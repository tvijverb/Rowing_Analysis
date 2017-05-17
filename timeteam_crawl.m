function [timestruct] = timeteam_crawl()
% search time-team.nl database and write results to MATLAB structure
%
%   INPUTS
%   =========================================
%
%   OPTIONAL INPUTS
%   =========================================
%
%   OUTPUTS
%   =========================================


%% Create base URL for time-team db site
baseSearchURL = 'https://time-team.nl/informatie/uitslagen';
urlResponse = webread(baseSearchURL);


matches = regexp(urlResponse, 'http://regatta..*?matrix.php', 'match');
[numberofRowingMatches] = length(matches);

%% Handle NKIR/DMO 2014 error exception

err = 0;
for currentRowingMatch = 1 : numberofRowingMatches
    urlMatchResponse = [];
    disp(matches{1,currentRowingMatch-err});
    if(regexp(matches{1,currentRowingMatch-err},'nkir/2014'))
        [~,hitsForwardslash] = regexp(matches{1,currentRowingMatch-err},'/');
        matches{1,numberofRowingMatches+1} = regexp(matches{1,currentRowingMatch-err}(hitsForwardslash(5):end),'[]http://regatta..*?matrix.php', 'match');
        matches{1,currentRowingMatch-err} = strcat(matches{1,currentRowingMatch-err}(1:hitsForwardslash(5)),'results/matrix.php');
    end
    if(regexp(matches{1,currentRowingMatch-err},'dmo/2014'))
        err = 1;
    end
end
[numberofRowingMatches] = length(matches);
disp(matches{1,numberofRowingMatches});
%% Loop over all rowing matches
importErrors = 0;

for currentRowingMatch = 1 : numberofRowingMatches
    urlMatchResponse = [];
    rowingCrewURL=[];
    %Default var (name,year)
    [~,hitsForwardslash] = regexp(matches{1,currentRowingMatch},'/');
    name = matches{1,currentRowingMatch}(hitsForwardslash(3)+1:hitsForwardslash(4)-1);
    year = matches{1,currentRowingMatch}(hitsForwardslash(4)+1:hitsForwardslash(5)-1);
    disp(matches{1,currentRowingMatch});
    
    % Exception handeling
    if strcmp(name,'coupe') || strcmp(name,'nls') || strcmp(name,'srg') || strcmp(name,'dmo')
        importErrors = importErrors + 1;
        continue
    end
    if strcmp(year,'2011') || strcmp(year,'2010')
        importErrors = importErrors + 1;
        break
    end
    
    % Read match
    urlMatchResponse = webread(matches{1,currentRowingMatch});
    
    % Get rowing crew specific url extension
    [hits_char,index] = regexp(urlMatchResponse,'title=.*?>','match');
    rowingCrews = regexp(hits_char,'''(.[^'']*)''','match');
    for i = 1 : length(rowingCrews)
        rowingCrewURL(i,:) = urlMatchResponse(index(i)-9:index(i)-3);
        %disp(strcat(matches{1,currentRowingMatch}(1:end-10),rowingCrewURL(i,:)));
    end
    isValidRowingCrew = isstrprop(rowingCrewURL(:,1),'digit');
    rowingCrews = rowingCrews(isValidRowingCrew);
    rowingCrewURL = rowingCrewURL(isValidRowingCrew,:);
    disp(strcat(matches{1,currentRowingMatch}(1:end-10),rowingCrewURL(1,:)));
    
    for crew = 1 : length(rowingCrews)
        url = strcat(matches{1,currentRowingMatch}(1:end-10),rowingCrewURL(crew,:));
        tablefilter = [];
        matchname = [];
        if(strcmp(url,'http://regatta.time-team.nl/asoposnajaars/2016/results/001.php') || strcmp(url,'http://regatta.time-team.nl/asoposnajaars/2016/results/002.php') || strcmp(url,'http://regatta.time-team.nl/dmo/2014/results/323.php'))
            continue
        end
        
        urlCrewResponse = webread(url);
        disp(url);
        tablefilter = regexp(urlCrewResponse,'table class=''timeteam''>.*?</table>','match');
        matchname = regexp(urlCrewResponse,'<h2>.*?</h2>','match');
        
        if isempty(tablefilter) == 1
            continue
        elseif isempty(matchname) == 1
            continue
        elseif size(tablefilter) ~= size(matchname)
            continue
        else
            %urlCrewResponseFilter(crew,:) = regexp(urlCrewResponse,'container.*?</div>','match');
            crewContent2 = regexp(tablefilter,'<tr class=.*?><td>.*?</td></tr>','match');
            
            for games = 1 : length(tablefilter)
                crewContent = crewContent2{1,games}(1:2:end);
                disp(['Number of participating crews in ', rowingCrews{1,crew}{1,1}, ': ', num2str(length(crewContent))]);
                crewName = regexp(crewContent,'<a href=.*?>.*?</a>','match');
                crewName = crewName(~cellfun(@isempty, crewName));
                
                if(length(crewName) == 0)
                    continue
                end
                for i = 1 : length(crewName(1,:))
                    crewNameStr = rowingCrews{1,crew}{1,1};
                    crewNameStr = crewNameStr(2:end-1);
                    if( currentRowingMatch == 5 || currentRowingMatch == 27 || strcmp(crewNameStr,'Mixed Schoolroeien 4 (klas 4, 5, 6 &amp; ROC)') || strcmp(crewNameStr,'Junior Men&#039;s  Eight') || strcmp(crewNameStr,'Junior Women&#039;s  Four') || strcmp(crewNameStr,'Junior Women&#039;s  Eight') || strcmp(crewNameStr,'Mixed bedrijfs acht') || length(crewName{1,i}) == 1)
                        crewLinktmp(i,:) = regexp(crewName{1,i}{1,1},'''(.[^'']*)''','match');
                        crewLinktmp2(i,:) = regexp(crewName{1,i}{1,1},'>.*?<','match');
                        crewLinktmp3(i,:) = regexp(crewContent,'right;.*?>.*?</td>','match');
                    else
                        crewLinktmp(i,:) = regexp(crewName{1,i}{1,2},'''(.[^'']*)''','match');
                        crewLinktmp2(i,:) = regexp(crewName{1,i}{1,2},'>.*?<','match');
                        crewLinktmp3(i,:) = regexp(crewContent,'right;.*?>.*?</td>','match');
                    end
                    for j = 1 : length(crewLinktmp3{1,i})-1
                        rowingCrews{games+1,crew}{i,j+2} = crewLinktmp3{1,i}{1,j}(9:end-5);
                    end
                    rowingCrews{games+1,crew}{i,1} = crewLinktmp2{i,1}(2:end-1);
                    rowingCrews{games+1,crew}{i,2} = crewLinktmp{i,1}(4:end-1);
                end
                clearvars crewLinktmp crewLinktmp2 crewLinktmp3 crewLinktmp4
            end
            rowingCrews{length(tablefilter)+2,crew} = matchname;
        end
        
        
        timestruct(currentRowingMatch - importErrors).name = name;
        timestruct(currentRowingMatch - importErrors).year = year;
        timestruct(currentRowingMatch - importErrors).startingList = rowingCrews;
        clearvars urlCrewResponse urlCrewResponseFilter crewContent2 crewContent crewName crewStartName
        disp(num2str(currentRowingMatch-importErrors));
    end
end