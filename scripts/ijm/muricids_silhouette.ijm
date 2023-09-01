// Silhouette for chaincoder //

path = "/home/borea/Documents/mosceco/datapaper/morphometry_invmar/data/raw/standardisation_Siratus_michelae/apical/"
path_out = "/home/borea/Documents/mosceco/datapaper/morphometry_invmar/data/tidy/standardisation_Siratus_michelae/apical_silhouette/"
//path = "/home/borea/Documents/mosceco/datapaper/morphometry_invmar/data/raw/standardisation_Siratus_michelae/ventral/"
//path_out = "/home/borea/Documents/mosceco/datapaper/morphometry_invmar/data/tidy/standardisation_Siratus_michelae/ventral_silhouette/"
list = getFileList(path);
list = Array.sort(list);
for (i = 0; i < list.length; i++) {
	open(path + list[i]);
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
