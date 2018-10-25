<AppName>
Application that helps researcher to find back to back literature from a paper

<h2>Overview</h2>

In this app we use 2 APIs, <b>Microsoft Cognitive Service Labs (MS) API</b> and <b>Allen Institute's Semantic Scholar (SS) API</b>. The limitation of MCSL API is that it cannot provide us with the citation paper title data. Semantic Scholar API can provide the citation paper data, but it can only return data based on [PaperID | DOI | arxiv] input. So we retrieve such DOI from MS API and then use SS API to provide us with citation paper data.

Given a paper information, we use data that we collected form both API to find the best papers that it cites, and the best papers that cite it. We then create a before/after citation map of a paper. 

We return best papers citation and reference based on citation number and the paper venue.
