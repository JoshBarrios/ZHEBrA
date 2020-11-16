# ZHEBrA
 Zebrafish Head Embedded Behavior Analysis

Dependent on Douglass lab "Utilities" repo

Run ZHEBrA.m to launch GUI. Prompts will handle differences in data formats, fish orientations, lighting setups, etc. Movies should be saved in individual folders within a parent directory. ZHEBrA accepts tif stacks, tif series, and RAW movies. ZHEBrA will output tail angle over time for a set of behavior recordings, detect discreet swim bouts, extract 59 kinematic parameters per swim bout and run clustering based on these kinematic parameters (optional). Clustering options include k-means, cluster-DV (requires cluster-DV package), and self-organizing map (SOM).
