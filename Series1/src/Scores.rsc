module Scores

import List;
import util::Math;
import Volume;
import UnitSize;
import UnitComplexity;
import Duplication;

int maintainability(loc prj) = average([
	analysability(prj),
	changeability(prj),
	testability(prj)]);

int analysability(loc prj) = average([
	rankVolume(prj),
	rankDuplication(prj),
	rankUnitSize(prj)]);

int changeability(loc prj) = average([
	rankUnitComplexity(prj),
	rankDuplication(prj)]);

int testability(loc prj) = average([
	rankUnitComplexity(prj),
	rankUnitSize(prj)]);

int average(list[int] xs) = toInt(round(toReal(sum(xs)) / size(xs)));