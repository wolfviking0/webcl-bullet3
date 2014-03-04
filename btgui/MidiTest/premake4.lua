
	project "rtMidiTest"
		
	kind "ConsoleApp"
	
--	defines {  }
	
	targetdir "../../bin"
	
	includedirs 
	{
		".",
	}

			
--	links { }
	
	
	files {
		"**.cpp",
		"**.h"
	}
	if not _OPTIONS["emscripten"] then
		if os.is("Windows") then
			links {"winmm"}
			defines {"__WINDOWS_MM__", "WIN32"}
		end

		if os.is("Linux") then 
		end

		if os.is("MacOSX") then
			links{"CoreAudio.framework", "coreMIDI.framework", "Cocoa.framework"}
			defines {"__MACOSX_CORE__"}
			print ("hi!")
		end
	end
