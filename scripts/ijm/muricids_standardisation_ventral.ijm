// quantitative measures

// path
input = "/home/borea/Documents/mosceco/r_projects/morphometry_invmar/data/raw/standardisation_Siratus_michelae/ventral/"
output = "/home/borea/Documents/mosceco/r_projects/morphometry_invmar/data/tidy/standardisation_Siratus_michelae/ventral_measures/"
list = getFileList(input);
sp = "Siratus_michelae"

for (i = 0; i < list.length; i++){
	open(input + "/" + list[i]);
	run("Set Measurements...", "  redirect=None decimal=3");
	w = getWidth();
	h = getHeight();
	// Scale
	setTool("line");
waitForUser("Scale", "Set scale");
run("Set Scale...");
makePoint(w, h);

// Lengths: 
// H : Teleoconch length
setTool("line");
waitForUser("H", "Measure Teleoconch length");
run("Measure");
H = getResult("Length");
close("Results");
makePoint(w, h);

// D : Teleoconch diameter
setTool("line");
waitForUser("D", "Measure Teleoconch diameter");
run("Measure");
D = getResult("Length");
close("Results");
makePoint(w, h);

// HLW : Body Whorl length
setTool("line");
waitForUser("HLW", "Measure Body Whorl length");
run("Measure");
HLW = getResult("Length");
close("Results");
makePoint(w, h);

// HAS : Aperture length (including siphonal canal)
setTool("polyline");
waitForUser("HAS", "Measure Aperture and SC length");
run("Measure");
HAS = getResult("Length");
close("Results");
makePoint(w, h);

// HS : Siphonal Canal length
setTool("polyline");
waitForUser("HS", "Measure Siphonal Canal length");
run("Measure");
HS = getResult("Length");
close("Results");
makePoint(w, h);

// WA : Aperture width
setTool("line");
waitForUser("WA", "Measure Aperture width");
run("Measure");
WA = getResult("Length");
close("Results");
makePoint(w, h);

// HA : Aperture length
HA = HAS - HS;

// Angles:
// AA : Apical Angle
setTool("angle");
waitForUser("AA", "Measure Apical angle");
run("Measure");
AA = getResult("Angle");
close("Results");
makePoint(w, h);

// AAS : Apical Angle with Spines
setTool("angle");
waitForUser("AAS", "Measure Apical angle with spines");
run("Measure");
AAS = getResult("Angle");
close("Results");
makePoint(w, h);

// final table
setResult("sp", 0, sp);
setResult("sp", 1, sp);
setResult("sp", 2, sp);
setResult("sp", 3, sp);
setResult("sp", 4, sp);
setResult("sp", 5, sp);
setResult("sp", 6, sp);
setResult("sp", 7, sp);
setResult("sp", 8, sp);

setResult("measure", 0, "H");
setResult("measure", 1, "D");
setResult("measure", 2, "HLW");
setResult("measure", 3, "HAS");
setResult("measure", 4, "HS");
setResult("measure", 5, "WA");
setResult("measure", 6, "HA");
setResult("measure", 7, "AA");
setResult("measure", 8, "AAS");

setResult("value", 0, H);
setResult("value", 1, D);
setResult("value", 2, HLW);
setResult("value", 3, HAS);
setResult("value", 4, HS);
setResult("value", 5, WA);
setResult("value", 6, HA);
setResult("value", 7, AA);
setResult("value", 8, AAS);

updateResults();
selectWindow("Results");
saveAs("Results", output + "/" + list[i] + ".csv");
close("*"); close("Results");
}
