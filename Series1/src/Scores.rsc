module Scores

import List;
import IO;
import util::Math;
import Volume;
import UnitSize;
import UnitComplexity;
import Duplication;
import Util;

void ppScores(loc prj)
{
	println("Maintainability: " + rank(maintainability(prj)));
	println("Analysability:   " + rank(analysability(prj)));
	println("Changeability:   " + rank(changeability(prj)));
	println("Testability:     " + rank(testability(prj)));
	println("Code lines:      " + toString(nCodeLines(prj)));
	println("Unit complexity: " + rank(rankUnitComplexity(prj)));
	println("Unit size:       " + rank(rankUnitSize(prj)));
	println("Duplication:     " + "Implementation is too slow"); //rank(rankDuplication(prj)));
}

int maintainability(loc prj) = average([
	analysability(prj),
	changeability(prj),
	testability(prj)]);

int analysability(loc prj) = average([
	rankVolume(prj),
	//rankDuplication(prj),
	rankUnitSize(prj)]);

int changeability(loc prj) = average([
	rankUnitComplexity(prj)]);
	//rankDuplication(prj)]);

int testability(loc prj) = average([
	rankUnitComplexity(prj),
	rankUnitSize(prj)]);

int average(list[int] xs) = toInt(round(toReal(sum(xs)) / size(xs)));