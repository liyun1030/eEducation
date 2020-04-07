package io.agora.education;

import android.app.Application;

import io.agora.base.PreferenceManager;
import io.agora.base.ToastManager;
import io.agora.education.service.bean.response.AppConfigRes;
import io.agora.log.LogManager;

public class EduApplication extends Application {

    public static EduApplication instance;

    public AppConfigRes config;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;

        LogManager.init(this, BuildConfig.EXTRA);
        PreferenceManager.init(this);
        ToastManager.init(this);
    }

}
