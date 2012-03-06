module rmd_concurrent;
import std.concurrency;
import std.file;

// These concurrent remove functions operate by spawning multiple threads of the fileRemover
// function.
// They first send the lists of files to fileRemover and save directory names to 
// dirs[]. The files can be removed concurrently, in any order.  The directories
// can only be removed after all files have been removed, and then must be removed 
// in depth first order so that each directory is empty when it is removed.


void rmdConcurrent(in char[] pathname, int threadCount = 14){
    DirEntry de = dirEntry(pathname);
    rmdConcurrent(de, threadCount);
}
void rmdConcurrent(ref DirEntry de, int threadCount = 14){

	// need at least one thread
	if (threadCount < 1){
		threadCount = 1;
	}

	if(!de.isDir)      
		remove(de.name);    
	else    {
		// create array of threads to remove files
		string[] dirs;
		Tid[] tidf; 
		tidf.length = threadCount;

        foreach(ref thread ; tidf){
			thread = spawn(&fileRemover);
		}

		// all children, recursively depth-first
		// add directory names to dirs[]
		// send non-directory names to the tidf threads
	    int i=0;
		foreach(DirEntry e; dirEntries(de.name, SpanMode.depth, false))        {
			string nm = e.name;
            attrIsDir(e.linkAttributes) ? dirs ~= nm  : tidf[i].send(nm),i=(i+1)%threadCount;        
		} 
		
		// The tidf thread are already removing files, but now we
        // send a message to each of the tidf threads to request acknowledge of its final file deletion
		foreach (ref thread ; tidf){
			thread.send(thisTid);
			receiveOnly!Tid();
		}

		// remove the directory names, which were entered into dirs in depth first order
		foreach (ref dir; dirs){
			rmdir(dir);
		}

		// remove the root directory after all the subdirectories are gone       
		rmdir(de.name);    
	}
}

// A thread function that gets spawned multiple times
// The threads remove all regular files, plus any links, concurrently
void fileRemover() {
	for(bool running=true;running;){
		receive(
				// when we pull a pathname string from the msg queue, remove the pathname immediately
				(string pathname) {
					remove(pathname); 
				}, 
				// When we pull the Tid from the msg queue, that's the main thread signal it is the end of list.
				// Notify the main thread we're finished and exit the loop by setting running to false
				(Tid x) { 
					x.send(thisTid); 
					running=false; 
				}  
				);
	}
}
