<AppName>
Application that helps researcher to find back to back literature from a paper

Overview
<AppName> will pull data from Microsoft Cognitive Service Labs (MCSL) API based on paper [ Title | Keyword | Author]. Since MCSL doesn't provide us with the citation paper information, we also use Allen Institute's Semantic Scholar API.
Given a paper information, we use data that we collected form both API to find the best papers that it cites, and the best papers that cite it. We then create a before/after citation map of a paper. 
We return best papers citation and reference based on citation number and the paper venue.
