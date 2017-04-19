function [timestruct] = timeteam_crawl()
%pubmed_search Search PubMed database and write results to MATLAB structure
% 
%   INPUTS
%   =========================================
%   
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

%% Handle NKIR 2014 error exception
for currentRowingMatch = 1 : numberofRowingMatches
    urlMatchResponse = [];
    disp(matches{1,currentRowingMatch});
    if(regexp(matches{1,currentRowingMatch},'nkir/2014'))
        [~,hitsForwardslash] = regexp(matches{1,currentRowingMatch},'/');
        matches{1,numberofRowingMatches+1} = regexp(matches{1,currentRowingMatch}(hitsForwardslash(5):end),'[]http://regatta..*?matrix.php', 'match');
        matches{1,currentRowingMatch} = strcat(matches{1,currentRowingMatch}(1:hitsForwardslash(5)),'results/matrix.php');
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
    if strcmp(name,'coupe') || strcmp(name,'nls') || strcmp(name,'srg')
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
        %url = 'http://regatta.time-team.nl/varsity/2017/results/010.php';
        url = strcat(matches{1,currentRowingMatch}(1:end-10),rowingCrewURL(crew,:));
        urlCrewResponse = webread(url);
        urlCrewResponseFilter(crew,:) = regexp(urlCrewResponse,'container.*?</div>','match');
        crewContent2 = regexp(urlCrewResponseFilter(crew,:),'<tr class=.*?><td>.*?</td></tr>','match');
        crewContent = crewContent2{1,1}(1:2:end);
        disp(['Number of participating crews in ', rowingCrews{1,crew}{1,1}, ': ', num2str(length(crewContent))]);
        crewName = regexp(crewContent,'<a href=.*?>.*?</a>','match');
        crewName = crewName(~cellfun(@isempty, crewName));
        
        crewStartName = {};
        
        if(length(crewName) == 0)
            continue
        end
        for i = 1 : length(crewName(1,:))
            crewLinktmp(i,:) = regexp(crewName{1,i}{1,2},'''(.[^'']*)''','match');
            crewLinktmp2(i,:) = regexp(crewName{1,i}{1,2},'>.*?<','match');
            crewLinktmp3(i,:) = regexp(crewContent,'right;.*?>.*?</td>','match');
            %crewLinktmp4(i,:) = regexp(crewLinktmp3,'>.*?<','match');
            for j = 1 : length(crewLinktmp3{1,i})-1
                crewStartName{crew,i,j+2} = crewLinktmp3{1,i}{1,j}(9:end-5);
            end
            crewStartName{crew,i,1} = crewLinktmp2{i,1}(2:end-1);
            crewStartName{crew,i,2} = crewLinktmp{i,1}(4:end-1);
            
        end
        clearvars crewLinktmp crewLinktmp2 crewLinktmp3 crewLinktmp4
    end
        
    
    timestruct(currentRowingMatch - importErrors).name = name;
    timestruct(currentRowingMatch - importErrors).year = year;
    timestruct(currentRowingMatch - importErrors).startingList = rowingCrews;
    timestruct(currentRowingMatch - importErrors).results = crewStartName; %startingList,startingClub,results
    clearvars urlCrewResponse urlCrewResponseFilter crewContent2 crewContent crewName crewStartName
    disp(num2str(currentRowingMatch-importErrors));
end


% for i = 1:length(Ctopics)
%     searchterm = Ctopics(i);
%     
%     e_params = strrep(searchterm,' ','+');
%     for year = 2000:2014
%         e_params2 = strcat(e_params{1,1},'("',num2str(year),'/01/01"[Date - Publication] : "',num2str(year),'/12/30"[Date - Publication])'); 
%         searchURL = strcat(baseSearchURL,e_params2);
% 
%         medlineText = urlread(searchURL);
%         hits_char = regexp(medlineText,'<meta name="ncbi_resultcount".*?/>','match');
%         [~,hits_integer_index] = regexp(hits_char,'"');
%     if length(hits_integer_index{1,1}) < 4
%         disp('NCBI database has most likely been edited');
%     end
%         hits(i,year-1999) = str2double(hits_char{1,1}(hits_integer_index{1,1}(3)+1:hits_integer_index{1,1}(4)-1));
%     end
% end
% 
% baseline = mean(hits);
% baseline2 = repmat(baseline,length(Ctopics),1);
% basel_hits = hits-baseline2;
% 
% for i = 1:length(Ctopics)
%     slope(i,:) = polyfit(1:15,basel_hits(i,:),1);
% end

%hits = regexp(medlineText,'PMID-.*?(?=PMID|</pre>$)','match');

%hits = cellfun(@(x) html_encode_decode_amp('decode',x),hits,'un',0);

%NEED To DEAMPERSAND THE RESULTS ...

% pmstruct = struct(...
%     'raw','', ...
%     'title','', ...
%     'volume','',...
%     'year','',...
%     'pages','',...
%     'authors','',...
%     'journal','',...
%     'journalAbbr','',...
%     'doi','',...
%     'PMID','',...
%     'issn_print','',...
%     'issn_link','');

%"Search Field Descriptions and Tags"
%-> http://www.ncbi.nlm.nih.gov/books/NBK3827/#pubmedhelp.Search_Field_Descrip
%http://www.nlm.nih.gov/bsd/mms/medlineelements.html
% for n = 1:numel(hits)
%     pmstruct(n).raw              = hits{n};
%     
%     temp_title = strtrim(regexp(hits{n},'(?<=TI  - ).*?(?=PG  -|AB  -)','match', 'once')); 
%     
%     pmstruct(n).title = regexprep(temp_title,'\s+',' '); %Remove multiple whitespaces ...
%     
%     
%     if ~isempty(regexpi(pmstruct(n).title,'not available'))
%        pmstruct(n).title = ''; 
%     end
%     
%     pmstruct(n).volume           = deref(regexp(hits{n},'(?:VI  - )([^\s]*)','tokens','once'),'string');
%     pmstruct(n).year             = deref(regexp(hits{n},'(?:DP  - )(\d+)','tokens','once'),'string');
%     pmstruct(n).pages            = deref(regexp(hits{n},'(?:PG  - )([^\s]+)','tokens','once'),'string');
%     pmstruct(n).authors          = regexp(hits{n},'(?<=AU  - ).*?(?=\n)','match');
%     pmstruct(n).journal          = deref(regexp(hits{n},'(?:JT  - )([^\n]*)','tokens','once'),'string');
%     pmstruct(n).journalAbbr      = deref(regexp(hits{n},'(?:TA  - )([^\n]*)','tokens','once'),'string');
%     %AID OR LID
%     %LID - 10.1002/ajmg.a.34034 [doi]
%     %AID - 10.1002/ajmg.a.34034 [doi]
%     pmstruct(n).doi              = deref(regexp(hits{n},'(?:LID - )([^\s]*)(?: \[doi)','tokens','once'),true);
%     if isempty(pmstruct(n).doi)
%         pmstruct(n).doi          = deref(regexp(hits{n},'(?:AID - )([^\s]*)(?: \[doi)','tokens','once'),true);    
%     end
%     if isempty(pmstruct(n).doi)
%         pmstruct(n).doi  = '';
%     end
%     %COULD ADD ISSUE AS WELL
%     pmstruct(n).PMID             = regexp(hits{n},'(?<=PMID- ).*?(?=\n)','match', 'once');
%     
%     %IS  - 0022-2151 (Print)
%     %IS  - 0022-2151 (Linking)
%     pmstruct(n).issn_print       = deref(regexp(hits{n},'(?:IS  - )(\d{4}-\d{4})(?: \(Print\))','tokens'),'string');
%     pmstruct(n).issn_link        = deref(regexp(hits{n},'(?:IS  - )(\d{4}-\d{4})(?: \(Linking\))','tokens'),'string');
end