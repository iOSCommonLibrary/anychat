package com.bairuitech.anychatqueue;




import java.util.Timer;
import java.util.TimerTask;

import com.bairuitech.anychat.AnyChatBaseEvent;
import com.bairuitech.anychat.AnyChatCoreSDK;
import com.bairuitech.anychat.AnyChatDefine;
import com.bairuitech.anychat.AnyChatObjectDefine;
import com.bairuitech.anychat.AnyChatObjectEvent;
import com.bairuitech.anychat.AnyChatVideoCallEvent;
import com.bairuitech.bussinesscenter.BussinessCenter;

import com.example.anychatqueue.MainActivity;
import com.example.anychatqueue.R;
import com.example.common.BaseConst;
import com.example.common.BaseMethod;
import com.example.common.ConfigEntity;
import com.example.common.DialogFactory;
import com.example.common.ConfigService;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.view.inputmethod.BaseInputConnection;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;

public class QueueActivity extends Activity implements AnyChatBaseEvent,AnyChatVideoCallEvent,AnyChatObjectEvent, OnClickListener{
	private Button  quickButton;
	private AnyChatCoreSDK anychat;
	private Dialog dialog;
	private TextView showTextView;
	private ConfigEntity configEntity;
	private ImageButton mImgBtnReturn;
	private TextView mTitleName,timeshow;	
	private int seconds = 0;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		 requestWindowFeature(Window.FEATURE_CUSTOM_TITLE);
		setContentView(R.layout.activity_queue);
		getWindow().setFeatureInt(Window.FEATURE_CUSTOM_TITLE, R.layout.titlebar); 
		
		Intent intent = getIntent();
		int morder = intent.getIntExtra("order",666);
		
		initSdk();
		initView(morder);
		
	}
	private void initView(int morder) {
		configEntity = ConfigService.LoadConfig(this);
		mImgBtnReturn = (ImageButton) this.findViewById(R.id.returnImgBtn);
		mImgBtnReturn.setOnClickListener(this);
		mTitleName = (TextView) this.findViewById(R.id.titleName);
		mTitleName.setText("业务排队大厅");
		
		showTextView = (TextView) findViewById(R.id.queue_show);
		showTextView.setText("在您前面还有："+morder+" 人等待，请您耐心等候...");
		timeshow = (TextView) findViewById(R.id.queue_time);
		final Handler myhHandler = new Handler(){
			@Override
			public void handleMessage(Message msg) {
				if(msg.what == 0x123){					
			seconds = AnyChatCoreSDK.ObjectGetIntValue(AnyChatObjectDefine.ANYCHAT_OBJECT_TYPE_QUEUE, configEntity.CurrentQueueId, AnyChatObjectDefine.ANYCHAT_QUEUE_INFO_WAITTIMESECOND);
			timeshow.setText("您已等待了 "+BaseMethod.getTimeShowString(seconds));
				}
			}
			
		};
		new Timer().schedule(new TimerTask() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				myhHandler.sendEmptyMessage(0x123);
			}
		}, 0,1000);
		
		
		quickButton = (Button) findViewById(R.id.queue_btn);
		quickButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				AlertDialog.Builder builder = new AlertDialog.Builder(QueueActivity.this);
					builder.setMessage("您确定要退出当前排队吗!")
							.setPositiveButton("sure", new DialogInterface.OnClickListener() {
								
								@Override
								public void onClick(DialogInterface dialog, int which) {
									// TODO Auto-generated method stub
									AnyChatCoreSDK.ObjectControl(AnyChatObjectDefine.ANYCHAT_OBJECT_TYPE_QUEUE,configEntity.CurrentQueueId, AnyChatObjectDefine.ANYCHAT_QUEUE_CTRL_USERLEAVE, 0, 0, 0, 0, "");
									finish();
								}
							}).setNegativeButton("cancel", new DialogInterface.OnClickListener() {
								
								@Override
								public void onClick(DialogInterface dialog, int which) {
									// TODO Auto-generated method stub
									
								}
							}).create().show();
			}
		});
	}
	private void initSdk() {
		// TODO Auto-generated method stub
		if (anychat == null) {
			anychat = new AnyChatCoreSDK();
		}
		anychat.SetBaseEvent(this);
		anychat.SetVideoCallEvent(this);
		anychat.SetObjectEvent(this);
//		anychat.SetUserInfoEvent(this);
		Log.i("ANYCHAT", "initSdk");
	}
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		BussinessCenter.mContext = QueueActivity.this;
		super.onResume();
	}
	@Override
	public void OnAnyChatConnectMessage(boolean bSuccess) {
		// TODO Auto-generated method stub
		if (dialog != null
				&& dialog.isShowing()
				&& DialogFactory.getCurrentDialogId() == DialogFactory.DIALOGID_RESUME) {
			dialog.dismiss();
		}
	}
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		BussinessCenter.getBussinessCenter().realseData();
	}
	@Override
	public boolean dispatchKeyEvent(KeyEvent event) {
		// TODO Auto-generated method stub
		if (event.getAction() == KeyEvent.ACTION_DOWN
				&& event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
			AlertDialog.Builder builder = new AlertDialog.Builder(QueueActivity.this);
			builder.setMessage("Are you sure you want to exist!")
					.setPositiveButton("sure", new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
							// TODO Auto-generated method stub
							AnyChatCoreSDK.ObjectControl(AnyChatObjectDefine.ANYCHAT_OBJECT_TYPE_QUEUE,configEntity.CurrentQueueId, AnyChatObjectDefine.ANYCHAT_QUEUE_CTRL_USERLEAVE, 0, 0, 0, 0, "");
							System.out.println("退出队列语句执行，队列id号为："+configEntity.CurrentQueueId);
							finish();
						}
					}).setNegativeButton("cancel", new DialogInterface.OnClickListener() {
						
						@Override
						public void onClick(DialogInterface dialog, int which) {
							// TODO Auto-generated method stub
							
						}
					}).create().show();
			
			
		}
		return super.dispatchKeyEvent(event);
	}
	/*private void destroyCurActivity() {
		// TODO Auto-generated method stub
		
		onDestroy();
		finish();
	}*/
	@Override
	public void OnAnyChatLoginMessage(int dwUserId, int dwErrorCode) {
		// TODO Auto-generated method stub
		if(dwErrorCode==0)
		{
			BussinessCenter.selfUserId   =  dwUserId;
			BussinessCenter.selfUserName = anychat.GetUserName(dwUserId);
		} else {
			BaseMethod.showToast(this.getString(R.string.str_login_failed) + "(ErrorCode:" + dwErrorCode + ")",	this);
		}
	}
	@Override
	public void OnAnyChatEnterRoomMessage(int dwRoomId, int dwErrorCode) {
		// TODO Auto-generated method stub
		if (dwErrorCode == 0) {
			
			Intent intent = new Intent();
			intent.setClass(this, VideoActivity.class);
			this.startActivity(intent);
			
		} else {
			BaseMethod.showToast(this.getString(R.string.str_enterroom_failed),
					this);
		}
		if (dialog != null)
			dialog.dismiss();
	}
	@Override
	public void OnAnyChatOnlineUserMessage(int dwUserNum, int dwRoomId) {
		// TODO Auto-generated method stub
		
	}
	@Override
	public void OnAnyChatUserAtRoomMessage(int dwUserId, boolean bEnter) {
		// TODO Auto-generated method stub
		
	}
	@Override
	public void OnAnyChatLinkCloseMessage(int dwErrorCode) {
		// TODO Auto-generated method stub
		if (dwErrorCode == 0) {
			if (dialog != null && dialog.isShowing())
				dialog.dismiss();
			dialog = DialogFactory.getDialog(DialogFactory.DIALOG_NETCLOSE,
					DialogFactory.DIALOG_NETCLOSE, this);
			dialog.show();
		} else {
			BaseMethod.showToast(this.getString(R.string.str_serverlink_close),
					this);
			Intent intent = new Intent();
			intent.putExtra("INTENT", BaseConst.AGAIGN_LOGIN);
			intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			intent.setClass(this,MainActivity.class);
			this.startActivity(intent);	
		}
	}
	@Override
	public void OnAnyChatObjectEvent(int dwObjectType, int dwObjectId,
			int dwEventType, int dwParam1, int dwParam2, int dwParam3,
			int dwParam4, String strParam) {
		// TODO Auto-generated method stub
		
		//有其他人进入队列；
		if(dwEventType == AnyChatObjectDefine.ANYCHAT_QUEUE_EVENT_USERENTER)
		{
			//查询前面有多少人
			int mbefore = AnyChatCoreSDK.ObjectGetIntValue(AnyChatObjectDefine.ANYCHAT_OBJECT_TYPE_QUEUE, dwObjectId, AnyChatObjectDefine.ANYCHAT_QUEUE_INFO_BEFOREUSERNUM);
			if(mbefore == -1) mbefore = 0;
			showTextView.setText("在您前面还有："+mbefore+"人等待，请您耐心等候...");
		}//有其他人离开队列
		else if(dwEventType == AnyChatObjectDefine.ANYCHAT_QUEUE_EVENT_USERLEAVE)
			{
				//查询前面有多少人
				int mbefore = AnyChatCoreSDK.ObjectGetIntValue(AnyChatObjectDefine.ANYCHAT_OBJECT_TYPE_QUEUE, dwObjectId, AnyChatObjectDefine.ANYCHAT_QUEUE_INFO_BEFOREUSERNUM);
				if(mbefore == -1) mbefore = 0;
				showTextView.setText("在您前面还有："+mbefore+"人等待，请您耐心等候...");

			//自己离开
		}else if(dwEventType== AnyChatObjectDefine.ANYCHAT_QUEUE_EVENT_LEAVERESULT){
			if(dwParam1 == 0){
					finish();
			}
			
		}	
	}
	@Override
	public void OnAnyChatVideoCallEvent(int dwEventType, int dwUserId,
			int dwErrorCode, int dwFlags, int dwParam, String userStr) {
		// TODO Auto-generated method stub
		Log.e("queue","queue 有没有被触发");
		switch (dwEventType) {

		case AnyChatDefine.BRAC_VIDEOCALL_EVENT_REQUEST:
			Log.e("queueactivity","接受对方请求回调");
			BussinessCenter.getBussinessCenter().onVideoCallRequest(
					dwUserId, dwFlags, dwParam, userStr);
			if (dialog != null && dialog.isShowing())
				dialog.dismiss();
			dialog = DialogFactory.getDialog(DialogFactory.DIALOGID_REQUEST,
					dwUserId, this);
			dialog.show();
			break;
			
		case AnyChatDefine.BRAC_VIDEOCALL_EVENT_REPLY:
			//呼叫成功的时候的所做出的反应；
			Log.e("queueactivity","呼叫成功等待对方反应的回调");
			BussinessCenter.getBussinessCenter().onVideoCallReply(
					dwUserId, dwErrorCode, dwFlags, dwParam, userStr);
			if (dwErrorCode == AnyChatDefine.BRAC_ERRORCODE_SUCCESS) {
				dialog = DialogFactory.getDialog(
						DialogFactory.DIALOGID_CALLING, dwUserId,
						QueueActivity.this);
				dialog.show();

			} else {
				if (dialog != null && dialog.isShowing()) {
					dialog.dismiss();
				}
			}
			break;
			
		case AnyChatDefine.BRAC_VIDEOCALL_EVENT_START:
			Log.e("queueactivity","会话开始回调");
			if (dialog != null && dialog.isShowing())
				dialog.dismiss();
			BussinessCenter.getBussinessCenter().onVideoCallStart(
					dwUserId, dwFlags, dwParam, userStr);
			break;
		case AnyChatDefine.BRAC_VIDEOCALL_EVENT_FINISH:
			Log.e("queueactivity","会话结束回调");
		/*BussinessCenter.getBussinessCenter().onVideoCallEnd(dwUserId,
					dwFlags, dwParam, userStr);*/
			AnyChatCoreSDK.ObjectControl(AnyChatObjectDefine.ANYCHAT_OBJECT_TYPE_QUEUE,configEntity.CurrentQueueId, AnyChatObjectDefine.ANYCHAT_QUEUE_CTRL_USERLEAVE, 0, 0, 0, 0, "");
			finish();
			break;
		}
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch (v.getId()) {
		case R.id.returnImgBtn://按下返回键
			//leave area event;
			AnyChatCoreSDK.ObjectControl(AnyChatObjectDefine.ANYCHAT_OBJECT_TYPE_QUEUE,configEntity.CurrentQueueId, AnyChatObjectDefine.ANYCHAT_QUEUE_CTRL_USERLEAVE, 0, 0, 0, 0, "");			
			finish();
			break;

		default:
			break;
		}
	}

}