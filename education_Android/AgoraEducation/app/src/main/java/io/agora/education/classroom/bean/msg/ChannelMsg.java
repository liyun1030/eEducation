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

public class ChannelMsg extends JsonBean {

    @Type
    @SerializedName("cmd")
    public int type;
    public JsonObject data;

    public ChannelMsg(@NonNull SubMsg data) {
        this.type = data.type;
        this.data = new JsonParser().parse(data.toJsonString()).getAsJsonObject();
    }

    @IntDef({Type.CHAT, Type.UPDATE, Type.REPLAY, Type.COURSE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Type {
        int CHAT = 1; // simple chat msg
        int UPDATE = 2; // user attributes updated msg
        int REPLAY = 3; // replay msg
        int COURSE = 4; // course broadcast msg
    }

    public static abstract class SubMsg extends JsonBean {
        @Type
        public transient int type;

        public ChannelMsg superMsg() {
            return new ChannelMsg(this);
        }
    }

    public static class ChatMsg extends SubMsg {
        public String account;
        public String content;
        public transient boolean isMe;

        ChatMsg() {
        }

        public ChatMsg(String account, String content) {
            this.type = Type.CHAT;
            this.account = account;
            this.content = content;
            this.isMe = true;
        }
    }

    public static class UpdateMsg extends SubMsg {
        @Cmd
        @SerializedName("operate")
        public int cmd;
        public String account;
        public int uid;

        @IntDef({
                Cmd.MUTE_AUDIO, Cmd.UNMUTE_AUDIO,
                Cmd.MUTE_VIDEO, Cmd.UNMUTE_VIDEO,
                Cmd.ACCEPT_CO_VIDEO, Cmd.CANCEL_CO_VIDEO,
                Cmd.MUTE_CHAT, Cmd.UNMUTE_CAHT,
                Cmd.MUTE_BOARD, Cmd.UNMUTE_BOARD
        })
        @Retention(RetentionPolicy.SOURCE)
        public @interface Cmd {
            int MUTE_AUDIO = 101;
            int UNMUTE_AUDIO = 102;
            int MUTE_VIDEO = 103;
            int UNMUTE_VIDEO = 104;
            int ACCEPT_CO_VIDEO = 106;
            int CANCEL_CO_VIDEO = 108;
            int MUTE_CHAT = 109;
            int UNMUTE_CAHT = 110;
            int MUTE_BOARD = 200;
            int UNMUTE_BOARD = 201;
        }

        public UpdateMsg(@Cmd int cmd, String account, int uid) {
            this.type = Type.UPDATE;
            this.cmd = cmd;
            this.account = account;
            this.uid = uid;
        }
    }

    public static class ReplayMsg extends ChatMsg {
        public String recordId;

        public ReplayMsg() {
            this.content = "replay recording";
        }

        public ReplayMsg(String account, String recordId) {
            super(account, null);
            this.type = Type.REPLAY;
            this.recordId = recordId;
        }
    }

    public static class CourseMsg extends SubMsg {
        @Cmd
        @SerializedName("operate")
        public int cmd;

        @IntDef({
                Cmd.LOCK_BOARD, Cmd.UNLOCK_BOARD,
                Cmd.START_COURSE, Cmd.END_COURSE,
                Cmd.MUTE_ALL_CHAT, Cmd.UNMUTE_ALL_CHAT
        })
        @Retention(RetentionPolicy.SOURCE)
        public @interface Cmd {
            int LOCK_BOARD = 301;
            int UNLOCK_BOARD = 302;
            int START_COURSE = 401;
            int END_COURSE = 402;
            int MUTE_ALL_CHAT = 501;
            int UNMUTE_ALL_CHAT = 502;
        }

        public CourseMsg(@Cmd int cmd) {
            this.type = Type.COURSE;
            this.cmd = cmd;
        }
    }

    public <T extends SubMsg> T getMsg(Class<T> tClass) {
        return new Gson().fromJson(data.toString(), tClass);
    }

}
