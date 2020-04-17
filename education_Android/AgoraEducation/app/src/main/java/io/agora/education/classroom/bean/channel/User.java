package io.agora.education.classroom.bean.channel;

import androidx.annotation.IntDef;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.education.classroom.bean.JsonBean;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.education.classroom.mediator.MsgMediator;
import io.agora.rtc.Constants;
import io.agora.sdk.annotation.ClientRole;

public class User extends JsonBean implements Cloneable {

    public String userToken;
    public String userId;
    public String userName;
    @Role
    public int role;
    @Chat
    public int enableChat;
    @Video
    public int enableVideo;
    @Audio
    public int enableAudio;
    public int uid;
    public int screenId;
    public String rtcToken;
    public String rtmToken;
    public String screenToken;
    @Board
    public int grantBoard;
    @CoVideo
    public int coVideo;
    public transient boolean isGenerate; // create by local

    @IntDef({Role.TEACHER, Role.STUDENT})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Role {
        int TEACHER = 1;
        int STUDENT = 2;
    }

    @IntDef({Chat.DISABLE, Chat.ENABLE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Chat {
        int DISABLE = 0;
        int ENABLE = 1;
    }

    @IntDef({Video.DISABLE, Video.ENABLE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Video {
        int DISABLE = 0;
        int ENABLE = 1;
    }

    @IntDef({Audio.DISABLE, Audio.ENABLE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Audio {
        int DISABLE = 0;
        int ENABLE = 1;
    }

    @IntDef({Board.NOT_GRANT, Board.GRANT})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Board {
        int NOT_GRANT = 0;
        int GRANT = 1;
    }

    @IntDef({CoVideo.DISABLE, CoVideo.ENABLE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface CoVideo {
        int DISABLE = 0;
        int ENABLE = 1;
    }

    public User(boolean isGenerate) {
        this.isGenerate = isGenerate;
    }

    public User(int uid, String userName, @ClientRole int role) {
        this.uid = uid;
        this.userName = userName;
        disableVideo(role == Constants.CLIENT_ROLE_AUDIENCE);
        disableAudio(role == Constants.CLIENT_ROLE_AUDIENCE);
        disableChat(true);
        disableBoard(false);
        disableCoVideo(role == Constants.CLIENT_ROLE_AUDIENCE);
        this.isGenerate = true;
    }

    public String getUid() {
        return String.valueOf(uid);
    }

    public boolean isTeacher() {
        return role == Role.TEACHER;
    }

    public boolean isChatEnable() {
        return enableChat == Chat.ENABLE;
    }

    public void disableChat(boolean disable) {
        this.enableChat = disable ? Chat.DISABLE : Chat.ENABLE;
    }

    public boolean isVideoEnable() {
        return enableVideo == Video.ENABLE;
    }

    public void disableVideo(boolean disable) {
        this.enableVideo = disable ? Video.DISABLE : Video.ENABLE;
    }

    public boolean isAudioEnable() {
        return enableAudio == Audio.ENABLE;
    }

    public void disableAudio(boolean disable) {
        this.enableAudio = disable ? Audio.DISABLE : Audio.ENABLE;
    }

    public boolean isBoardGrant() {
        return grantBoard == Board.GRANT;
    }

    public void disableBoard(boolean disable) {
        this.grantBoard = disable ? Board.NOT_GRANT : Board.GRANT;
    }

    public boolean isCoVideoEnable() {
        return coVideo == CoVideo.ENABLE;
    }

    public void disableCoVideo(boolean disable) {
        this.coVideo = disable ? CoVideo.DISABLE : CoVideo.ENABLE;
    }

    @NonNull
    @Override
    public User clone() throws CloneNotSupportedException {
        return (User) super.clone();
    }

    public void sendCoVideoMsg(@PeerMsg.CoVideoMsg.Cmd int cmd, @Nullable User teacher) {
        MsgMediator.sendCoVideoMsg(this, cmd, teacher);
    }

    public void sendUpdateMsg(@ChannelMsg.UpdateMsg.Cmd int cmd) {
        MsgMediator.sendUpdateMsg(this, cmd);
    }

}
