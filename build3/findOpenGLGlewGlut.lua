
	function initOpenGL()
		configuration {}
		if not _OPTIONS["emscripten"] then
			configuration {"Windows"}
				links {"opengl32","glu32"}
			configuration {"MacOSX"}
	 			links { "OpenGL.framework"} 
			configuration {"not Windows", "not MacOSX"}
				links {"GL"}
		end
		configuration{}
	end

	function initGlut()
		configuration {}
		if not _OPTIONS["emscripten"] then
			if os.is("Windows") then
				configuration {"Windows"}
				includedirs {
					projectRootDir .. "btgui/OpenGLWindow/Glut"
				}
				libdirs { projectRootDir .. "btgui/OpenGLWindow/Glut"}
				configuration {"Windows", "x32"}
					links {"glut32"}
				configuration {"Windows", "x64"}
					links {"glut64"}
			end
			
			configuration {"MacOSX"}
	 			links { "Glut.framework" } 
			configuration {"Linux"}
				links {"glut","GLU"}
		end
		configuration{}
	end

	function initGlew()
		configuration {}
		if os.is("Windows") then
			configuration {"Windows"}
			defines { "GLEW_STATIC"}
			includedirs {
					projectRootDir .. "btgui/OpenGLWindow/GlewWindows"
			}
			files { projectRootDir .. "btgui/OpenGLWindow/GlewWindows/glew.c"}
		end
		if os.is("Linux") then
			links{"GLEW"}
		end
		configuration{}
	end



