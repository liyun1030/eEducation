package io.agora.education.classroom.bean.msg;

import androidx.annotation.IntDef;
import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.annotations.SerializedName;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.education.classroom.bean.JsonBean;

public class PeerMsg extends JsonBean {

    @Type
    @SerializedName("cmd")
    public int type;
    public JsonObject data;

    public PeerMsg(@NonNull SubMsg data) {
        this.type = data.type;
        this.data = new JsonParser().parse(data.toJsonString()).getAsJsonObject();
    }

    @IntDef({Type.CO_VIDEO})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Type {
        int CO_VIDEO = 1; // co-video msg
    }

    public static abstract class SubMsg extends JsonBean {
        @Type
        public transient int type;

        public PeerMsg superMsg() {
            return new PeerMsg(this);
        }
    }

    public static class CoVideoMsg extends SubMsg {
        @Cmd
        @SerializedName("operate")
        public int cmd;
        public String userId;
        public String account;

        @IntDef({Cmd.APPLY_CO_VIDEO, Cmd.REJECT_CO_VIDEO})
        @Retention(RetentionPolicy.SOURCE)
        public @interface Cmd {
            int APPLY_CO_VIDEO = 105;
            int REJECT_CO_VIDEO = 107;
        }

        public CoVideoMsg(@Cmd int cmd, String userId, String account) {
            this.type = Type.CO_VIDEO;
            this.cmd = cmd;
            this.userId = userId;
            this.account = account;
        }
    }

    public <T extends SubMsg> T getMsg(Class<T> tClass) {
        return new Gson().fromJson(data.toString(), tClass);
    }

}
