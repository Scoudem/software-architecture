module Volume2

import IO;
import Util;
import List;
import lang::java::jdt::m3::Core;

int rankVolumeForProject(loc project)
{
	lines = linesOfCodeFromProject(project);
	return rankVolumeByLines(size(lines));
}

int rankVolumeByLines(int linesOfCode)
{
	return rankThresholds(linesOfCode / 1000, [66, 246, 665, 1310]);
}

list[str] linesOfCodeFromProject(loc project)
{
	projectFiles = srcFiles(project);
	
	return concat([linesOfCodeFromFile(file) | file <- projectFiles]);
}

list[str] linesOfCodeFromFile(loc file)
{
	model = createM3FromString(file, readFile(file));
	
	documentation = sort([doc | <_, doc> <- model.documentation], locLessThan);
	
	lines = readFileLines(file);
	
	for (entry <- reverse(documentation))
	{
		beginLineIndex = entry.begin.line - 1;
		endLineIndex   = entry.end.line - 1;
	
		if (beginLineIndex == endLineIndex)
		{						
			line = lines[beginLineIndex];
			
			line = removeDocumentationFromLine(line, entry);
			
			lines[beginLineIndex] = line;		
		}
		else {	
			beginLine = lines[beginLineIndex];
			beginLine = beginLine[.. entry.begin.column];
			lines[beginLineIndex] = beginLine;
			
			endLine = lines[endLineIndex];
			endLine = endLine[entry.end.column ..];
			lines[endLineIndex] = endLine;
			
			for (i <- [beginLineIndex + 1 .. endLineIndex])
			{
				lines[i] = "";
			}
		}
	}
	
	return dropEmptyLines(lines);
}

str removeDocumentationFromLine(str line, loc entry)
{	
	str left  = line[.. entry.begin.column];
	str right = line[entry.end.column ..];
	
	return left + right;
}

list[str] dropEmptyLines(list[str] lines) 
{
	return [line | line <- lines, !isEmptyLine(line)];
}

bool isEmptyLine(str line)
{
	return /^\s*$/ := line;
}

bool locLessThan(loc left, loc right)
{	
	return left.offset < right.offset;
}