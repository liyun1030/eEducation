package io.agora.education.util;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.text.TextUtils;

import androidx.fragment.app.FragmentActivity;

import io.agora.base.Callback;
import io.agora.base.ToastManager;
import io.agora.education.BuildConfig;
import io.agora.education.EduApplication;
import io.agora.education.R;
import io.agora.education.widget.ConfirmDialog;
import io.agora.log.LogManager;
import io.agora.log.UploadManager;

public class LogUtil {

    public static void upload(FragmentActivity context) {
        UploadManager.upload(context, new UploadManager.UploadParam() {{
            host = BuildConfig.API_BASE_URL;
            if (TextUtils.isEmpty(EduApplication.getAppId())) {
                appId = "default";
            } else {
                appId = EduApplication.getAppId();
            }
            appCode = BuildConfig.CODE;
            appVersion = BuildConfig.VERSION_NAME;
            uploadPath = LogManager.path.getAbsolutePath();
        }}, new Callback<String>() {
            @Override
            public void onSuccess(String res) {
                ConfirmDialog.single(context.getString(R.string.upload_success) + "\n" + res, confirm -> {
                    if (confirm) {
                        ClipboardManager manager = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
                        if (manager != null) {
                            manager.setPrimaryClip(ClipData.newPlainText("LogNumber", res));
                            ToastManager.showShort(context.getString(R.string.clipboard));
                        }
                    }
                }).show(context.getSupportFragmentManager(), null);
            }

            @Override
            public void onFailure(Throwable throwable) {
                ToastManager.showShort(throwable.getMessage());
            }
        });
    }

}
