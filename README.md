ohi-global Antarctica
==========
  
### Global assessment for Antarctica

#### Anatomy of the file structure

General information about file structure is here: http://ohi-science.org/manual/#file-system-organization

This includes files for the OHI global assessment for Antarctica 2014-2015 CCAMLR regions (includes the high seas/FAO and EEZ regions)


Additional files/folders include:

* calculate\_scores_aq..R: These files provide the code to calculate scores for the corresponding OHI assessment, including a version with changes to sea ice
* layers\_antarctica.csv: provides location of the data layers used to calculate the OHI assessments. 
* other files can be ignored

Important files within the antarctica folder include:

* layers.csv: provides the location of the data layers used to calculate the OHI assessments. 
* scores.csv: The OHI scores
* layers.csv: All the data layers used by the OHI models to calculate scores
* conf: Files that are used to set up the OHI model parameters
    - config.R: define model parameters, weighting files, etc.
    - functions.R: functions used to calculate goal/subgoal status and trend scores
    - goals.csv: list of goals and corresponding weights (also where status years are defined for each assessment year)
    - pressures_matrix.csv: Weights for each pressure layer and goal
    - resilience_matrix.csv: Indicates which resilience layers affect which goals
    
