module rmdir_parallel;
import std.file;
import std.parallelism;

// Removes files or directories in parallel using taskpool.
// Doesn't follow links.
// The parallel foreach removes all regular files and links.  Any order ok.
// The parallel foreach completes all tasks before exiting.
// The following non-parallel portion removes all directories, depth first.


void rmdirParallel(in char[] pathname){
    DirEntry de = dirEntry(pathname);
    rmdirParallel(de);
}


void rmdirParallel (ref DirEntry de){ 
	string[] files;
	string[] dirs;

	if(!de.isDir()){        
		remove(de.name);
	}
	else    { 

		// Make separate arrays of the regular files and dirs. 
		// Links will be included with the regular files.
		foreach(DirEntry e; dirEntries(de.name, SpanMode.depth, false)){
			if (!attrIsDir(e.linkAttributes)){
				files ~= e.name ;
			}
			else{
				// save subdirectory names, depth first
				dirs ~= e.name;
			}
 		} 

		// parallel foreach removes regular files and links
		foreach(fn; taskPool.parallel(files,100)) {
			remove(fn);
		}

		// now remove all the empty subdirectories, depth first
 		foreach(nm; dirs){
			rmdir(nm);
		}

		// finally, remove the root directory
		rmdir (de.name);
	}
}


