# FIJI-macro-ADA
This contains several ImageJ/FIJI macros used to quantify actin intensity on mitochondria in images/films of stained cells.

We have been studying a phenomenon we call Acute Damage-induced Actin, or ADA, in which we observe a buildup of actin around mitochondria when mitochondria are damaged. In our experiments, we have done a significant amount of cell imaging that we analyze using FIJI. To measure the actin intensity on mitochondria, we developed these macros.

Each macro will have specific instructions via comments in each file, but they all do similar things: measuring intensity of actin overlapping with mitochondria. The "ADA_detection" macros measure the intensity of actin overlapping with mitochondria and also the intensity of actin NOT overlapping with mitochondria in an attempt to normalize this intensity. The "ADA_quantification" macro simply measures the intensity of the actin on mitochondria.

While we designed these macros specifically for the study of ADA, they can be applied to any attempt at quantifying intenity of one channels overlapping with signal on another channel. 

To use these macros, you can download them from here, or from our Zenoba link: _______
Simply drag the file into FIJI and it will open automatically. Please remember to read over the directions commented in each macro.


The purpose of each macro is as follows:
ADA_detection: To measure the actin intensity on mitochondria against actin intensity in the rest of the cell for a two-channel image.
ADA_detection_w/nucleus: The same as the last but on an image with a nucleus channel; the nucleus is automatically segmented and removed from the selection for a more accurate measurement. 
ADA_movie_detection: The same as the first, but does so for every frame of a movie of a live cell.
ADA_quantification_mutlipleROIs: Just measures the actin intensity on mitochondria for every frame of a movie of a live cell. 
