	
		project "App_SimpleOpenGL3"

		language "C++"
				
		kind "ConsoleApp"
		targetdir "../../bin"

  	includedirs {
                ".",
                "../../src",
                "../../btgui"
                }

		initOpenGL()
		initGlew()
			
		links{"gwen", "OpenGL_Window","OpenGL_TrueTypeFont"}
		
		files {
		"**.cpp",
		"**.h",
		"../../src/Bullet3Common/**.cpp",
 		"../../src/Bullet3Common/**.h",
		"../../btgui/Timing/b3Clock.cpp",
		"../../btgui/Timing/b3Clock.h"

		}
<<<<<<< HEAD
		if not _OPTIONS["emscripten"] then
			if os.is("Linux") then links {"X11"} end
			if os.is("MacOSX") then links{"Cocoa.framework"} end
		end	
=======
		
if os.is("Linux") then links {"X11","pthread"} end

if os.is("MacOSX") then
	links{"Cocoa.framework"}
end
>>>>>>> upstream/master
