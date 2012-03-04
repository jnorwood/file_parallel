module copy_parallel;
import std.file;
import std.path;
import std.parallelism;

// Copy a source file or directory in parallel.
// Creates the destination directory if it doesn't exist.
// Throws an error if any destination files or directories exist, other than the root destDir

void copyParallel (in char[] pathname ,in char[] destDir){
    DirEntry deSrc = dirEntry(pathname);
	string[] files;

	if (!exists(destDir)){
		mkdirRecurse (destDir); // makes dest root and all required parents
	}
 	DirEntry destDe = dirEntry(destDir);
	if(!destDe.isDir()){        
		throw new FileException( destDe.name, " is not a directory"); 
	}
	string destName = destDe.name ~ '/';
	string destRoot = destName ~ baseName(deSrc.name);

	if(!deSrc.isDir()){
		copy(deSrc.name,destRoot); 
	}
	else    { 
		int srcLen = deSrc.name.length;
        mkdir(destRoot);

		// make an array of the regular files only, also create the directory structure
		// Since it is SpanMode.breadth, can just use mkdir
 		foreach(DirEntry e; dirEntries(deSrc.name, SpanMode.breadth, false)){
			if (attrIsDir(e.linkAttributes)){
				string destDir = destRoot ~ e.name[srcLen..$];
				mkdir(destDir);
			}
			else{
				files ~= e.name;
			}
 		} 

		// parallel foreach for regular files
		foreach(fn ; taskPool.parallel(files,100)) {
			string dfn = destRoot ~ fn[srcLen..$];
			copy(fn,dfn);
		}
	}
}

