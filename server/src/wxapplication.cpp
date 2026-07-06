#include "wxapplication.h"

wxIMPLEMENT_APP(wxApplication);

#include "../res/icon.xpm"

wxApplication::wxApplication() { }

bool wxApplication::OnInit()
{
    instanceChecker = new wxSingleInstanceChecker();
    if(instanceChecker->IsAnotherRunning())
    {
        wxMessageBox("Mousedroid is already running.", "Mousedroid", wxOK | wxICON_INFORMATION);
        return false;
    }

    main_frame = new wxMain(settings);

    try
    {
        server = new Server(6969, *this, settings, inputManager);
    }
    catch(const std::exception &e)
    {
        wxMessageBox("Could not start: port 6969 is already in use.\nIs Mousedroid already running?", "Mousedroid", wxOK | wxICON_ERROR);
        return false;
    }

    Server::HostInfo hostInfo = server->GetHostInfo();
    
    main_frame->Bind(wxEVT_CLOSE_WINDOW, &wxApplication::OnWindowCloseEvent, this);
    main_frame->SetHostInfo(std::get<0>(hostInfo), std::get<1>(hostInfo));

    if(!settings.GetRunAtStartup())
        main_frame->Show();
    
    server->Start();

    main_frame->UpdateUI();

    return true;
}

int wxApplication::OnExit()
{
    delete instanceChecker;
    return wxApp::OnExit();
}

void wxApplication::OnDeviceConnected(std::string device) const
{
    auto devices = server->GetConnectedDevicesInfo();
    main_frame->wxdevlist->SetDevices(devices);
}

void wxApplication::OnDeviceDisconnected(std::string device) const
{
	auto devices = server->GetConnectedDevicesInfo();
    main_frame->wxdevlist->SetDevices(devices);
}

void wxApplication::OnWindowCloseEvent(wxCloseEvent &evt)
{
    if(!server->GetConnectedDevicesInfo().empty())
    {
        wxMessageDialog *box = new wxMessageDialog(main_frame, "This will disconnect all connected devices. Proceed?", "Confirm", wxYES_NO | wxICON_INFORMATION);
        if(box->ShowModal() != wxID_YES)
            return;
    }

    main_frame->Hide();
    server->Close();
    Logger::monitor->Destroy();
    main_frame->Destroy();
}
