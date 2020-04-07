package io.agora.education;

import android.Manifest;
import android.app.DownloadManager;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;

import androidx.annotation.NonNull;

import butterknife.BindView;
import butterknife.OnClick;
import io.agora.base.Callback;
import io.agora.base.ToastManager;
import io.agora.base.network.RetrofitManager;
import io.agora.education.base.BaseActivity;
import io.agora.education.base.BaseCallback;
import io.agora.education.broadcast.DownloadReceiver;
import io.agora.education.classroom.BaseClassActivity;
import io.agora.education.classroom.LargeClassActivity;
import io.agora.education.classroom.OneToOneClassActivity;
import io.agora.education.classroom.SmallClassActivity;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.service.CommonService;
import io.agora.education.service.RoomService;
import io.agora.education.service.bean.request.RoomEntryReq;
import io.agora.education.service.bean.response.AppConfigRes;
import io.agora.education.service.bean.response.RoomEntryRes;
import io.agora.education.util.AppUtil;
import io.agora.education.util.UUIDUtil;
import io.agora.education.widget.ConfirmDialog;
import io.agora.education.widget.PolicyDialog;
import io.agora.sdk.manager.RtcManager;
import io.agora.sdk.manager.RtmManager;

public class MainActivity extends BaseActivity {

    private final int REQUEST_CODE_DOWNLOAD = 100;
    private final int REQUEST_CODE_RTC = 101;

    @BindView(R.id.et_your_name)
    protected EditText et_your_name;
    @BindView(R.id.et_password)
    protected EditText et_password;

    private DownloadReceiver receiver;
    private CommonService commonService;
    private RoomService roomService;
    private String url;
    private boolean isJoining;

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_main;
    }

    @Override
    protected void initData() {
        receiver = new DownloadReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction(DownloadManager.ACTION_DOWNLOAD_COMPLETE);
        filter.setPriority(IntentFilter.SYSTEM_LOW_PRIORITY);
        registerReceiver(receiver, filter);

        commonService = RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, CommonService.class);
        roomService = RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, RoomService.class);
        checkVersion();
        getConfig();
    }

    @Override
    protected void initView() {
        new PolicyDialog().show(getSupportFragmentManager(), null);
        if (BuildConfig.DEBUG) {
            et_your_name.setText("123");
            et_password.setText("2Rn98F");
        }
    }

    @Override
    protected void onDestroy() {
        unregisterReceiver(receiver);
        RtmManager.instance().reset();
        super.onDestroy();
    }

    private void checkVersion() {
        commonService.appVersion(BuildConfig.CODE).enqueue(new BaseCallback<>(data -> {
            if (data != null && data.forcedUpgrade != 0) {
                showAppUpgradeDialog(data.upgradeUrl, data.forcedUpgrade == 2);
            }
        }));
    }

    private void showAppUpgradeDialog(String url, boolean isForce) {
        this.url = url;
        String content = getString(R.string.app_upgrade);
        ConfirmDialog.DialogClickListener listener = confirm -> {
            if (confirm) {
                if (AppUtil.checkAndRequestAppPermission(MainActivity.this, new String[]{
                        Manifest.permission.WRITE_EXTERNAL_STORAGE
                }, REQUEST_CODE_DOWNLOAD)) {
                    receiver.downloadApk(MainActivity.this, url);
                }
            }
        };
        ConfirmDialog dialog;
        if (isForce) {
            dialog = ConfirmDialog.singleWithButton(content, getString(R.string.upgrade), listener);
            dialog.setCancelable(false);
        } else {
            dialog = ConfirmDialog.normalWithButton(content, getString(R.string.later), getString(R.string.upgrade), listener);
        }
        dialog.show(getSupportFragmentManager(), null);
    }

    private void getConfig() {
        commonService.language().enqueue(new BaseCallback<>(data -> {
            if (EduApplication.instance.config == null) {
                EduApplication.instance.config = new AppConfigRes();
            }
            EduApplication.instance.config.multiLanguage = data;
        }));
    }

    private void joinRoom() {
        String yourNameStr = et_your_name.getText().toString();
        if (TextUtils.isEmpty(yourNameStr)) {
            ToastManager.showShort(R.string.your_name_should_not_be_empty);
            return;
        }

        String passwordStr = et_password.getText().toString();
        if (TextUtils.isEmpty(passwordStr)) {
            ToastManager.showShort(R.string.password_should_not_be_empty);
            return;
        }

        if (EduApplication.instance.config == null) {
            ToastManager.showShort(R.string.configuration_load_failed);
            getConfig();
            return;
        }

        roomEntry(yourNameStr, passwordStr);
    }

    private void roomEntry(String yourNameStr, String passwordStr) {
        if (isJoining) return;
        isJoining = true;
        roomService.roomEntry(new RoomEntryReq() {{
            userName = yourNameStr;
            password = passwordStr;
            uuid = UUIDUtil.getUUID();
        }}).enqueue(new BaseCallback<>(data -> {
            RetrofitManager.instance().addHeader("token", data.user.userToken);
            if (!TextUtils.equals(EduApplication.instance.config.appId, data.room.appId)) {
                EduApplication.instance.config.appId = data.room.appId;
                RtcManager.instance().init(getApplicationContext(), data.room.appId);
                RtmManager.instance().init(getApplicationContext(), data.room.appId);
            }
            room(data);
        }, throwable -> isJoining = false));
    }

    private void room(RoomEntryRes data) {
        User user = data.user;
        Room room = data.room;
        RtmManager.instance().login(user.rtmToken, user.uid, new Callback<Void>() {
            @Override
            public void onSuccess(Void res) {
                startActivity(createIntent(room, user));
                isJoining = false;
            }

            @Override
            public void onFailure(Throwable throwable) {
                ToastManager.showShort(throwable.getMessage());
                isJoining = false;
            }
        });
    }

    private Intent createIntent(Room room, User user) {
        Intent intent = new Intent();
        if (room.type == Room.Type.ONE2ONE) {
            intent.setClass(this, OneToOneClassActivity.class);
        } else if (room.type == Room.Type.SMALL) {
            intent.setClass(this, SmallClassActivity.class);
        } else {
            intent.setClass(this, LargeClassActivity.class);
        }
        intent.putExtra(BaseClassActivity.ROOM, room)
                .putExtra(BaseClassActivity.USER, user);
        return intent;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        for (int result : grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                ToastManager.showShort(R.string.no_enough_permissions);
                return;
            }
        }
        switch (requestCode) {
            case REQUEST_CODE_DOWNLOAD:
                receiver.downloadApk(this, url);
                break;
            case REQUEST_CODE_RTC:
                joinRoom();
                break;
        }
    }

    @OnClick({R.id.iv_setting, R.id.btn_join})
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.iv_setting:
                startActivity(new Intent(this, SettingActivity.class));
                break;
            case R.id.btn_join:
                if (AppUtil.checkAndRequestAppPermission(this, new String[]{
                        Manifest.permission.RECORD_AUDIO,
                        Manifest.permission.CAMERA,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE
                }, REQUEST_CODE_RTC)) {
                    joinRoom();
                }
                break;
        }
    }

}
