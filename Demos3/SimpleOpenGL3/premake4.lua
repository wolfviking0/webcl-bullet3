	
		project "App_SimpleOpenGL3"

		language "C++"
				
		kind "ConsoleApp"

  	includedirs {
                ".",
                "../../src",
                "../../btgui"
                }

			
		links{ "OpenGL_Window","Bullet3Common"}
		initOpenGL()	
		initGlew()
	
		files {
		"*.cpp",
		"*.h",
		}
<<<<<<< HEAD
		if not _OPTIONS["emscripten"] then
			if os.is("Linux") then links {"X11"} end
			if os.is("MacOSX") then links{"Cocoa.framework"} end
		end	
=======
		
if os.is("Linux") then initX11() end

if os.is("MacOSX") then
	links{"Cocoa.framework"}
end
>>>>>>> upstream/master
