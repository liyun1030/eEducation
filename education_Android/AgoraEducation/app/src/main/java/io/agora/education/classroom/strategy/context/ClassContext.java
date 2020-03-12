package io.agora.education.classroom.strategy.context;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import java.util.Date;
import java.util.List;

import io.agora.base.Callback;
import io.agora.education.classroom.bean.channel.ChannelInfo;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.education.classroom.strategy.ChannelEventListener;
import io.agora.education.classroom.strategy.ChannelStrategy;
import io.agora.sdk.listener.RtcEventListener;
import io.agora.sdk.manager.RtcManager;

import static io.agora.education.classroom.bean.msg.ChannelMsg.UpdateMsg.Cmd.MUTE_AUDIO;
import static io.agora.education.classroom.bean.msg.ChannelMsg.UpdateMsg.Cmd.MUTE_CHAT;
import static io.agora.education.classroom.bean.msg.ChannelMsg.UpdateMsg.Cmd.MUTE_VIDEO;
import static io.agora.education.classroom.bean.msg.ChannelMsg.UpdateMsg.Cmd.UNMUTE_AUDIO;
import static io.agora.education.classroom.bean.msg.ChannelMsg.UpdateMsg.Cmd.UNMUTE_CAHT;
import static io.agora.education.classroom.bean.msg.ChannelMsg.UpdateMsg.Cmd.UNMUTE_VIDEO;

public abstract class ClassContext implements ChannelEventListener {

    private Context context;

    ChannelStrategy channelStrategy;
    ClassEventListener classEventListener;

    ClassContext(Context context, ChannelStrategy strategy) {
        this.context = context;
        channelStrategy = strategy;
        channelStrategy.setChannelEventListener(this);
        RtcManager.instance().registerListener(rtcEventListener);
    }

    public void setClassEventListener(ClassEventListener listener) {
        classEventListener = listener;
    }

    public abstract void checkChannelEnterable(@NonNull Callback<Boolean> callback);

    public void joinChannel() {
        preConfig();
        channelStrategy.joinChannel();
    }

    public void leaveChannel() {
        channelStrategy.leaveChannel();
    }

    abstract void preConfig();

    public void muteLocalAudio(boolean isMute) {
        User local = channelStrategy.getLocal();
        local.disableAudio(isMute);
        channelStrategy.updateLocalAttribute(local, new Callback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                RtcManager.instance().muteLocalAudioStream(isMute);
                channelStrategy.getLocal().sendUpdateMsg(isMute ? MUTE_AUDIO : UNMUTE_AUDIO);
            }

            @Override
            public void onFailure(Throwable throwable) {
            }
        });
    }

    public void muteLocalVideo(boolean isMute) {
        User local = channelStrategy.getLocal();
        local.disableVideo(isMute);
        channelStrategy.updateLocalAttribute(local, new Callback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                RtcManager.instance().muteLocalVideoStream(isMute);
                channelStrategy.getLocal().sendUpdateMsg(isMute ? MUTE_VIDEO : UNMUTE_VIDEO);
            }

            @Override
            public void onFailure(Throwable throwable) {
            }
        });
    }

    public void muteLocalChat(boolean isMute) {
        User local = channelStrategy.getLocal();
        local.disableChat(isMute);
        channelStrategy.updateLocalAttribute(local, new Callback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                channelStrategy.getLocal().sendUpdateMsg(isMute ? MUTE_CHAT : UNMUTE_CAHT);
            }

            @Override
            public void onFailure(Throwable throwable) {
            }
        });
    }

    public void release() {
        channelStrategy.clearLocalAttribute(null);
        channelStrategy.release();
        RtcManager.instance().unregisterListener(rtcEventListener);
        leaveChannel();
    }

    void runListener(Runnable runnable) {
        if (classEventListener != null) {
            if (context instanceof Activity) {
                ((Activity) context).runOnUiThread(runnable);
            }
        }
    }

    @Override
    public void onChannelInfoInit() {
        runListener(() -> classEventListener.onTeacherInit(channelStrategy.getTeacher()));
    }

    @Override
    public void onRoomChanged(Room room) {
        runListener(() -> {
            classEventListener.onClassStateChanged(room.isCourseBegin(), new Date().getTime() - room.startTime);
            classEventListener.onWhiteboardChanged(room.boardId, room.boardToken);
            classEventListener.onLockWhiteboard(room.isBoardLock());
            classEventListener.onMuteAllChat(!room.isChatEnable());
        });
    }

    @Override
    public void onTeacherChanged(User teacher) {
    }

    @Override
    public void onLocalChanged(User local) {
        runListener(() -> classEventListener.onMuteLocalChat(!local.isChatEnable()));
    }

    @Override
    public void onStudentsChanged(List<User> students) {
    }

    @Override
    @SuppressLint("SwitchIntDef")
    public void onChannelMsgReceived(ChannelMsg msg) {
        switch (msg.type) {
            case ChannelMsg.Type.CHAT:
                ChannelMsg.ChatMsg chatMsg = msg.getMsg(ChannelMsg.ChatMsg.class);
                runListener(() -> classEventListener.onChatMsgReceived(chatMsg));
                break;
            case ChannelMsg.Type.REPLAY:
                ChannelMsg.ReplayMsg replayMsg = msg.getMsg(ChannelMsg.ReplayMsg.class);
                runListener(() -> classEventListener.onChatMsgReceived(replayMsg));
                break;
            case ChannelMsg.Type.UPDATE:
            case ChannelMsg.Type.COURSE:
                channelStrategy.queryChannelInfo(null);
                break;
        }
    }

    @Override
    public void onPeerMsgReceived(PeerMsg msg) {
    }

    @Override
    public void onMemberCountUpdated(int count) {
    }

    private RtcEventListener rtcEventListener = new RtcEventListener() {
        @Override
        public void onNetworkQuality(int uid, int txQuality, int rxQuality) {
            if (uid == 0) {
                runListener(() -> classEventListener.onNetworkQualityChanged(Math.max(txQuality, rxQuality)));
            }
        }

        @Override
        public void onUserJoined(int uid, int elapsed) {
            if (uid == ChannelInfo.SHARE_UID) {
                runListener(() -> classEventListener.onScreenShareJoined(uid));
            }
        }

        @Override
        public void onUserOffline(int uid, int reason) {
            if (uid == ChannelInfo.SHARE_UID) {
                runListener(() -> classEventListener.onScreenShareOffline(uid));
            }
        }
    };

}
