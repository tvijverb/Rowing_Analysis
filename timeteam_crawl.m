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
urlResponse = urlread2(baseSearchURL);

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
for currentRowingMatch = 1 : numberofRowingMatches
    urlMatchResponse = [];
    disp(matches{1,currentRowingMatch});
    
    urlMatchResponse = urlread2(matches{1,currentRowingMatch});
    [~,hitsForwardslash] = regexp(matches{1,currentRowingMatch},'/');
    timestruct(currentRowingMatch).name = matches{1,currentRowingMatch}(hitsForwardslash(3)+1:hitsForwardslash(4)-1);
    disp(num2str(currentRowingMatch));
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