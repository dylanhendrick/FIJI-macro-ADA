/*

This macro measures the intensity of actin filaments overlapping with mitochondria in a selection over a 
multi-frame movie. 

Input: movie of cells with a channel for mitochondria and a channel for actin. 

Using one of the selection tools, create ROI's that outline cells. These selections do not have to be accurate at
all since the macro will simply find all mitochondria in the selection and measure the actin intensity in those
areas. In our method, we preferred to outline individual cells for more data points, but one could simply select the
entire image if needed. Add as many of these ROI's as you would like. It is important to quickly check the entire 
movie to make sure the cell stays in the ROI for accurate measurements.

For each ROI, the macro will threshold the mitochondria within the ROI and create a selection of these mitochondria.
Then, it will measure the actin intensity over this selection, which effectively measures the actin that overlaps
with the mitochondria. Finally, it will load a table consisting of the mean actin intensity overlapping with the 
mitochondria for every frame and this intensity normalized to the first 4 frames.

Some notes:
After making your final ROI selection, deselect all ROI's by clicking on the image outside of the last ROI before
running the macro.

The last bit of this macro organizes all the data on a table. If you would like to add a column or calculation, this
can be done there, and there is a handy formula for doing this.

The macro uses the measure tool to find the mean intensity of an area, so make sure this statistic is recorded in
the measure tool by naviagting to Analyze -> Set measurements... and checking "Mean gray value."

*/

// Remember to click on the image outside of an ROI to deselect it - when running this macro, there should be no ROI outlined on the image.




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
	IJ.renameResults("Results");
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








