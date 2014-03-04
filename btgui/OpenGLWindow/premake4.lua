	
		project "OpenGL_Window"
	
		language "C++"
				
		kind "StaticLib"
		targetdir "../../bin"

		initOpenGL()
		initGlew()

		includedirs {
		 	"..",
		 	"../../src",
		}
		
		--links {
		--}
		
		files {
			"**.cpp",
			"**.h",
		}

		if _OPTIONS["emscripten"] then
			excludes {
				"Win32OpenGLWindow.cpp",
	      		"Win32OpenGLWindow.h",
	      		"Win32Window.cpp",
	      		"Win32Window.h",
				"X11OpenGLWindow.cpp",
				"X11OpenGLWindows.h"
			}
			files
			{
				"../OpenGLWindow/GlutOpenGLWindow.h",
				"../OpenGLWindow/GlutOpenGLWindow.cpp",
			}
		else
			if not os.is("Windows") then 
				excludes {  
					"Win32OpenGLWindow.cpp",
	      	"Win32OpenGLWindow.h",
	      	"Win32Window.cpp",
	      	"Win32Window.h",
				}
			end
			if not os.is("Linux") then
				excludes {
					"X11OpenGLWindow.cpp",
					"X11OpenGLWindows.h"
				}
			end
			if os.is("MacOSX") then
				files
				{
						"../OpenGLWindow/MacOpenGLWindow.h",
						"../OpenGLWindow/MacOpenGLWindow.mm",
				} 
			end
		end

