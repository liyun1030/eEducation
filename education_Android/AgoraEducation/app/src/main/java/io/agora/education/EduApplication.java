package io.agora.education;

import android.app.Application;

import io.agora.base.LogManager;
import io.agora.base.PreferenceManager;
import io.agora.base.ToastManager;
import io.agora.education.service.bean.response.AppConfigRes;

public class EduApplication extends Application {

    public static EduApplication instance;

    public AppConfigRes config;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;

        PreferenceManager.init(this);
        ToastManager.init(this);
        LogManager.setTagPre("education_");
    }

}
