; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CSettingsDlg
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "BRAnyChatMeeting.h"

ClassCount=7
Class1=CBRAnyChatMeetingApp
Class2=CBRAnyChatMeetingDlg

ResourceCount=7
Resource2=IDD_DIALOG_HALL
Resource1=IDR_MAINFRAME
Class3=CLoginDlg
Resource3=IDD_DIALOG_LOGIN
Class4=CHallDlg
Resource4=IDD_DIALOG_SETTINGS
Class5=CVideoPanelDlg
Resource5=IDD_DIALOG_MEETING
Class6=CSettingsDlg
Resource6=IDD_DIALOG_VIDEOPANEL
Class7=CFullScreenDlg
Resource7=IDD_DIALOG_FULLSCREEN

[CLS:CBRAnyChatMeetingApp]
Type=0
HeaderFile=BRAnyChatMeeting.h
ImplementationFile=BRAnyChatMeeting.cpp
Filter=N
BaseClass=CWinApp
VirtualFilter=AC

[CLS:CBRAnyChatMeetingDlg]
Type=0
HeaderFile=BRAnyChatMeetingDlg.h
ImplementationFile=BRAnyChatMeetingDlg.cpp
Filter=W
LastObject=IDC_EDIT_TEXTOUTPUT
BaseClass=CDialog
VirtualFilter=dWC



[DLG:IDD_DIALOG_LOGIN]
Type=1
Class=CLoginDlg
ControlCount=12
Control1=IDC_BUTTON_LOGIN,button,1342242816
Control2=IDC_STATIC,static,1342308352
Control3=IDC_STATIC,static,1342308352
Control4=IDC_EDIT_USERNAME,edit,1350631552
Control5=IDC_EDIT_PASSWORD,edit,1350631552
Control6=IDC_CHECK_GUESTLOGIN,button,1342242819
Control7=IDC_BUTTON_SETTINGS,button,1342242816
Control8=IDC_STATIC,static,1342308352
Control9=IDC_STATIC,static,1342308352
Control10=IDC_EDIT_PORT,edit,1350639744
Control11=IDC_STATIC_NOTIFY,static,1342308352
Control12=IDC_SERVER_IPADDR,edit,1350631552

[CLS:CLoginDlg]
Type=0
HeaderFile=LoginDlg.h
ImplementationFile=LoginDlg.cpp
BaseClass=CDialog
Filter=W
LastObject=CLoginDlg
VirtualFilter=dWC

[DLG:IDD_DIALOG_HALL]
Type=1
Class=CHallDlg
ControlCount=15
Control1=IDC_STATIC,button,1342177287
Control2=IDC_LIST_ROOM,SysListView32,1350631424
Control3=IDC_STATIC_NOTIFY,static,1342308352
Control4=IDC_BUTTON_EXIT,button,1342242816
Control5=IDC_STATIC,static,1342308352
Control6=IDC_STATIC_NICKNAME,static,1342308352
Control7=IDC_STATIC,static,1342308352
Control8=IDC_STATIC_USERID,static,1342308352
Control9=IDC_STATIC,static,1342308352
Control10=IDC_STATIC_USERLEVEL,static,1342308352
Control11=IDC_STATIC,static,1342308352
Control12=IDC_STATIC_INTERNETIP,static,1342308352
Control13=IDC_STATIC,static,1342308352
Control14=IDC_EDIT_ROOMID,edit,1350639744
Control15=IDC_BUTTON_ENTERROOM,button,1342242816

[CLS:CHallDlg]
Type=0
HeaderFile=HallDlg.h
ImplementationFile=HallDlg.cpp
BaseClass=CDialog
Filter=D
VirtualFilter=dWC
LastObject=IDC_EDIT_ROOMID

[DLG:IDD_DIALOG_MEETING]
Type=1
Class=CBRAnyChatMeetingDlg
ControlCount=11
Control1=IDC_EDIT_TEXTINPUT,edit,1350631552
Control2=IDC_STATIC_USERLIST,button,1342177287
Control3=IDC_STATIC_LOCALVIDEO,button,1342177287
Control4=IDC_STATIC_REMOTEVIDEO,button,1342177287
Control5=IDC_STATIC,button,1342177287
Control6=IDC_EDIT_TEXTOUTPUT,edit,1350631556
Control7=IDC_STATIC,static,1342308352
Control8=IDC_BUTTON_SENDTEXT,button,1342242816
Control9=IDC_LIST_USER,SysListView32,1350680577
Control10=IDC_COMBO_DISPNUM,combobox,1344339971
Control11=IDC_BUTTON_ADVSET,button,1342242816

[DLG:IDD_DIALOG_VIDEOPANEL]
Type=1
Class=CVideoPanelDlg
ControlCount=5
Control1=IDC_PROGRESS_AUDIOVOLUME,msctls_progress32,1342177281
Control2=IDC_BUTTON_VIDEOCTRL,button,1342242816
Control3=IDC_BUTTON_AUDIOCTRL,button,1342242816
Control4=IDC_BUTTON_SNAPSHOT,button,1342242816
Control5=IDC_BUTTON_RECORD,button,1342242816

[CLS:CVideoPanelDlg]
Type=0
HeaderFile=VideoPanelDlg.h
ImplementationFile=VideoPanelDlg.cpp
BaseClass=CDialog
Filter=W
VirtualFilter=dWC
LastObject=IDC_STATIC_TITLE

[DLG:IDD_DIALOG_SETTINGS]
Type=1
Class=CSettingsDlg
ControlCount=55
Control1=IDC_STATIC,static,1342308352
Control2=IDC_COMBO_VIDEOCAPTURE,combobox,1344339971
Control3=IDC_STATIC,static,1342308352
Control4=IDC_COMBO_AUDIOCAPTURE,combobox,1344339971
Control5=IDC_STATIC,button,1342177287
Control6=IDC_STATIC,button,1342177287
Control7=IDC_STATIC,static,1342308352
Control8=IDC_STATIC,static,1342308352
Control9=IDC_CHECK_MICBOOST,button,1342242819
Control10=IDC_STATIC,button,1342177287
Control11=IDC_COMBO_AUDIOWORKMODE,combobox,1344339971
Control12=IDC_CHECK_AUDIOVAD,button,1342242819
Control13=IDC_CHECK_AUDIOAEC,button,1342242819
Control14=IDC_CHECK_AUDIONS,button,1342242819
Control15=IDC_CHECK_AUDIOAGC,button,1342242819
Control16=IDC_STATIC,button,1342177287
Control17=IDC_COMBO_VIDEOQUALITY,combobox,1344339971
Control18=IDC_BUTTON_VIDEOPROPERTY,button,1342242816
Control19=IDC_SLIDER_WAVEOUTVOLUME,static,1342308608
Control20=IDC_SLIDER_WAVEINVOLUME,static,1342308608
Control21=IDC_CHECK_DEINTERLACE,button,1342242819
Control22=IDC_CHECK_STREAMPROXY,button,1342242819
Control23=IDC_EDIT_PROXYUSERID,edit,1350631552
Control24=IDC_BUTTON_CHANGEPROXYUSER,button,1342242816
Control25=IDC_STATIC,static,1342308352
Control26=IDC_COMBO_VIDEOSIZE,combobox,1344339971
Control27=IDC_STATIC_CURVIDEOSIZE,static,1342308352
Control28=IDC_BUTTON_VIDEOAPPLY,button,1342242816
Control29=IDC_STATIC,static,1342308352
Control30=IDC_COMBO_VIDEOFPS,combobox,1344339971
Control31=IDC_CHECK_SERVERVIDEOSETTINGS,button,1342242819
Control32=IDC_STATIC,static,1342308352
Control33=IDC_COMBO_VIDEOBITRATE,combobox,1344339971
Control34=IDC_STATIC,static,1342308352
Control35=IDC_STATIC,static,1342308352
Control36=IDC_COMBO_VIDEOPRESET,combobox,1344339971
Control37=IDC_STATIC_VIDEOBITRATE,static,1342308352
Control38=IDC_STATIC,static,1342308352
Control39=IDC_STATIC,static,1342308352
Control40=IDC_COMBO_AUDIOPLAYBACK,combobox,1344339971
Control41=IDC_STATIC,button,1342177287
Control42=IDC_STATIC,static,1342308352
Control43=IDC_MULTICAST_IPADDR,SysIPAddress32,1342242816
Control44=IDC_STATIC,static,1342308352
Control45=IDC_EDIT_MULTICASTPORT,edit,1350631552
Control46=IDC_COMBO_MULTICASTCTRL,combobox,1344339971
Control47=IDC_CHECK_SENDDATA,button,1342242819
Control48=IDC_CHECK_RECVDATA,button,1342242819
Control49=IDC_BUTTON_MULTICASTAPPLY,button,1342242816
Control50=IDC_COMBO_MULTICASTPOLITIC,combobox,1344339971
Control51=IDC_STATIC,static,1342308352
Control52=IDC_STATIC,static,1342308352
Control53=IDC_COMBO_MULTICASTNIC,combobox,1344339971
Control54=IDC_CHECK_ENABLEP2P,button,1342242819
Control55=IDC_STATIC,button,1342177287

[CLS:CSettingsDlg]
Type=0
HeaderFile=SettingsDlg.h
ImplementationFile=SettingsDlg.cpp
BaseClass=CDialog
Filter=W
VirtualFilter=dWC
LastObject=IDC_CHECK_ENABLEP2P

[DLG:IDD_DIALOG_FULLSCREEN]
Type=1
Class=CFullScreenDlg
ControlCount=0

[CLS:CFullScreenDlg]
Type=0
HeaderFile=FullScreenDlg.h
ImplementationFile=FullScreenDlg.cpp
BaseClass=CDialog
Filter=D
LastObject=CFullScreenDlg
VirtualFilter=dWC

