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



//normalization on table
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


