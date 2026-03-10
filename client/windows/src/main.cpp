#include <wx/wx.h>

// Define a new application class
class MyApp : public wxApp
{
public:
    virtual bool OnInit();
};

// Define a new frame (window)
class MyFrame : public wxFrame
{
public:
    MyFrame() : wxFrame(NULL, wxID_ANY, "Hello ATS_11") {}
};

// Implement the application
bool MyApp::OnInit()
{
    MyFrame* frame = new MyFrame();
    frame->Show(true);
    return true;
}

// Start the application
wxIMPLEMENT_APP(MyApp);
