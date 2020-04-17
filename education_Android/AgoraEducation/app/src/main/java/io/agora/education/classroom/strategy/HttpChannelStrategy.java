package io.agora.education.classroom.strategy;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.agora.base.Callback;
import io.agora.base.network.RetrofitManager;
import io.agora.education.BuildConfig;
import io.agora.education.EduApplication;
import io.agora.education.base.BaseCallback;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.education.service.RoomService;
import io.agora.education.service.bean.request.UserReq;
import io.agora.education.service.bean.response.RoomRes;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmMessage;
import io.agora.sdk.listener.RtmEventListener;
import io.agora.sdk.manager.RtcManager;
import io.agora.sdk.manager.RtmManager;
import io.agora.sdk.manager.SdkManager;

public class HttpChannelStrategy extends ChannelStrategy<RoomRes> {

    private RoomService roomService;

    public HttpChannelStrategy(String channelId, User local) {
        super(channelId, local);
        roomService = RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, RoomService.class);
        RtmManager.instance().registerListener(rtmEventListener);
    }

    @Override
    public void release() {
        super.release();
        RtmManager.instance().unregisterListener(rtmEventListener);
    }

    @Override
    public void joinChannel() {
        roomService.room(EduApplication.getAppId(), getChannelId()).enqueue(new BaseCallback<>(data -> {
            Room room = data.room;
            User user = data.user;
            RtmManager.instance().joinChannel(new HashMap<String, String>() {{
                put(SdkManager.CHANNEL_ID, room.channelName);
            }});
            RtcManager.instance().joinChannel(new HashMap<String, String>() {{
                put(SdkManager.TOKEN, user.rtcToken);
                put(SdkManager.CHANNEL_ID, room.channelName);
                put(SdkManager.USER_ID, user.getUid());
                put(SdkManager.USER_EXTRA, BuildConfig.EXTRA);
            }});
        }));
    }

    @Override
    public void leaveChannel() {
        roomService.roomExit(EduApplication.getAppId(), getChannelId());
        RtmManager.instance().leaveChannel();
        RtcManager.instance().leaveChannel();
    }

    @Override
    public void queryOnlineStudentNum(@NonNull Callback<Integer> callback) {
        callback.onSuccess(0);
    }

    @Override
    public void queryChannelInfo(@Nullable Callback<Void> callback) {
        roomService.room(EduApplication.getAppId(), getChannelId())
                .enqueue(new BaseCallback<>(data -> {
                    parseChannelInfo(data);
                    if (callback != null) {
                        callback.onSuccess(null);
                    }
                }, throwable -> {
                    if (callback != null) {
                        callback.onFailure(throwable);
                    }
                }));
    }

    @Override
    public void parseChannelInfo(RoomRes data) {
        Room room = data.room;
        if (room.coVideoUsers != null) {
            List<User> students = new ArrayList<>();
            for (User user : room.coVideoUsers) {
                if (user.isTeacher()) {
                    setTeacher(user);
                } else if (user.uid != getLocal().uid) {
                    students.add(user);
                }
            }
            setStudents(students);
        }
        room.coVideoUsers = null;
        setRoom(room);
        setLocal(data.user);
    }

    @Override
    public void updateLocalAttribute(User local, @Nullable Callback<Void> callback) {
        roomService.user(EduApplication.getAppId(), getChannelId(), local.userId, new UserReq(local))
                .enqueue(new BaseCallback<>(data -> {
                    if (callback != null) {
                        callback.onSuccess(null);
                    }
                    queryChannelInfo(null);
                }, throwable -> {
                    if (callback != null) {
                        callback.onFailure(throwable);
                    }
                }));
    }

    @Override
    public void clearLocalAttribute(@Nullable Callback<Void> callback) {
        roomService.user(EduApplication.getAppId(), getChannelId(), getLocal().userId, new UserReq(getLocal()) {{
            coVideo = User.CoVideo.DISABLE;
        }}).enqueue(new BaseCallback<>(data -> {
            if (callback != null) {
                callback.onSuccess(null);
            }
        }, throwable -> {
            if (callback != null) {
                callback.onFailure(throwable);
            }
        }));
    }

    private RtmEventListener rtmEventListener = new RtmEventListener() {
        @Override
        public void onJoinChannelSuccess(String channel) {
            queryChannelInfo(new Callback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    if (channelEventListener != null) {
                        channelEventListener.onChannelInfoInit();
                    }
                }

                @Override
                public void onFailure(Throwable throwable) {
                }
            });
        }

        @Override
        public void onMessageReceived(RtmMessage rtmMessage, RtmChannelMember rtmChannelMember) {
            if (channelEventListener != null) {
                ChannelMsg msg = ChannelMsg.fromJson(rtmMessage.getText(), ChannelMsg.class);
                channelEventListener.onChannelMsgReceived(msg);
            }
        }

        @Override
        public void onMessageReceived(RtmMessage rtmMessage, String s) {
            if (channelEventListener != null) {
                PeerMsg msg = PeerMsg.fromJson(rtmMessage.getText(), PeerMsg.class);
                channelEventListener.onPeerMsgReceived(msg);
            }
        }

        @Override
        public void onMemberCountUpdated(int i) {
            if (channelEventListener != null) {
                channelEventListener.onMemberCountUpdated(i);
            }
        }
    };

}
