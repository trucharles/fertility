This is a test for Charles. 
Network meta-analysis with netmeta for fertility outcomes

Preparation:
  First parameter is url of Google Sheet with data
  Second parameter is vector of sheet names containing data

For continuous outcomes (Sperm count, sperm motility, sperm morphology, semen volume) use conduct_nma_cont

Google Sheet preparation:
  Required columns are Study ID, Grouped intervention,	Control,	Intervention Mean,	Intervention SD,	Intervention N,	Control Mean,	Control SD,	Control N

For dichotomous outcomes (Pregnancy live birth, pregnancy correlations) use conduct_nma_disc

Google Sheet preparation:
  Required columns are Study ID, Grouped intervention,	Event,	N total
  Note: Each arm gets its own row, unlike continuous outcomes
  Note: Inconsistency analysis is not included, as there were no closed loops in the network graph
