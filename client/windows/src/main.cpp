#include <wx/wx.h>

class DebtFrame : public wxFrame
{
public:
    DebtFrame();

private:
    wxTextCtrl* principalInput;
    wxTextCtrl* rateInput;

    wxStaticText* intervalsOutput;
    wxStaticText* interestOutput;
    wxStaticText* debtOutput;

    wxRadioBox* interestType;

    int intervals = 0;
    double principal = 0;
    double rate = 0;
    double totalDebt = 0;

    void OnInterval(wxCommandEvent& event);
    void OnResetDebt(wxCommandEvent& event);
    void OnResetAll(wxCommandEvent& event);

    void UpdateDisplay();
};

class DebtApp : public wxApp
{
public:
    virtual bool OnInit();
};

wxIMPLEMENT_APP(DebtApp);

bool DebtApp::OnInit()
{
    DebtFrame* frame = new DebtFrame();
    frame->Show(true);
    return true;
}

DebtFrame::DebtFrame()
    : wxFrame(nullptr, wxID_ANY,
              "ATS_11 (Demo debt calculator)",
              wxDefaultPosition,
              wxSize(500, 350))
{
    wxPanel* panel = new wxPanel(this);

    wxBoxSizer* mainSizer = new wxBoxSizer(wxVERTICAL);

    // INPUTS
    wxFlexGridSizer* inputGrid = new wxFlexGridSizer(2, 5, 5);

    inputGrid->Add(new wxStaticText(panel, wxID_ANY, "Principal:"));
    principalInput = new wxTextCtrl(panel, wxID_ANY, "1000");
    inputGrid->Add(principalInput, 1, wxEXPAND);

    inputGrid->Add(new wxStaticText(panel, wxID_ANY, "Interest % per interval:"));
    rateInput = new wxTextCtrl(panel, wxID_ANY, "5");
    inputGrid->Add(rateInput, 1, wxEXPAND);

    mainSizer->Add(inputGrid, 0, wxALL | wxEXPAND, 10);

    // SIMPLE / COMPOUND SELECTOR
    wxString choices[] = {"Simple Interest", "Compound Interest"};
    interestType = new wxRadioBox(panel,
                                  wxID_ANY,
                                  "Interest Type",
                                  wxDefaultPosition,
                                  wxDefaultSize,
                                  2,
                                  choices);

    mainSizer->Add(interestType, 0, wxALL, 10);

    // OUTPUTS
    wxFlexGridSizer* outputGrid = new wxFlexGridSizer(2, 5, 5);

    outputGrid->Add(new wxStaticText(panel, wxID_ANY, "Intervals Passed:"));
    intervalsOutput = new wxStaticText(panel, wxID_ANY, "0");
    outputGrid->Add(intervalsOutput);

    outputGrid->Add(new wxStaticText(panel, wxID_ANY, "Interest Accumulated:"));
    interestOutput = new wxStaticText(panel, wxID_ANY, "0");
    outputGrid->Add(interestOutput);

    outputGrid->Add(new wxStaticText(panel, wxID_ANY, "Total Debt:"));
    debtOutput = new wxStaticText(panel, wxID_ANY, "0");
    outputGrid->Add(debtOutput);

    mainSizer->Add(outputGrid, 0, wxALL, 10);

    // BUTTONS
    wxBoxSizer* buttonSizer = new wxBoxSizer(wxHORIZONTAL);

    wxButton* intervalButton = new wxButton(panel, wxID_ANY, "Interval");
    wxButton* resetDebtButton = new wxButton(panel, wxID_ANY, "Reset Debt");
    wxButton* resetAllButton = new wxButton(panel, wxID_ANY, "Reset All");

    buttonSizer->Add(intervalButton, 1, wxALL, 5);
    buttonSizer->Add(resetDebtButton, 1, wxALL, 5);
    buttonSizer->Add(resetAllButton, 1, wxALL, 5);

    mainSizer->Add(buttonSizer, 0, wxALIGN_RIGHT | wxALL, 10);

    panel->SetSizer(mainSizer);

    intervalButton->Bind(wxEVT_BUTTON, &DebtFrame::OnInterval, this);
    resetDebtButton->Bind(wxEVT_BUTTON, &DebtFrame::OnResetDebt, this);
    resetAllButton->Bind(wxEVT_BUTTON, &DebtFrame::OnResetAll, this);

    UpdateDisplay();
}

void DebtFrame::OnInterval(wxCommandEvent&)
{
    principalInput->GetValue().ToDouble(&principal);
    rateInput->GetValue().ToDouble(&rate);

    rate /= 100.0;

    intervals++;

    if(intervals == 1)
        totalDebt = principal;

    if(interestType->GetSelection() == 0)
    {
        // SIMPLE INTEREST
        totalDebt = principal + (principal * rate * intervals);
    }
    else
    {
        // COMPOUND INTEREST
        totalDebt = totalDebt * (1 + rate);
    }

    UpdateDisplay();
}

void DebtFrame::OnResetDebt(wxCommandEvent&)
{
    intervals = 0;
    totalDebt = 0;
    UpdateDisplay();
}

void DebtFrame::OnResetAll(wxCommandEvent&)
{
    intervals = 0;
    totalDebt = 0;

    principalInput->SetValue("0");
    rateInput->SetValue("0");

    UpdateDisplay();
}

void DebtFrame::UpdateDisplay()
{
    intervalsOutput->SetLabel(wxString::Format("%d", intervals));

    double interest = totalDebt - principal;

    interestOutput->SetLabel(wxString::Format("%.2f", interest));
    debtOutput->SetLabel(wxString::Format("%.2f", totalDebt));
}