// Remember to click on the image outside of an ROI to deselect it - when running this macro, there should be no ROI outlined on the image.
n = roiManager("count");

for (i = 0; i < n; i++) {
	roiManager("deselect");
	run("Duplicate...", "title=myimage duplicate frames=1");
	
	//roiManager("reset");
	
	selectWindow("myimage");
	
	/* mito masking */
	run("Duplicate...", "title=myimage-mito duplicate channels=1");
	roiManager("Select", i);
	setBackgroundColor(0, 0, 0);
	run("Clear Outside");
	
	//setMinAndMax(96, 2903);
	setAutoThreshold("Otsu dark no-reset");
	//run("Threshold...");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	selectWindow("myimage-mito");
	run("Create Selection");
	roiManager("Add"); // add selection of mitos
	
	
	/* Nuclei masking */
	selectWindow("myimage");
	
	run("Duplicate...", "title=myimage-nucleus duplicate channels=3");
	roiManager("Select", i);
	setBackgroundColor(0, 0, 0);
	run("Clear Outside");
	
	/*
	//setMinAndMax(96, 2903);
	setAutoThreshold("Otsu dark no-reset");
	//run("Threshold...");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	*/
	
	setThreshold(833, 65535, "raw");
	run("Convert to Mask", "method=Otsu background=Dark");

	selectWindow("myimage-nucleus");
	run("Create Selection");
	roiManager("Add");
	
	// end nuclei
	
	
	/* actin measuring */
	selectWindow("myimage");
	run("Duplicate...", "title=myimage-actin duplicate channels=2");
	selectWindow("myimage-actin");
	run("Subtract...", "value=100");	// the camera offset
	roiManager("Select", n); // select mito mask
	run("Measure");
	
	roiManager("Select", newArray(i,n));
	roiManager("XOR");
	roiManager("add");
	roiManager("Select", newArray(n+1,n+2)); // select nucleus and new xor
	roiManager("XOR");
	run("Measure");
	
	
	roiManager("Select", n+2);
	roiManager("delete"); // . delete first xor
	
	roiManager("Select", n+1);
	roiManager("delete"); // delete nucleus

	roiManager("Select", n);
	roiManager("delete"); // delete mito
	
	
	// cleanup
	selectWindow("myimage-mito");
	close();
	
	selectWindow("myimage-nucleus");
	close();
	
	selectWindow("myimage");
	close();
	
	selectWindow("myimage-actin");
	close();
	run("Select None");
}

//normalization on table
time = newArray(n);
for (i=0; i<n; i++) {
	time[i] = i+1;
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
norm = newArray(n);
for (i=0; i<n; i++) {
	norm[i] = mean1[i] / mean2[i];
}

Table.create("Table");
Table.setColumn("Cell", time);
Table.setColumn("Mito Mean", mean1);
Table.setColumn("Other Mean", mean2);
Table.setColumn("Normal", norm);
