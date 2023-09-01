// quantitative measures: lateral angle

// path
input = "/home/borea/Documents/mosceco/r_projects/morphometry_invmar/data/raw/standardisation_Siratus_michelae/lateral/"
output = "/home/borea/Documents/mosceco/r_projects/morphometry_invmar/data/tidy/standardisation_Siratus_michelae/lateral_measures/"
sp = "Siratus_michelae";
list = getFileList(input);

for (i = 0; i < list.length; i++){
	open(input + "/" + list[i]);
	run("Set Measurements...", "  redirect=None decimal=3");
	w = getWidth();
	h = getHeight();
	// Scale
	setTool("line");

// Siphonal Canal Curvature (Angle) :
setTool("angle");
waitForUser("SCC", "Measure Siphonal Canal Curvature\n(Angle)");
run("Measure");
SCC = getResult("Angle");
SCC = 180 - SCC;
close("Results");

// final table
setResult("sp", 0, sp);
setResult("measure", 0, "SCC");
setResult("value", 0, SCC);

updateResults();
selectWindow("Results");
saveAs("Results", output + "/" + list[i] + ".csv");
close("*"); close("Results");
}
