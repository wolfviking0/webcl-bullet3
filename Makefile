#
#  Makefile
#
#  Created by Anthony Liot.
#  Copyright (c) 2013 Anthony Liot. All rights reserved.
#

CURRENT_ROOT:=$(PWD)/
	
ORIG=0
ifeq ($(ORIG),1)
EMSCRIPTEN_ROOT:=$(CURRENT_ROOT)../emscripten
else

$(info )
$(info )
$(info **************************************************************)
$(info **************************************************************)
$(info ************ /!\ BUILD USE SUBMODULE CARREFUL /!\ ************)
$(info **************************************************************)
$(info **************************************************************)
$(info )
$(info )

EMSCRIPTEN_ROOT:=$(CURRENT_ROOT)../webcl-translator/emscripten
endif

CXX = $(EMSCRIPTEN_ROOT)/em++

CHDIR_SHELL := $(SHELL)
define chdir
   $(eval _D=$(firstword $(1) $(@D)))
   $(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

DEB=0
VAL=0
FAST=1

ifeq ($(VAL),1)
PREFIX = val_
VALIDATOR = '[""]' # Enable validator without parameter
$(info ************  Mode VALIDATOR : Enabled ************)
else
PREFIX = 
VALIDATOR = '[]' # disable validator
$(info ************  Mode VALIDATOR : Disabled ************)
endif

DEBUG = -O0 -s CL_VALIDATOR=$(VAL) -s CL_VAL_PARAM=$(VALIDATOR) -s CL_PRINT_TRACE=1 -s DISABLE_EXCEPTION_CATCHING=0 -s WARN_ON_UNDEFINED_SYMBOLS=1 -s CL_DEBUG=1 -s CL_GRAB_TRACE=1 -s CL_CHECK_VALID_OBJECT=1

NO_DEBUG = -02 -s CL_VALIDATOR=$(VAL) -s CL_VAL_PARAM=$(VALIDATOR) -s WARN_ON_UNDEFINED_SYMBOLS=0  -s CL_DEBUG=0 -s CL_GRAB_TRACE=0 -s CL_PRINT_TRACE=0 -s CL_CHECK_VALID_OBJECT=0

ifeq ($(DEB),1)
MODE=$(DEBUG)
EMCCDEBUG = EMCC_FAST_COMPILER=$(FAST) EMCC_DEBUG
$(info ************  Mode DEBUG : Enabled ************)
else
MODE=$(NO_DEBUG)
EMCCDEBUG = EMCC_FAST_COMPILER=$(FAST) EMCCDEBUG
$(info ************  Mode DEBUG : Disabled ************)
endif

$(info )
$(info )

#----------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------#
# BUILD
#----------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------#		

KERNEL_FILES = \
	src/Bullet3OpenCL/BroadphaseCollision/kernels/sap.cl \
	src/Bullet3OpenCL/BroadphaseCollision/kernels/sapFast.cl \
  	\
	src/Bullet3OpenCL/NarrowphaseCollision/kernels/bvhTraversal.cl \
	src/Bullet3OpenCL/NarrowphaseCollision/kernels/primitiveContacts.cl \
	src/Bullet3OpenCL/NarrowphaseCollision/kernels/sat.cl \
	src/Bullet3OpenCL/NarrowphaseCollision/kernels/satClipHullContacts.cl \
	\
	src/Bullet3OpenCL/ParallelPrimitives/kernels/BoundSearchKernels.cl \
	src/Bullet3OpenCL/ParallelPrimitives/kernels/CopyKernels.cl \
	src/Bullet3OpenCL/ParallelPrimitives/kernels/FillKernels.cl \
	src/Bullet3OpenCL/ParallelPrimitives/kernels/PrefixScanFloat4Kernels.cl \
	src/Bullet3OpenCL/ParallelPrimitives/kernels/PrefixScanKernels.cl \
	src/Bullet3OpenCL/ParallelPrimitives/kernels/RadixSort32Kernels.cl \
	\
	src/Bullet3OpenCL/Raycast/kernels/rayCastKernels.cl \
	\
	src/Bullet3OpenCL/RigidBody/kernels/batchingKernels.cl \
	src/Bullet3OpenCL/RigidBody/kernels/batchingKernelsNew.cl \
	src/Bullet3OpenCL/RigidBody/kernels/integrateKernel.cl \
	src/Bullet3OpenCL/RigidBody/kernels/jointSolver.cl \
	src/Bullet3OpenCL/RigidBody/kernels/solveContact.cl \
	src/Bullet3OpenCL/RigidBody/kernels/solveFriction.cl \
	src/Bullet3OpenCL/RigidBody/kernels/solverSetup.cl \
	src/Bullet3OpenCL/RigidBody/kernels/solverSetup2.cl \
	src/Bullet3OpenCL/RigidBody/kernels/solverUtils.cl \
	src/Bullet3OpenCL/RigidBody/kernels/updateAabbsKernel.cl \
 	
		
all: BulletGui BulletGwen BulletKernels opencl demo test

opencl: Bullet3Common Bullet3Geometry Bullet3Serialize Bullet3Dynamics Bullet3Collision Bullet3OpenCL

demo: BulletGwenTest BulletGpuGuiInitialize
#BulletGpuDemos

test: BulletBasicInitialize BulletKernelLaunch BulletParallelPrimitives BulletRadixSortBenchmark BulletBitonicSort 
	
BulletGui:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		btgui/FontFiles/OpenSans.cpp \
		btgui/OpenGLTrueTypeFont/fontstash.cpp \
		btgui/OpenGLTrueTypeFont/opengl_fontstashcallbacks.cpp \
		btgui/stb_image/stb_image.cpp \
		btgui/Timing/b3Clock.cpp \
		btgui/Timing/b3Quickprof.cpp \
		btgui/OpenGLWindow/GLInstancingRenderer.cpp \
		btgui/OpenGLWindow/GLPrimitiveRenderer.cpp \
		btgui/OpenGLWindow/GLRenderToTexture.cpp \
		btgui/OpenGLWindow/LoadShader.cpp \
		btgui/OpenGLWindow/TwFonts.cpp \
		btgui/OpenGLWindow/GlutOpenGLWindow.cpp \
		-I ./btgui/ -I ./src/ $(DEBUG) -o ./js/BulletGui.o

BulletGwen:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		btgui/gwen/Anim.cpp \
		btgui/gwen/BaseRender.cpp \
		btgui/gwen/DragAndDrop.cpp \
		btgui/gwen/events.cpp \
		btgui/gwen/Gwen.cpp \
		btgui/gwen/Hook.cpp \
		btgui/gwen/inputhandler.cpp \
		btgui/gwen/Skin.cpp \
		btgui/gwen/ToolTip.cpp \
		btgui/gwen/Utility.cpp \
		btgui/gwen/Controls/Base.cpp \
		btgui/gwen/Controls/Button.cpp \
		btgui/gwen/Controls/Canvas.cpp \
		btgui/gwen/Controls/CheckBox.cpp \
		btgui/gwen/Controls/ColorControls.cpp \
		btgui/gwen/Controls/ColorPicker.cpp \
		btgui/gwen/Controls/ComboBox.cpp \
		btgui/gwen/Controls/CrossSplitter.cpp \
		btgui/gwen/Controls/DockBase.cpp \
		btgui/gwen/Controls/DockedTabControl.cpp \
		btgui/gwen/Controls/Dragger.cpp \
		btgui/gwen/Controls/GroupBox.cpp \
		btgui/gwen/Controls/HorizontalScrollBar.cpp \
		btgui/gwen/Controls/HorizontalSlider.cpp \
		btgui/gwen/Controls/HSVColorPicker.cpp \
		btgui/gwen/Controls/ImagePanel.cpp \
		btgui/gwen/Controls/Label.cpp \
		btgui/gwen/Controls/LabelClickable.cpp \
		btgui/gwen/Controls/ListBox.cpp \
		btgui/gwen/Controls/Menu.cpp \
		btgui/gwen/Controls/MenuItem.cpp \
		btgui/gwen/Controls/MenuStrip.cpp \
		btgui/gwen/Controls/NumericUpDown.cpp \
		btgui/gwen/Controls/PanelListPanel.cpp \
		btgui/gwen/Controls/ProgressBar.cpp \
		btgui/gwen/Controls/Properties.cpp \
		btgui/gwen/Controls/RadioButton.cpp \
		btgui/gwen/Controls/RadioButtonController.cpp \
		btgui/gwen/Controls/ResizableControl.cpp \
		btgui/gwen/Controls/Resizer.cpp \
		btgui/gwen/Controls/RichLabel.cpp \
		btgui/gwen/Controls/ScrollBar.cpp \
		btgui/gwen/Controls/ScrollBarBar.cpp \
		btgui/gwen/Controls/ScrollBarButton.cpp \
		btgui/gwen/Controls/ScrollControl.cpp \
		btgui/gwen/Controls/Slider.cpp \
		btgui/gwen/Controls/SplitterBar.cpp \
		btgui/gwen/Controls/TabButton.cpp \
		btgui/gwen/Controls/TabControl.cpp \
		btgui/gwen/Controls/TabStrip.cpp \
		btgui/gwen/Controls/Text.cpp \
		btgui/gwen/Controls/TextBox.cpp \
		btgui/gwen/Controls/TextBoxNumeric.cpp \
		btgui/gwen/Controls/TreeControl.cpp \
		btgui/gwen/Controls/TreeNode.cpp \
		btgui/gwen/Controls/VerticalScrollBar.cpp \
		btgui/gwen/Controls/VerticalSlider.cpp \
		btgui/gwen/Controls/WindowControl.cpp \
		btgui/gwen/Platforms/Null.cpp \
		btgui/gwen/Platforms/Windows.cpp \
		-I ./btgui/ $(DEBUG) -o ./js/BulletGwen.o		

BulletGwenTest:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		btgui/GwenOpenGLTest/Button.cpp \
		btgui/GwenOpenGLTest/Checkbox.cpp \
		btgui/GwenOpenGLTest/ComboBox.cpp \
		btgui/GwenOpenGLTest/CrossSplitter.cpp \
		btgui/GwenOpenGLTest/GroupBox.cpp \
		btgui/GwenOpenGLTest/ImagePanel.cpp \
		btgui/GwenOpenGLTest/Label.cpp \
		btgui/GwenOpenGLTest/ListBox.cpp \
		btgui/GwenOpenGLTest/MenuStrip.cpp \
		btgui/GwenOpenGLTest/Numeric.cpp \
		btgui/GwenOpenGLTest/OpenGLSample.cpp \
		btgui/GwenOpenGLTest/PanelListPanel.cpp \
		btgui/GwenOpenGLTest/ProgressBar.cpp \
		btgui/GwenOpenGLTest/Properties.cpp \
		btgui/GwenOpenGLTest/RadioButton.cpp \
		btgui/GwenOpenGLTest/ScrollControl.cpp \
		btgui/GwenOpenGLTest/Slider.cpp \
		btgui/GwenOpenGLTest/StatusBar.cpp \
		btgui/GwenOpenGLTest/TabControl.cpp \
		btgui/GwenOpenGLTest/TextBox.cpp \
		btgui/GwenOpenGLTest/TreeControl.cpp \
		btgui/GwenOpenGLTest/UnitTest.cpp \
		./js/Bullet3Common.o ./js/Bullet3Geometry.o ./js/BulletGwen.o ./js/BulletGui.o \
		-I ./btgui/ $(DEBUG) -o ./html/BulletGwenTest.html

Bullet3Common:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		src/Bullet3Common/b3AlignedAllocator.cpp \
		src/Bullet3Common/b3Vector3.cpp \
		src/Bullet3Common/b3Logging.cpp \
		$(DEBUG) -o ./js/Bullet3Common.o
		
Bullet3Geometry:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		src/Bullet3Geometry/b3ConvexHullComputer.cpp \
		src/Bullet3Geometry/b3GeometryUtil.cpp \
		-I ./src/ $(DEBUG) -o ./js/Bullet3Geometry.o		
		
Bullet3Serialize:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		src/Bullet3Serialize/Bullet2FileLoader/b3BulletFile.cpp \
		src/Bullet3Serialize/Bullet2FileLoader/b3Chunk.cpp \
		src/Bullet3Serialize/Bullet2FileLoader/b3DNA.cpp \
		src/Bullet3Serialize/Bullet2FileLoader/b3File.cpp \
		src/Bullet3Serialize/Bullet2FileLoader/b3Serializer.cpp \
		-I ./src/ $(DEBUG) -o ./js/Bullet3Serialize.o		

Bullet3Dynamics:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		src/Bullet3Dynamics/b3CpuRigidBodyPipeline.cpp \
		src/Bullet3Dynamics/ConstraintSolver/b3FixedConstraint.cpp \
		src/Bullet3Dynamics/ConstraintSolver/b3Generic6DofConstraint.cpp \
		src/Bullet3Dynamics/ConstraintSolver/b3PgsJacobiSolver.cpp \
		src/Bullet3Dynamics/ConstraintSolver/b3Point2PointConstraint.cpp \
		src/Bullet3Dynamics/ConstraintSolver/b3TypedConstraint.cpp \
		-I ./src/ $(DEBUG) -o ./js/Bullet3Dynamics.o		
		
Bullet3Collision:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		src/Bullet3Collision/BroadPhaseCollision/b3DynamicBvh.cpp \
		src/Bullet3Collision/BroadPhaseCollision/b3DynamicBvhBroadphase.cpp \
		src/Bullet3Collision/BroadPhaseCollision/b3OverlappingPairCache.cpp \
		src/Bullet3Collision/NarrowPhaseCollision/b3ConvexUtility.cpp \
		src/Bullet3Collision/NarrowPhaseCollision/b3CpuNarrowPhase.cpp \
		-I ./src/ $(DEBUG) -o ./js/Bullet3Collision.o
		
Bullet3OpenCL:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		src/Bullet3OpenCL/BroadphaseCollision/b3GpuSapBroadphase.cpp \
		src/Bullet3OpenCL/Initialize/b3OpenCLUtils.cpp \
		src/Bullet3OpenCL/NarrowphaseCollision/b3ContactCache.cpp \
		src/Bullet3OpenCL/NarrowphaseCollision/b3ConvexHullContact.cpp \
		src/Bullet3OpenCL/NarrowphaseCollision/b3GjkEpa.cpp \
		src/Bullet3OpenCL/NarrowphaseCollision/b3GjkPairDetector.cpp \
		src/Bullet3OpenCL/NarrowphaseCollision/b3OptimizedBvh.cpp \
		src/Bullet3OpenCL/NarrowphaseCollision/b3QuantizedBvh.cpp \
		src/Bullet3OpenCL/NarrowphaseCollision/b3StridingMeshInterface.cpp \
		src/Bullet3OpenCL/NarrowphaseCollision/b3TriangleCallback.cpp \
		src/Bullet3OpenCL/NarrowphaseCollision/b3TriangleIndexVertexArray.cpp \
		src/Bullet3OpenCL/NarrowphaseCollision/b3VoronoiSimplexSolver.cpp \
		src/Bullet3OpenCL/ParallelPrimitives/b3BoundSearchCL.cpp \
		src/Bullet3OpenCL/ParallelPrimitives/b3FillCL.cpp \
		src/Bullet3OpenCL/ParallelPrimitives/b3PrefixScanCL.cpp \
		src/Bullet3OpenCL/ParallelPrimitives/b3PrefixScanFloat4CL.cpp \
		src/Bullet3OpenCL/ParallelPrimitives/b3RadixSort32CL.cpp \
		src/Bullet3OpenCL/Raycast/b3GpuRaycast.cpp \
		src/Bullet3OpenCL/RigidBody/b3GpuGenericConstraint.cpp \
		src/Bullet3OpenCL/RigidBody/b3GpuJacobiContactSolver.cpp \
		src/Bullet3OpenCL/RigidBody/b3GpuNarrowPhase.cpp \
		src/Bullet3OpenCL/RigidBody/b3GpuPgsConstraintSolver.cpp \
		src/Bullet3OpenCL/RigidBody/b3GpuPgsContactSolver.cpp \
		src/Bullet3OpenCL/RigidBody/b3GpuRigidBodyPipeline.cpp \
		src/Bullet3OpenCL/RigidBody/b3Solver.cpp \
		-I ./src/ $(DEBUG) -o ./js/Bullet3OpenCL.o
	
BulletLinearMath:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		src/LinearMath/btAlignedAllocator.cpp \
		src/LinearMath/btConvexHull.cpp \
		src/LinearMath/btConvexHullComputer.cpp \
		src/LinearMath/btGeometryUtil.cpp \
		src/LinearMath/btPolarDecomposition.cpp \
		src/LinearMath/btQuickprof.cpp \
		src/LinearMath/btSerializer.cpp \
		src/LinearMath/btVector3.cpp \
		-I ./src/ $(DEBUG) -o ./js/BulletLinearMath.o
	
BulletGpuDemos:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		Demos3/GpuDemos/GpuDemo.cpp \
		Demos3/GpuDemos/gwenUserInterface.cpp \
		Demos3/GpuDemos/main_opengl3core.cpp \
		Demos3/GpuDemos/ParticleDemo.cpp \
		Demos3/GpuDemos/broadphase/PairBench.cpp \
		Demos3/GpuDemos/constraints/ConstraintsDemo.cpp \
		Demos3/GpuDemos/raytrace/RaytracedShadowDemo.cpp \
		Demos3/GpuDemos/rigidbody/Bullet2FileDemo.cpp \
		Demos3/GpuDemos/rigidbody/BulletDataExtractor.cpp \
		Demos3/GpuDemos/rigidbody/ConcaveScene.cpp \
		Demos3/GpuDemos/rigidbody/GpuCompoundScene.cpp \
		Demos3/GpuDemos/rigidbody/GpuConvexScene.cpp \
		Demos3/GpuDemos/rigidbody/GpuRigidBodyDemo.cpp \
		Demos3/GpuDemos/rigidbody/GpuSphereScene.cpp \
		Demos3/GpuDemos/shadows/ShadowMapDemo.cpp \
		Demos3/GpuDemos/softbody/GpuSoftBodyDemo.cpp \
		Demos3/Wavefront/tiny_obj_loader.cpp \
		src/clew/clew.c \
		./js/Bullet3Common.o ./js/Bullet3Serialize.o ./js/Bullet3OpenCL.o ./js/Bullet3Collision.o ./js/Bullet3Geometry.o ./js/Bullet3Dynamics.o ./js/BulletGwen.o ./js/BulletGui.o \
		-I ./btgui/ -I ./src/ $(DEBUG) -o ./html/BulletGpuDemo.html
			
BulletGpuGuiInitialize:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		Demos3/GpuGuiInitialize/main.cpp \
		src/clew/clew.c \
		./js/Bullet3Common.o ./js/Bullet3Serialize.o ./js/Bullet3OpenCL.o ./js/Bullet3Collision.o ./js/Bullet3Geometry.o ./js/Bullet3Dynamics.o ./js/BulletGwen.o ./js/BulletGui.o \
		-I ./btgui/ -I ./src/ $(DEBUG) -o ./html/BulletGpuGuiInitialize.html		
			
BulletBasicInitialize:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
	./test/OpenCL/BasicInitialize/main.cpp \
		src/clew/clew.c \
		./js/Bullet3Common.o ./js/Bullet3OpenCL.o \
		-I ./btgui/ -I ./src/ $(DEBUG) -o ./html/BulletBasicInitialize.html	
		
BulletKernelLaunch:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
	./test/OpenCL/KernelLaunch/main.cpp \
		src/clew/clew.c \
		./js/Bullet3Common.o ./js/Bullet3OpenCL.o \
		-I ./btgui/ -I ./src/ -s OPENCL_FORCE_CPU=1 $(DEBUG) -o ./html/BulletKernelLaunch.html			
	
BulletParallelPrimitives:
	$(call chdir,./)
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 ../../webcl-translator/emscripten/emcc \
		test/OpenCL/ParallelPrimitives/main.cpp \
		src/clew/clew.c \
		../js/Bullet3Common.o ../js/Bullet3OpenCL.o \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/BoundSearchKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/CopyKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/FillKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/PrefixScanFloat4Kernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/PrefixScanKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/RadixSort32Kernels.cl \
		-I ../btgui/ -I ../src/ -s OPENCL_FORCE_CPU=1 $(DEBUG) -o ../html/BulletParallelPrimitives.html
		
BulletRadixSortBenchmark:
	$(call chdir,./)
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 ../../webcl-translator/emscripten/emcc \
		test/OpenCL/RadixSortBenchmark/main.cpp \
		src/clew/clew.c \
		../js/Bullet3Common.o ../js/Bullet3OpenCL.o ../js/BulletGui.o \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/BoundSearchKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/CopyKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/FillKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/PrefixScanFloat4Kernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/PrefixScanKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/RadixSort32Kernels.cl \
		-I ../btgui/ -I ../src/ -s TOTAL_MEMORY=1024*1024*150 $(DEBUG) -o ../html/BulletRadixSortBenchmark.html	
		
BulletBitonicSort:
	$(call chdir,./)
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 ../../webcl-translator/emscripten/emcc \
		test/OpenCL/BitonicSort/b3BitonicSort.cpp \
		test/OpenCL/BitonicSort/main.cpp \
		src/clew/clew.c \
		../js/Bullet3Common.o ../js/Bullet3OpenCL.o ../js/BulletGui.o \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/BoundSearchKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/CopyKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/FillKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/PrefixScanFloat4Kernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/PrefixScanKernels.cl \
		--preload-file src/Bullet3OpenCL/ParallelPrimitives/kernels/RadixSort32Kernels.cl \
		-I ../btgui/ -I ../src/ -s TOTAL_MEMORY=1024*1024*150 $(DEBUG) -o ../html/BulletBitonicSort.html					
		
BulletKernels:
		python $(EMSCRIPTEN_ROOT)/tools/file_packager.py ./js/BulletKernels.data --preload $(KERNEL_FILES) --pre-run > ./js/BulletKernels.js

clean:
	rm -f build/$(FOLDER)/*.data
	rm -f build/$(FOLDER)/*.js
	rm -f build/$(FOLDER)/*.map
	$(CXX) --clear-cache

	
	
