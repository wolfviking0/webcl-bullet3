#include "GlutOpenGLWindow.h"
#include "OpenGLInclude.h"

#include <stdio.h>
#include <stdlib.h>

GlutOpenGLWindow::GlutOpenGLWindow()
:m_OpenGLInitialized(false),
m_requestedExit(false)
{

}

GlutOpenGLWindow::~GlutOpenGLWindow()
{
    if (m_OpenGLInitialized)
    {
        disableOpenGL();
    }
}



void GlutOpenGLWindow::enableOpenGL()
{

}

void GlutOpenGLWindow::disableOpenGL()
{

}

void GlutOpenGLWindow::createWindow(const b3gWindowConstructionInfo& ci)
{
    enableOpenGL();
}

void GlutOpenGLWindow::closeWindow()
{
    disableOpenGL();
}

int GlutOpenGLWindow::getAsciiCodeFromVirtualKeycode(int keycode)
{
    return 0;
}

void GlutOpenGLWindow::startRendering()
{

}

void GlutOpenGLWindow::renderAllObjects()
{

}

void GlutOpenGLWindow::endRendering()
{

}

void GlutOpenGLWindow::runMainLoop()
{

}

float GlutOpenGLWindow::getTimeInSeconds()
{
    return 0.f;
}

bool GlutOpenGLWindow::requestedExit() const
{
    return m_requestedExit;
}

void GlutOpenGLWindow::setRequestExit()
{
	m_requestedExit=true;
}

void GlutOpenGLWindow::setRenderCallback( b3RenderCallback renderCallback)
{

}

void GlutOpenGLWindow::setWindowTitle(const char* title)
{

}


void GlutOpenGLWindow::setWheelCallback(b3WheelCallback wheelCallback)
{

}

void GlutOpenGLWindow::setMouseMoveCallback(b3MouseMoveCallback	mouseCallback)
{

}

void GlutOpenGLWindow::setMouseButtonCallback(b3MouseButtonCallback	mouseCallback)
{

}

void GlutOpenGLWindow::setResizeCallback(b3ResizeCallback	resizeCallback)
{

}

void GlutOpenGLWindow::setKeyboardCallback( b3KeyboardCallback	keyboardCallback)
{

}

b3KeyboardCallback GlutOpenGLWindow::getKeyboardCallback()
{
	return (b3KeyboardCallback)NULL;
}

