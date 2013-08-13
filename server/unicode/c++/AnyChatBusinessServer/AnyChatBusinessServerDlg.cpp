// AnyChatBusinessServerDlg.cpp : implementation file
//

#include "stdafx.h"
#include "AnyChatBusinessServer.h"
#include "AnyChatBusinessServerDlg.h"

#include "AnyChatServerSDK.h"
#ifdef _UNICODE
#	pragma comment(lib,"AnyChatServerSDKU.lib")
#else
#	pragma comment(lib,"AnyChatServerSDK.lib")
#endif //_UNICODE

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


#define SENDBUF_STYLE_SYSTEM	0		///< ϵͳ�㲥
#define SENDBUF_STYLE_ROOM		1		///< ����㲥
#define SENDBUF_STYLE_USER		2		///< ָ���û�



// ������Ӧ�ó�����Ϣ�ص���������
void CALLBACK OnServerAppMessageCallBack(DWORD dwMsg, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(dwMsg == BRAS_SERVERAPPMSG_CONNECTED)
		lpServerDlg->AppendLogString(_T("��AnyChat���������ӳɹ���"));
	else if(dwMsg == BRAS_SERVERAPPMSG_DISCONNECT)
		lpServerDlg->AppendLogString(_T("��AnyChat�������Ͽ����ӣ�"));
	else
	{
		CString strMsg;
		strMsg.Format(_T("�յ�������Ӧ�ó�����Ϣ��%d"),dwMsg);
		lpServerDlg->AppendLogString(strMsg);
	}
}

/**
 *	SDK��ʱ���ص��������壬�ϲ�Ӧ�ÿ����ڸûص��д�����ʱ���񣬶�����Ҫ���⿪���̣߳����Ƕ�ʱ��
 *	������������̣߳�����ע��Windows��ʱ��������뿼�Ƕ��߳�ͬ��������
 *	��ʹ��SDK��TimerEvent�ص�������Ҫ���ǣ���Ϊ��ʱ���ص��ͱ�Ļص���������˳�򴥷���
 */
void CALLBACK OnTimerEventCallBack(LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
//		lpServerDlg->AppendLogString("��ʱ���¼�");
	}
}

// �û�������֤�ص���������
DWORD CALLBACK VerifyUserCallBack(IN LPCTSTR lpUserName,IN LPCTSTR lpPassword, OUT LPDWORD lpUserID, OUT LPDWORD lpUserLevel, OUT LPTSTR lpNickName,IN DWORD dwNCLen, LPVOID lpUserValue)
{
	static DWORD dwUserIdSeed = 1;
	*lpUserID = dwUserIdSeed++;

	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("VerifyUser(%s - %s) --> userid(%d)"),lpUserName,lpPassword,(int)*lpUserID);
		lpServerDlg->AppendLogString(strMsg);
	}
	return 0;
}
// �û�������뷿��ص���������
DWORD CALLBACK PrepareEnterRoomCallBack(DWORD dwUserId, DWORD dwRoomId, LPCTSTR lpRoomName,LPCTSTR lpPassword, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("PrepareEnterRoom(dwUserId:%d - dwRoomId:%d)"),(int)dwUserId,(int)dwRoomId);
		lpServerDlg->AppendLogString(strMsg);
	}
	return 0;
}
// �û���¼�ɹ��ص���������
void CALLBACK OnUserLoginActionCallBack(DWORD dwUserId, LPCTSTR szUserName, DWORD dwLevel, LPCTSTR szIpAddr, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("OnUserLoginAction(dwUserId:%d - Name:%s)"),(int)dwUserId,szUserName);
		lpServerDlg->AppendLogString(strMsg);
	}
}
// �û�ע���ص���������
void CALLBACK OnUserLogoutActionCallBack(DWORD dwUserId, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("OnUserLogoutAction(dwUserId:%d)"),(int)dwUserId);
		lpServerDlg->AppendLogString(strMsg);
	}
}
// �û����뷿��ص���������
void CALLBACK OnUserEnterRoomActionCallBack(DWORD dwUserId, DWORD dwRoomId, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("OnUserEnterRoomAction(dwUserId:%d - dwRoomId:%d)"),(int)dwUserId,(int)dwRoomId);
		lpServerDlg->AppendLogString(strMsg);
	}
}
// �û��뿪����ص���������
void CALLBACK OnUserLeaveRoomActionCallBack(DWORD dwUserId, DWORD dwRoomId, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("OnUserLeaveRoomAction(dwUserId:%d - dwRoomId:%d)"),(int)dwUserId,(int)dwRoomId);
		lpServerDlg->AppendLogString(strMsg);
	}
}
// �ϲ�ҵ���Զ������ݻص���������
void CALLBACK OnRecvUserFilterDataCallBack(DWORD dwUserId, BYTE* lpBuf, DWORD dwLen, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("OnRecvUserFilterData(dwUserId:%d - Buf:%s)"),(int)dwUserId,lpBuf);
		lpServerDlg->AppendLogString(strMsg);
	}
}

// �յ��û���������ͨ�����ݻص���������
void CALLBACK OnRecvUserTextMsgCallBack(DWORD dwRoomId, DWORD dwSrcUserId, DWORD dwTarUserId, BOOL bSecret, LPCTSTR lpTextMessage, DWORD dwLen, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("OnRecvUserTextMsg(dwRoomId:%d, dwSrcUserId:%d, dwTarUserId:%d - Buf:%s)"),(int)dwRoomId,(int)dwSrcUserId,(int)dwTarUserId,lpTextMessage);
		lpServerDlg->AppendLogString(strMsg);
	}
}

// ͸��ͨ�����ݻص���������
void CALLBACK OnTransBufferCallBack(DWORD dwUserId, LPBYTE lpBuf, DWORD dwLen, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("OnTransBufferCallBack(dwUserId:%d - BufLen:%d)"),(int)dwUserId,dwLen);
		lpServerDlg->AppendLogString(strMsg);
	}
}

// ͸��ͨ��������չ�ص���������
void CALLBACK OnTransBufferExCallBack(DWORD dwUserId, LPBYTE lpBuf, DWORD dwLen, DWORD wParam, DWORD lParam, DWORD dwTaskId, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("OnTransBufferExCallBack(dwUserId:%d - BufLen:%d - wParam:%d - lParam:%d - dwTaskId:%d)"),(int)dwUserId,dwLen, wParam, lParam, dwTaskId);
		lpServerDlg->AppendLogString(strMsg);
	}
}
// �ļ�����ص���������
void CALLBACK OnTransFileCallBack(DWORD dwUserId, LPCTSTR lpFileName, LPCTSTR lpTempFilePath, DWORD dwFileLength, DWORD wParam, DWORD lParam, DWORD dwTaskId, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("OnTransFileCallBack(dwUserId:%d, PathName:%s - wParam:%d - lParam:%d - dwTaskId:%d)"),(int)dwUserId, lpFileName, wParam, lParam, dwTaskId);
		lpServerDlg->AppendLogString(strMsg);
	}
}

// ������¼��ص���������
void CALLBACK OnServerRecord_CallBack(DWORD dwUserId, DWORD dwParam, DWORD dwRecordServerId, DWORD dwElapse, LPCTSTR lpRecordFileName, LPVOID lpUserValue)
{
	CAnyChatBusinessServerDlg* lpServerDlg = (CAnyChatBusinessServerDlg*)lpUserValue;
	if(lpServerDlg)
	{
		CString strMsg;
		strMsg.Format(_T("OnServerRecordCallBack(dwUserId:%d, FileName:%s)"),(int)dwUserId, lpRecordFileName);
		lpServerDlg->AppendLogString(strMsg);
	}
}


CAnyChatBusinessServerDlg::CAnyChatBusinessServerDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CAnyChatBusinessServerDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CAnyChatBusinessServerDlg)
	m_iTargetId = 0;
	//}}AFX_DATA_INIT
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CAnyChatBusinessServerDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAnyChatBusinessServerDlg)
	DDX_Control(pDX, IDC_EDIT_LOG, m_ctrlEditLog);
	DDX_Control(pDX, IDC_COMBO_STYLE, m_ComboStyle);
	DDX_Text(pDX, IDC_EDIT_TARGETID, m_iTargetId);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAnyChatBusinessServerDlg, CDialog)
	//{{AFX_MSG_MAP(CAnyChatBusinessServerDlg)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_WM_DESTROY()
	ON_BN_CLICKED(IDC_BUTTON_SENDBUF, OnButtonSendbuf)
	ON_BN_CLICKED(IDC_BUTTONTRANSFILE, OnButtonTransFile)
	ON_BN_CLICKED(IDC_BUTTONTRANSBUFFEREX, OnButtonTransBufferEx)
	ON_BN_CLICKED(IDC_BUTTON_TRANSBUFFER, OnButtonTransBuffer)
	ON_BN_CLICKED(IDC_BUTTON_STARTRECORD, OnButtonStartRecord)
	ON_BN_CLICKED(IDC_BUTTON_STOPRECORD, OnButtonStopRecord)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CAnyChatBusinessServerDlg message handlers

BOOL CAnyChatBusinessServerDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	DWORD dwIndex = m_ComboStyle.AddString(_T("�����û��㲥"));
	m_ComboStyle.SetItemData(dwIndex,SENDBUF_STYLE_SYSTEM);
	m_ComboStyle.SetCurSel(dwIndex);
	dwIndex = m_ComboStyle.AddString(_T("ָ������㲥"));
	m_ComboStyle.SetItemData(dwIndex,SENDBUF_STYLE_ROOM);
	dwIndex = m_ComboStyle.AddString(_T("ָ���û�����"));
	m_ComboStyle.SetItemData(dwIndex,SENDBUF_STYLE_USER);

	
	// ���÷�����Ӧ�ó�����Ϣ�ص�����
	BRAS_SetOnServerAppMessageCallBack(OnServerAppMessageCallBack,this);
	// ����SDK��ʱ���ص�����
	BRAS_SetTimerEventCallBack(1000,OnTimerEventCallBack,this);
	// �����û�������֤�ص�����
	BRAS_SetVerifyUserCallBack(VerifyUserCallBack,this);
	// �����û�������뷿��ص�����
	BRAS_SetPrepareEnterRoomCallBack(PrepareEnterRoomCallBack, this);
	// �����û���¼�ɹ��ص�����
	BRAS_SetOnUserLoginActionCallBack(OnUserLoginActionCallBack, this);
	// �����û�ע���ص�����
	BRAS_SetOnUserLogoutActionCallBack(OnUserLogoutActionCallBack, this);
	// �����û����뷿��ص�����
	BRAS_SetOnUserEnterRoomActionCallBack(OnUserEnterRoomActionCallBack, this);
	// �����û��뿪����ص�����
	BRAS_SetOnUserLeaveRoomActionCallBack(OnUserLeaveRoomActionCallBack, this);
	// �����û��ϲ�ҵ���Զ������ݻص�����
	BRAS_SetOnRecvUserFilterDataCallBack(OnRecvUserFilterDataCallBack, this);
	// �û���������ͨ�����ݻص�����
	BRAS_SetOnRecvUserTextMsgCallBack(OnRecvUserTextMsgCallBack,this);
	// ����͸��ͨ�����ݻص�����
	BRAS_SetOnTransBufferCallBack(OnTransBufferCallBack, this);
	// ����͸��ͨ��������չ�ص�����
	BRAS_SetOnTransBufferExCallBack(OnTransBufferExCallBack, this);
	// �����ļ�����ص�����
	BRAS_SetOnTransFileCallBack(OnTransFileCallBack, this);
	// ���÷�����¼��ص�����
	BRAS_SetOnServerRecordCallBack(OnServerRecord_CallBack, this);
	
	BRAS_InitSDK(0);

	return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CAnyChatBusinessServerDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

HCURSOR CAnyChatBusinessServerDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

void CAnyChatBusinessServerDlg::OnDestroy() 
{
	BRAS_Release();

	CDialog::OnDestroy();
}

void CAnyChatBusinessServerDlg::OnButtonSendbuf() 
{
	UpdateData(TRUE);
	CString strBuffer;
	GetDlgItemText(IDC_EDIT_SENDBUF,strBuffer);
	if(strBuffer.IsEmpty())
		return;

	DWORD dwStyle = m_ComboStyle.GetCurSel();
	if(dwStyle == SENDBUF_STYLE_SYSTEM)
		BRAS_SendBufToRoom(-1,strBuffer.GetBuffer(0),strBuffer.GetLength());
	else if(dwStyle == SENDBUF_STYLE_ROOM)
		BRAS_SendBufToRoom(m_iTargetId,strBuffer.GetBuffer(0),strBuffer.GetLength());
	else
		BRAS_SendBufToUser(m_iTargetId,strBuffer.GetBuffer(0),strBuffer.GetLength());	
}

/**
 *	��ʾ��־��Ϣ
 */
void CAnyChatBusinessServerDlg::AppendLogString(CString logstr)
{
	m_strLogInfo += (logstr + "\r\n");
	m_ctrlEditLog.SetWindowText(m_strLogInfo);
	m_ctrlEditLog.LineScroll(m_ctrlEditLog.GetLineCount());
}

void CAnyChatBusinessServerDlg::OnButtonTransFile() 
{
	UpdateData(TRUE);
	if(m_iTargetId == -1)
	{
		AppendLogString("BRAS_TransFile ����Ŀ���û�����Ϊ-1");
		return;
	}
	static TCHAR BASED_CODE szFilter[] = _T("All Files (*.*)|*.*||");
	CFileDialog dlg(TRUE,_T(""),NULL,  OFN_HIDEREADONLY ,szFilter);
	if(dlg.DoModal() == IDOK)
	{
		DWORD wParam = 1;				// wParam��lParam�Ǹ��������������ϲ�Ӧ����չ
		DWORD lParam = 2;
		DWORD dwFlags = 0;
		DWORD dwTaskId = 0;
		DWORD ret = BRAS_TransFile(m_iTargetId, dlg.GetPathName(), wParam, lParam, dwFlags, dwTaskId);
		CString strLog;
		if(ret == 0)
			strLog.Format(_T("BRAS_TransFile �����ύ�ɹ���TaskId:%d"), dwTaskId);
		else
			strLog.Format(_T("BRAS_TransFile �����ύʧ�ܣ�ErrorCode:%d"), ret);
		AppendLogString(strLog);
	}
}

// ʹ��͸��ͨ����չ������ָ���û����ʹ����ݿ黺����
void CAnyChatBusinessServerDlg::OnButtonTransBufferEx() 
{
	UpdateData(TRUE);
	if(m_iTargetId == -1)
	{
		AppendLogString("BRAS_TransBufferEx ����Ŀ���û�����Ϊ-1");
		return;
	}
	BYTE szBuf[1024*10] = {0};		// ʵ�飬��һ���ջ�������Ŀ���û����ж��Ƿ��ܽ��յ�
	DWORD wParam = 1;				// wParam��lParam�Ǹ��������������ϲ�Ӧ����չ
	DWORD lParam = 2;
	DWORD dwFlags = 0;
	DWORD dwTaskId = 0;
	DWORD ret = BRAS_TransBufferEx(m_iTargetId, szBuf, sizeof(szBuf), wParam, lParam, dwFlags, dwTaskId);
	CString strLog;
	if(ret == 0)
		strLog.Format(_T("BRAS_TransBufferEx �����ύ�ɹ���TaskId:%d"), dwTaskId);
	else
		strLog.Format(_T("BRAS_TransBufferEx �����ύʧ�ܣ�ErrorCode:%d"), ret);
	AppendLogString(strLog);
}
// ʹ��͸��ͨ��������ָ���û����ͻ�����
void CAnyChatBusinessServerDlg::OnButtonTransBuffer() 
{
	UpdateData(TRUE);
	CString strBuffer;
	GetDlgItemText(IDC_EDIT_SENDBUF,strBuffer);
	if(strBuffer.IsEmpty())
		return;
	if(m_iTargetId == -1)
	{
		AppendLogString("BRAS_TransBuffer ����Ŀ���û�����Ϊ-1");
		return;
	}
	BRAS_TransBuffer(m_iTargetId,(LPBYTE)strBuffer.GetBuffer(0),strBuffer.GetLength());	
}

void CAnyChatBusinessServerDlg::OnButtonStartRecord() 
{
	UpdateData(TRUE);
	BRAS_StreamRecordCtrl(m_iTargetId, TRUE, 0, 0, -1);
}

void CAnyChatBusinessServerDlg::OnButtonStopRecord() 
{
	UpdateData(TRUE);
	BRAS_StreamRecordCtrl(m_iTargetId, FALSE, 0, 0, -1);
}