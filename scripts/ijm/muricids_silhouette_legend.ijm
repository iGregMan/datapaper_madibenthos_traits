// Silhouette for chaincoder //

path = "/home/borea/Documents/mosceco/r_projects/morphometry_invmar/data/raw/photos/test/"
path_out = "/home/borea/Documents/mosceco/r_projects/morphometry_invmar/data/tidy/test/"
list = getFileList(path);
list = Array.sort(list);
for (i = 0; i < list.length; i++) {
	// get photo
	open(path + list[i]);
	run("Set Measurements...", "  redirect=None decimal=3");
	w = getWidth();
	h = getHeight();
	// Set scale
	setTool("line");
	waitForUser("Scale", "Set scale");
	run("Set Scale...");
	makePoint(w, h);
	// legend stick
	length_stick = getNumber("Longueur de la barre de\nlégende ?", 1);
	
	run("8-bit");
	setTool("wand");
	run("Threshold...");
	waitForUser("Silhouetto", "Adjust threshold to fill the desired shape\nand surround area of interest");
	roiManager("Add");
    close("*");
    open(path + "/" + list[i]);
    roiManager("Select", 0);
    setBackgroundColor(255, 255, 255); //for a dark background
    //setBackgroundColor(0, 0, 0); //for a clear background
    run("Clear", "slice");
    run("Crop");
    saveAs("BMP", path_out + list[i] + ".bmp");
    close("*"); close("ROI Manager");
}
