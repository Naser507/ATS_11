#include <wx/wx.h>

class CounterFrame : public wxFrame {
public:
    CounterFrame() : wxFrame(nullptr, wxID_ANY, "Counter App", wxDefaultPosition, wxSize(250, 150)), count(0) {
        wxPanel* panel = new wxPanel(this);

        countLabel = new wxStaticText(panel, wxID_ANY, "Count: 0", wxPoint(90, 20));

        wxButton* incBtn = new wxButton(panel, wxID_ANY, "Increment", wxPoint(30, 60));
        wxButton* resetBtn = new wxButton(panel, wxID_ANY, "Reset", wxPoint(140, 60));

        incBtn->Bind(wxEVT_BUTTON, &CounterFrame::OnIncrement, this);
        resetBtn->Bind(wxEVT_BUTTON, &CounterFrame::OnReset, this);
    }

private:
    int count;
    wxStaticText* countLabel;

    void OnIncrement(wxCommandEvent&) {
        count++;
        countLabel->SetLabel(wxString::Format("Count: %d", count));
    }

    void OnReset(wxCommandEvent&) {
        count = 0;
        countLabel->SetLabel("Count: 0");
    }
};

class CounterApp : public wxApp {
public:
    bool OnInit() override {
        CounterFrame* frame = new CounterFrame();
        frame->Show(true);
        return true;
    }
};

wxIMPLEMENT_APP(CounterApp);