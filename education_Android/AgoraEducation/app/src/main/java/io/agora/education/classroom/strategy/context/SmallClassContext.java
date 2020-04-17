package io.agora.education.classroom.strategy.context;

import android.annotation.SuppressLint;
import android.content.Context;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

import io.agora.base.Callback;
import io.agora.base.ToastManager;
import io.agora.education.R;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.strategy.ChannelStrategy;
import io.agora.rtc.Constants;
import io.agora.sdk.manager.RtcManager;

import static io.agora.education.classroom.bean.msg.ChannelMsg.UpdateMsg.Cmd.ACCEPT_CO_VIDEO;
import static io.agora.education.classroom.bean.msg.ChannelMsg.UpdateMsg.Cmd.MUTE_BOARD;
import static io.agora.education.classroom.bean.msg.ChannelMsg.UpdateMsg.Cmd.UNMUTE_BOARD;

public class SmallClassContext extends ClassContext {

    private final static int MAX_STUDENT_NUM = 16;

    SmallClassContext(Context context, ChannelStrategy strategy) {
        super(context, strategy);
    }

    @Override
    public void checkChannelEnterable(@NonNull Callback<Boolean> callback) {
        channelStrategy.queryChannelInfo(new Callback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                channelStrategy.queryOnlineStudentNum(new Callback<Integer>() {
                    @Override
                    public void onSuccess(Integer integer) {
                        callback.onSuccess(integer < MAX_STUDENT_NUM);
                    }

                    @Override
                    public void onFailure(Throwable throwable) {
                        callback.onFailure(throwable);
                    }
                });
            }

            @Override
            public void onFailure(Throwable throwable) {
                callback.onFailure(throwable);
            }
        });
    }

    @Override
    void preConfig() {
        RtcManager.instance().setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
        RtcManager.instance().setClientRole(Constants.CLIENT_ROLE_BROADCASTER);
        // enable dual stream mode in small class
        RtcManager.instance().enableDualStreamMode(true);
        RtcManager.instance().setRemoteDefaultVideoStreamType(Constants.VIDEO_STREAM_LOW);
    }

    @Override
    public void onChannelInfoInit() {
        super.onChannelInfoInit();
        if (channelStrategy.getLocal().isGenerate) {
            channelStrategy.updateLocalAttribute(channelStrategy.getLocal(), new Callback<Void>() {
                @Override
                public void onSuccess(Void res) {
                    channelStrategy.getLocal().sendUpdateMsg(ACCEPT_CO_VIDEO);
                }

                @Override
                public void onFailure(Throwable throwable) {
                }
            });
        } else {
            channelStrategy.getLocal().sendUpdateMsg(ACCEPT_CO_VIDEO);
        }
    }

    @Override
    public void onTeacherChanged(User teacher) {
        super.onTeacherChanged(teacher);
        // teacher need set high stream type
        RtcManager.instance().setRemoteVideoStreamType(teacher.uid, Constants.VIDEO_STREAM_HIGH);
        onUsersMediaChanged();
    }

    @Override
    public void onLocalChanged(User local) {
        super.onLocalChanged(local);
        onUsersMediaChanged();
        if (classEventListener instanceof SmallClassEventListener) {
            runListener(() -> ((SmallClassEventListener) classEventListener).onGrantWhiteboard(local.isBoardGrant()));
        }
    }

    @Override
    public void onStudentsChanged(List<User> students) {
        super.onStudentsChanged(students);
        onUsersMediaChanged();
    }

    private void onUsersMediaChanged() {
        if (classEventListener instanceof SmallClassEventListener) {
            List<User> users = new ArrayList<>();
            for (Object object : channelStrategy.getAllUsers()) {
                if (object instanceof User) {
                    users.add((User) object);
                }
            }
            runListener(() -> ((SmallClassEventListener) classEventListener).onUsersMediaChanged(users));
        }
    }

    @Override
    @SuppressLint("SwitchIntDef")
    public void onChannelMsgReceived(ChannelMsg msg) {
        super.onChannelMsgReceived(msg);
        if (msg.type == ChannelMsg.Type.UPDATE) {
            ChannelMsg.UpdateMsg updateMsg = msg.getMsg(ChannelMsg.UpdateMsg.class);
            if (updateMsg.uid == channelStrategy.getLocal().uid) {
                switch (updateMsg.cmd) {
                    case MUTE_BOARD:
                        muteBoard(true);
                        break;
                    case UNMUTE_BOARD:
                        muteBoard(false);
                        break;
                }
            }
        }
    }

    private void muteBoard(boolean muted) {
        User local = channelStrategy.getLocal();
        local.disableBoard(muted);
        channelStrategy.updateLocalAttribute(local, new Callback<Void>() {
            @Override
            public void onSuccess(Void res) {
                ToastManager.showShort(muted ? R.string.revoke_board : R.string.authorize_board);
            }

            @Override
            public void onFailure(Throwable throwable) {
            }
        });
    }

    public interface SmallClassEventListener extends ClassEventListener {
        void onUsersMediaChanged(List<User> users);

        void onGrantWhiteboard(boolean granted);
    }

}
