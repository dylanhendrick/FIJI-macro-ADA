// 2-channel movie (60 frames) as input:
// 1.- mitochondria, 2. - actin (phalloidin?)

// manual selection should be there! - group similar cells (in intensity/brightness of mitos) or individual cells.
// selections do not need to be precise, but make sure all mitos of a cell are included throughout the film.

// make sure you have channel 2 selected before running the program.

// this code measures actin intensity that overlaps mitos, within the selection; and total actin from the selection
// constant offset of 100 is subtracted from the phalloidin signal!

// get the number of frames
Stack.getDimensions(width, height, channels, slices, frames);

n = roiManager("count");

for (r = 0; r < n; r++) {

	for (i=1; i<=frames; i++) {
		roiManager("deselect");
		run("Duplicate...", "title=myimage duplicate frames=i");
		
		//roiManager("reset");
		
		selectWindow("myimage");
		
		
		run("Duplicate...", "title=myimage-mito duplicate channels=2");
		roiManager("Select", r);
		setBackgroundColor(0, 0, 0);
		run("Clear Outside");
		
		//setMinAndMax(96, 2903);
		setAutoThreshold("Otsu dark no-reset");
		//run("Threshold...");
		setOption("BlackBackground", false);
		run("Convert to Mask");
		selectWindow("myimage-mito");
		run("Create Selection");
		roiManager("Add");
		
		selectWindow("myimage");
		run("Duplicate...", "title=myimage-actin duplicate channels=1");
		selectWindow("myimage-actin");
		run("Subtract...", "value=100");	// the camera offset
		roiManager("Select", n);
		run("Measure");
		roiManager("delete");
		
		// cleanup
		selectWindow("myimage-mito");
		close();
		
		selectWindow("myimage");
		close();
		
		selectWindow("myimage-actin");
		close();
		run("Select None");
	
	}
	
	//Processes data in the results table after running the quantification

	//Will add a new column that normalizes the existing mean data to the average of the first 5 frames and the peak 
	
	IJ.renameResults("Results"); // otherwise below does not work...?
	start = frames * r;
	
	//find the average of first 5 frames (baseline)
	base = (getResult("Mean", start + 0) + getResult("Mean", start + 1) + getResult("Mean", start + 2) + getResult("Mean", start + 3)) / 4;
	
	
	//Find the normalized value for each frame with the formula (mean - baseline) / range
	for (row=start; row<nResults; row++) {
		normal = (getResult("Mean", row) - 500) / (base-500);// this is where the calculation happens
	    setResult("Normal", row, normal);
	}
	
	
	/* Easy to edit formula for new columns:
	
	for (row=0; row<nResults; row++) {
		*result* = *calculation*;  
	    setResult("*Name of new column*", row, *result*);
	}
	//Note: getResult("*Name of column*", row) - this gets the measurement of a column at the current row.
	*/
	
	updateResults();

}








