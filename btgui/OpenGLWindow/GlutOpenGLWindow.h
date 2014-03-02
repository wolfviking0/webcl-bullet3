#ifndef GLUT_OPENGL_WINDOW_H
#define GLUT_OPENGL_WINDOW_H

#define b3gDefaultOpenGLWindow GlutOpenGLWindow

#include "b3gWindowInterface.h"

class GlutOpenGLWindow : public b3gWindowInterface
{

    bool m_OpenGLInitialized;
	bool m_requestedExit;

protected:

        void enableOpenGL();

        void disableOpenGL();

        void pumpMessage();

        int getAsciiCodeFromVirtualKeycode(int orgCode);

public:

        GlutOpenGLWindow();

        virtual ~GlutOpenGLWindow();

        virtual void    createWindow(const b3gWindowConstructionInfo& ci);

        virtual void    closeWindow();

        virtual void    startRendering();

        virtual void    renderAllObjects();

        virtual void    endRendering();

        virtual float 	getRetinaScale() const {return 1.f;}

		virtual void    runMainLoop();
        virtual float   getTimeInSeconds();

        virtual bool    requestedExit() const;
        virtual void    setRequestExit() ;

        virtual void setMouseMoveCallback(b3MouseMoveCallback   mouseCallback);
        virtual void setMouseButtonCallback(b3MouseButtonCallback       mouseCallback);
        virtual void setResizeCallback(b3ResizeCallback resizeCallback);
        virtual void setWheelCallback(b3WheelCallback wheelCallback);
        virtual void setKeyboardCallback( b3KeyboardCallback    keyboardCallback);
        virtual b3KeyboardCallback      getKeyboardCallback();

        virtual void setRenderCallback( b3RenderCallback renderCallback);

        virtual void setWindowTitle(const char* title);

};


#endif

