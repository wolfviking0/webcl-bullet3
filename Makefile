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
	demo/src/Bullet3OpenCL/BroadphaseCollision/kernels/sap.cl \
	demo/src/Bullet3OpenCL/BroadphaseCollision/kernels/sapFast.cl \
  	\
	demo/src/Bullet3OpenCL/NarrowphaseCollision/kernels/bvhTraversal.cl \
	demo/src/Bullet3OpenCL/NarrowphaseCollision/kernels/primitiveContacts.cl \
	demo/src/Bullet3OpenCL/NarrowphaseCollision/kernels/sat.cl \
	demo/src/Bullet3OpenCL/NarrowphaseCollision/kernels/satClipHullContacts.cl \
	\
	demo/src/Bullet3OpenCL/ParallelPrimitives/kernels/BoundSearchKernels.cl \
	demo/src/Bullet3OpenCL/ParallelPrimitives/kernels/CopyKernels.cl \
	demo/src/Bullet3OpenCL/ParallelPrimitives/kernels/FillKernels.cl \
	demo/src/Bullet3OpenCL/ParallelPrimitives/kernels/PrefixScanFloat4Kernels.cl \
	demo/src/Bullet3OpenCL/ParallelPrimitives/kernels/PrefixScanKernels.cl \
	demo/src/Bullet3OpenCL/ParallelPrimitives/kernels/RadixSort32Kernels.cl \
	\
	demo/src/Bullet3OpenCL/Raycast/kernels/rayCastKernels.cl \
	\
	demo/src/Bullet3OpenCL/RigidBody/kernels/batchingKernels.cl \
	demo/src/Bullet3OpenCL/RigidBody/kernels/batchingKernelsNew.cl \
	demo/src/Bullet3OpenCL/RigidBody/kernels/integrateKernel.cl \
	demo/src/Bullet3OpenCL/RigidBody/kernels/jointSolver.cl \
	demo/src/Bullet3OpenCL/RigidBody/kernels/solveContact.cl \
	demo/src/Bullet3OpenCL/RigidBody/kernels/solveFriction.cl \
	demo/src/Bullet3OpenCL/RigidBody/kernels/solverSetup.cl \
	demo/src/Bullet3OpenCL/RigidBody/kernels/solverSetup2.cl \
	demo/src/Bullet3OpenCL/RigidBody/kernels/solverUtils.cl \
	demo/src/Bullet3OpenCL/RigidBody/kernels/updateAabbsKernel.cl \
 	
		
all: BulletGui BulletGwen BulletKernels opencl demo test

opencl: Bullet3Common Bullet3Geometry Bullet3Serialize Bullet3Dynamics Bullet3Collision Bullet3OpenCL

demo: BulletGwenTest BulletGpuGuiInitialize
#BulletGpuDemos

test: BulletBasicInitialize BulletKernelLaunch BulletParallelPrimitives BulletRadixSortBenchmark BulletBitonicSort 
	
BulletGui:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/btgui/FontFiles/OpenSans.cpp \
		demo/btgui/OpenGLTrueTypeFont/fontstash.cpp \
		demo/btgui/OpenGLTrueTypeFont/opengl_fontstashcallbacks.cpp \
		demo/btgui/stb_image/stb_image.cpp \
		demo/btgui/Timing/b3Clock.cpp \
		demo/btgui/Timing/b3Quickprof.cpp \
		demo/btgui/OpenGLWindow/GLInstancingRenderer.cpp \
		demo/btgui/OpenGLWindow/GLPrimitiveRenderer.cpp \
		demo/btgui/OpenGLWindow/GLRenderToTexture.cpp \
		demo/btgui/OpenGLWindow/GLUTOpenGLWindow.cpp \
		demo/btgui/OpenGLWindow/LoadShader.cpp \
		demo/btgui/OpenGLWindow/TwFonts.cpp \
		-I ./demo/btgui/ -I ./demo/src/ $(DEBUG) -o ./js/BulletGui.o	

BulletGwen:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/btgui/gwen/Anim.cpp \
		demo/btgui/gwen/BaseRender.cpp \
		demo/btgui/gwen/DragAndDrop.cpp \
		demo/btgui/gwen/events.cpp \
		demo/btgui/gwen/Gwen.cpp \
		demo/btgui/gwen/Hook.cpp \
		demo/btgui/gwen/inputhandler.cpp \
		demo/btgui/gwen/Skin.cpp \
		demo/btgui/gwen/ToolTip.cpp \
		demo/btgui/gwen/Utility.cpp \
		demo/btgui/gwen/Controls/Base.cpp \
		demo/btgui/gwen/Controls/Button.cpp \
		demo/btgui/gwen/Controls/Canvas.cpp \
		demo/btgui/gwen/Controls/CheckBox.cpp \
		demo/btgui/gwen/Controls/ColorControls.cpp \
		demo/btgui/gwen/Controls/ColorPicker.cpp \
		demo/btgui/gwen/Controls/ComboBox.cpp \
		demo/btgui/gwen/Controls/CrossSplitter.cpp \
		demo/btgui/gwen/Controls/DockBase.cpp \
		demo/btgui/gwen/Controls/DockedTabControl.cpp \
		demo/btgui/gwen/Controls/Dragger.cpp \
		demo/btgui/gwen/Controls/GroupBox.cpp \
		demo/btgui/gwen/Controls/HorizontalScrollBar.cpp \
		demo/btgui/gwen/Controls/HorizontalSlider.cpp \
		demo/btgui/gwen/Controls/HSVColorPicker.cpp \
		demo/btgui/gwen/Controls/ImagePanel.cpp \
		demo/btgui/gwen/Controls/Label.cpp \
		demo/btgui/gwen/Controls/LabelClickable.cpp \
		demo/btgui/gwen/Controls/ListBox.cpp \
		demo/btgui/gwen/Controls/Menu.cpp \
		demo/btgui/gwen/Controls/MenuItem.cpp \
		demo/btgui/gwen/Controls/MenuStrip.cpp \
		demo/btgui/gwen/Controls/NumericUpDown.cpp \
		demo/btgui/gwen/Controls/PanelListPanel.cpp \
		demo/btgui/gwen/Controls/ProgressBar.cpp \
		demo/btgui/gwen/Controls/Properties.cpp \
		demo/btgui/gwen/Controls/RadioButton.cpp \
		demo/btgui/gwen/Controls/RadioButtonController.cpp \
		demo/btgui/gwen/Controls/ResizableControl.cpp \
		demo/btgui/gwen/Controls/Resizer.cpp \
		demo/btgui/gwen/Controls/RichLabel.cpp \
		demo/btgui/gwen/Controls/ScrollBar.cpp \
		demo/btgui/gwen/Controls/ScrollBarBar.cpp \
		demo/btgui/gwen/Controls/ScrollBarButton.cpp \
		demo/btgui/gwen/Controls/ScrollControl.cpp \
		demo/btgui/gwen/Controls/Slider.cpp \
		demo/btgui/gwen/Controls/SplitterBar.cpp \
		demo/btgui/gwen/Controls/TabButton.cpp \
		demo/btgui/gwen/Controls/TabControl.cpp \
		demo/btgui/gwen/Controls/TabStrip.cpp \
		demo/btgui/gwen/Controls/Text.cpp \
		demo/btgui/gwen/Controls/TextBox.cpp \
		demo/btgui/gwen/Controls/TextBoxNumeric.cpp \
		demo/btgui/gwen/Controls/TreeControl.cpp \
		demo/btgui/gwen/Controls/TreeNode.cpp \
		demo/btgui/gwen/Controls/VerticalScrollBar.cpp \
		demo/btgui/gwen/Controls/VerticalSlider.cpp \
		demo/btgui/gwen/Controls/WindowControl.cpp \
		demo/btgui/gwen/Platforms/Null.cpp \
		demo/btgui/gwen/Platforms/Windows.cpp \
		-I ./demo/btgui/ $(DEBUG) -o ./js/BulletGwen.o		

BulletGwenTest:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/btgui/GwenOpenGLTest/Button.cpp \
		demo/btgui/GwenOpenGLTest/Checkbox.cpp \
		demo/btgui/GwenOpenGLTest/ComboBox.cpp \
		demo/btgui/GwenOpenGLTest/CrossSplitter.cpp \
		demo/btgui/GwenOpenGLTest/GroupBox.cpp \
		demo/btgui/GwenOpenGLTest/ImagePanel.cpp \
		demo/btgui/GwenOpenGLTest/Label.cpp \
		demo/btgui/GwenOpenGLTest/ListBox.cpp \
		demo/btgui/GwenOpenGLTest/MenuStrip.cpp \
		demo/btgui/GwenOpenGLTest/Numeric.cpp \
		demo/btgui/GwenOpenGLTest/OpenGLSample.cpp \
		demo/btgui/GwenOpenGLTest/PanelListPanel.cpp \
		demo/btgui/GwenOpenGLTest/ProgressBar.cpp \
		demo/btgui/GwenOpenGLTest/Properties.cpp \
		demo/btgui/GwenOpenGLTest/RadioButton.cpp \
		demo/btgui/GwenOpenGLTest/ScrollControl.cpp \
		demo/btgui/GwenOpenGLTest/Slider.cpp \
		demo/btgui/GwenOpenGLTest/StatusBar.cpp \
		demo/btgui/GwenOpenGLTest/TabControl.cpp \
		demo/btgui/GwenOpenGLTest/TextBox.cpp \
		demo/btgui/GwenOpenGLTest/TreeControl.cpp \
		demo/btgui/GwenOpenGLTest/UnitTest.cpp \
		./js/Bullet3Common.o ./js/Bullet3Geometry.o ./js/BulletGwen.o ./js/BulletGui.o \
		-I ./demo/btgui/ $(DEBUG) -o ./html/BulletGwenTest.html

Bullet3Common:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/src/Bullet3Common/b3AlignedAllocator.cpp \
		demo/src/Bullet3Common/b3Vector3.cpp \
		demo/src/Bullet3Common/b3Logging.cpp \
		$(DEBUG) -o ./js/Bullet3Common.o
		
Bullet3Geometry:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/src/Bullet3Geometry/b3ConvexHullComputer.cpp \
		demo/src/Bullet3Geometry/b3GeometryUtil.cpp \
		-I ./demo/src/ $(DEBUG) -o ./js/Bullet3Geometry.o		
		
Bullet3Serialize:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/src/Bullet3Serialize/Bullet2FileLoader/b3BulletFile.cpp \
		demo/src/Bullet3Serialize/Bullet2FileLoader/b3Chunk.cpp \
		demo/src/Bullet3Serialize/Bullet2FileLoader/b3DNA.cpp \
		demo/src/Bullet3Serialize/Bullet2FileLoader/b3File.cpp \
		demo/src/Bullet3Serialize/Bullet2FileLoader/b3Serializer.cpp \
		-I ./demo/src/ $(DEBUG) -o ./js/Bullet3Serialize.o		

Bullet3Dynamics:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/src/Bullet3Dynamics/b3CpuRigidBodyPipeline.cpp \
		demo/src/Bullet3Dynamics/ConstraintSolver/b3FixedConstraint.cpp \
		demo/src/Bullet3Dynamics/ConstraintSolver/b3Generic6DofConstraint.cpp \
		demo/src/Bullet3Dynamics/ConstraintSolver/b3PgsJacobiSolver.cpp \
		demo/src/Bullet3Dynamics/ConstraintSolver/b3Point2PointConstraint.cpp \
		demo/src/Bullet3Dynamics/ConstraintSolver/b3TypedConstraint.cpp \
		-I ./demo/src/ $(DEBUG) -o ./js/Bullet3Dynamics.o		
		
Bullet3Collision:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/src/Bullet3Collision/BroadPhaseCollision/b3DynamicBvh.cpp \
		demo/src/Bullet3Collision/BroadPhaseCollision/b3DynamicBvhBroadphase.cpp \
		demo/src/Bullet3Collision/BroadPhaseCollision/b3OverlappingPairCache.cpp \
		demo/src/Bullet3Collision/NarrowPhaseCollision/b3ConvexUtility.cpp \
		demo/src/Bullet3Collision/NarrowPhaseCollision/b3CpuNarrowPhase.cpp \
		-I ./demo/src/ $(DEBUG) -o ./js/Bullet3Collision.o
		
Bullet3OpenCL:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/src/Bullet3OpenCL/BroadphaseCollision/b3GpuSapBroadphase.cpp \
		demo/src/Bullet3OpenCL/Initialize/b3OpenCLUtils.cpp \
		demo/src/Bullet3OpenCL/NarrowphaseCollision/b3ContactCache.cpp \
		demo/src/Bullet3OpenCL/NarrowphaseCollision/b3ConvexHullContact.cpp \
		demo/src/Bullet3OpenCL/NarrowphaseCollision/b3GjkEpa.cpp \
		demo/src/Bullet3OpenCL/NarrowphaseCollision/b3GjkPairDetector.cpp \
		demo/src/Bullet3OpenCL/NarrowphaseCollision/b3OptimizedBvh.cpp \
		demo/src/Bullet3OpenCL/NarrowphaseCollision/b3QuantizedBvh.cpp \
		demo/src/Bullet3OpenCL/NarrowphaseCollision/b3StridingMeshInterface.cpp \
		demo/src/Bullet3OpenCL/NarrowphaseCollision/b3TriangleCallback.cpp \
		demo/src/Bullet3OpenCL/NarrowphaseCollision/b3TriangleIndexVertexArray.cpp \
		demo/src/Bullet3OpenCL/NarrowphaseCollision/b3VoronoiSimplexSolver.cpp \
		demo/src/Bullet3OpenCL/ParallelPrimitives/b3BoundSearchCL.cpp \
		demo/src/Bullet3OpenCL/ParallelPrimitives/b3FillCL.cpp \
		demo/src/Bullet3OpenCL/ParallelPrimitives/b3PrefixScanCL.cpp \
		demo/src/Bullet3OpenCL/ParallelPrimitives/b3PrefixScanFloat4CL.cpp \
		demo/src/Bullet3OpenCL/ParallelPrimitives/b3RadixSort32CL.cpp \
		demo/src/Bullet3OpenCL/Raycast/b3GpuRaycast.cpp \
		demo/src/Bullet3OpenCL/RigidBody/b3GpuBatchingPgsSolver.cpp \
		demo/src/Bullet3OpenCL/RigidBody/b3GpuGenericConstraint.cpp \
		demo/src/Bullet3OpenCL/RigidBody/b3GpuNarrowPhase.cpp \
		demo/src/Bullet3OpenCL/RigidBody/b3GpuPgsJacobiSolver.cpp \
		demo/src/Bullet3OpenCL/RigidBody/b3GpuRigidBodyPipeline.cpp \
		demo/src/Bullet3OpenCL/RigidBody/b3Solver.cpp \
		-I ./demo/src/ $(DEBUG) -o ./js/Bullet3OpenCL.o
	
BulletLinearMath:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/src/LinearMath/btAlignedAllocator.cpp \
		demo/src/LinearMath/btConvexHull.cpp \
		demo/src/LinearMath/btConvexHullComputer.cpp \
		demo/src/LinearMath/btGeometryUtil.cpp \
		demo/src/LinearMath/btPolarDecomposition.cpp \
		demo/src/LinearMath/btQuickprof.cpp \
		demo/src/LinearMath/btSerializer.cpp \
		demo/src/LinearMath/btVector3.cpp \
		-I ./demo/src/ $(DEBUG) -o ./js/BulletLinearMath.o
	
BulletGpuDemos:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/Demos3/GpuDemos/GpuDemo.cpp \
		demo/Demos3/GpuDemos/gwenUserInterface.cpp \
		demo/Demos3/GpuDemos/main_opengl3core.cpp \
		demo/Demos3/GpuDemos/ParticleDemo.cpp \
		demo/Demos3/GpuDemos/broadphase/PairBench.cpp \
		demo/Demos3/GpuDemos/constraints/ConstraintsDemo.cpp \
		demo/Demos3/GpuDemos/raytrace/RaytracedShadowDemo.cpp \
		demo/Demos3/GpuDemos/rigidbody/Bullet2FileDemo.cpp \
		demo/Demos3/GpuDemos/rigidbody/BulletDataExtractor.cpp \
		demo/Demos3/GpuDemos/rigidbody/ConcaveScene.cpp \
		demo/Demos3/GpuDemos/rigidbody/GpuCompoundScene.cpp \
		demo/Demos3/GpuDemos/rigidbody/GpuConvexScene.cpp \
		demo/Demos3/GpuDemos/rigidbody/GpuRigidBodyDemo.cpp \
		demo/Demos3/GpuDemos/rigidbody/GpuSphereScene.cpp \
		demo/Demos3/GpuDemos/shadows/ShadowMapDemo.cpp \
		demo/Demos3/GpuDemos/softbody/GpuSoftBodyDemo.cpp \
		demo/Demos3/Wavefront/tiny_obj_loader.cpp \
		demo/src/clew/clew.c \
		./js/Bullet3Common.o ./js/Bullet3Serialize.o ./js/Bullet3OpenCL.o ./js/Bullet3Collision.o ./js/Bullet3Geometry.o ./js/Bullet3Dynamics.o ./js/BulletGwen.o ./js/BulletGui.o \
		-I ./demo/btgui/ -I ./demo/src/ $(DEBUG) -o ./html/BulletGpuDemo.html
			
BulletGpuGuiInitialize:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/Demos3/GpuGuiInitialize/main.cpp \
		demo/src/clew/clew.c \
		./js/Bullet3Common.o ./js/Bullet3Serialize.o ./js/Bullet3OpenCL.o ./js/Bullet3Collision.o ./js/Bullet3Geometry.o ./js/Bullet3Dynamics.o ./js/BulletGwen.o ./js/BulletGui.o \
		-I ./demo/btgui/ -I ./demo/src/ $(DEBUG) -o ./html/BulletGpuGuiInitialize.html		
			
BulletBasicInitialize:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/test/OpenCL/BasicInitialize/main.cpp \
		demo/src/clew/clew.c \
		./js/Bullet3Common.o ./js/Bullet3OpenCL.o \
		-I ./demo/btgui/ -I ./demo/src/ $(DEBUG) -o ./html/BulletBasicInitialize.html	
		
BulletKernelLaunch:
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) \
		demo/test/OpenCL/KernelLaunch/main.cpp \
		demo/src/clew/clew.c \
		./js/Bullet3Common.o ./js/Bullet3OpenCL.o \
		-I ./demo/btgui/ -I ./demo/src/ -s OPENCL_FORCE_CPU=1 $(DEBUG) -o ./html/BulletKernelLaunch.html			
	
BulletParallelPrimitives:
	$(call chdir,demo/)
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
		-I ../demo/btgui/ -I ../demo/src/ -s OPENCL_FORCE_CPU=1 $(DEBUG) -o ../html/BulletParallelPrimitives.html
		
BulletRadixSortBenchmark:
	$(call chdir,demo/)
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
		-I ../demo/btgui/ -I ../demo/src/ -s TOTAL_MEMORY=1024*1024*150 $(DEBUG) -o ../html/BulletRadixSortBenchmark.html	
		
BulletBitonicSort:
	$(call chdir,demo/)
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
		-I ../demo/btgui/ -I ../demo/src/ -s TOTAL_MEMORY=1024*1024*150 $(DEBUG) -o ../html/BulletBitonicSort.html					
		
BulletKernels:
		python $(EMSCRIPTEN)/tools/file_packager.py ./js/BulletKernels.data --preload $(KERNEL_FILES) --pre-run > ./js/BulletKernels.js

clean:
	rm -f build/$(FOLDER)/*.data
	rm -f build/$(FOLDER)/*.js
	rm -f build/$(FOLDER)/*.map
	$(CXX) --clear-cache

	
	
