/*

This macro measures the intensity of actin filaments overlapping with mitochondria and not overlapping with
mitochondria in a selection over a multi-frame movie. 

Input: movie of cells with a channel for mitochondria and a channel for actin. 

Using the freehand selection tool, create ROI's that outline the cytoplasm of a cell, excluding the actin of
the cell membrane. Add as many of these ROI's as you would like. It is important to quickly check the entire movie
to make sure the cell stays in the ROI for accurate measurements.

For each ROI, the macro will threshold the mitochondria within the ROI and create a selection of these mitochondria.
Then, it will measure the actin intensity over this selection, which effectively measures the actin that overlaps
with the mitochondria. Then it will measure the actin intensity outside of the mitochondria, but still within the
initial ROI. Finally, it will load a table consisting of the mean actin intensity overlapping with and seperate from
the mitochondria, and the ratio of the two, as well as just the ADA intensity normalized to the first 4 frames.

Some notes:
After making your final ROI selection, deselect all ROI's by clicking on the image outside of the last ROI before
running the macro.

The last bit of this macro organizes all the data on a table. If you would like to add a column or calculation, this
can be done there. 

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
		
		roiManager("Select", newArray(r,n));
		roiManager("XOR");
		run("Measure");
	
		roiManager("Select", n);
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
	
	
}



/* Organization on table */
cell = newArray(n*frames); // or nResults/2
for (i=0; i<n*frames; i++) {
	cell[i] = i+1;
}

mean1 = newArray(n);
mean2 = newArray(n);
for (row=0; row<nResults; row++) {
	if (row % 2 == 0) {
		mean1[(row/2)] = (getResult("Mean", row));
	} else {
		mean2[row/2] = (getResult("Mean", row));
	}
}
//avg = (((mean2[0]+mean2[1]+mean2[2]+mean2[3])/4) - 500) / (((mean1[0]+mean1[1]+mean1[2]+mean1[3])/4) - 500);
ratio = newArray(n*frames);
for (i=0; i<n*frames; i++) {
	ratio[i] = mean1[i] / mean2[i];
}

Table.create("Table");
Table.setColumn("Cell", cell);
Table.setColumn("Mito Mean", mean1);
Table.setColumn("Other Mean", mean2);
Table.setColumn("Ratio", ratio);


norm = newArray(n*frames);

for (i=0; i<n; i++) {
		start = frames * i;
		base = (mean1[start + 0] + mean1[start + 1] + mean1[start + 2] + mean1[start + 3]) / 4;
		for (row=start; row<start+frames; row++) {
			normal = (mean1[row] - 500) / (base-500);// this is where the calculation happens
	    	norm[row] = normal;
		}	
}

Table.setColumn("Normal", norm);


