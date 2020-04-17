package io.agora.education.classroom.strategy.context;

import android.annotation.SuppressLint;
import android.content.Context;

import androidx.annotation.NonNull;

import java.util.List;

import io.agora.base.Callback;
import io.agora.base.ToastManager;
import io.agora.education.R;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.education.classroom.strategy.ChannelStrategy;
import io.agora.rtc.Constants;
import io.agora.sdk.manager.RtcManager;

import static io.agora.education.classroom.bean.msg.ChannelMsg.UpdateMsg.Cmd.ACCEPT_CO_VIDEO;
import static io.agora.education.classroom.bean.msg.ChannelMsg.UpdateMsg.Cmd.CANCEL_CO_VIDEO;
import static io.agora.education.classroom.bean.msg.PeerMsg.CoVideoMsg.Cmd.APPLY_CO_VIDEO;
import static io.agora.education.classroom.bean.msg.PeerMsg.CoVideoMsg.Cmd.REJECT_CO_VIDEO;

public class LargeClassContext extends ClassContext {

    LargeClassContext(Context context, ChannelStrategy strategy) {
        super(context, strategy);
    }

    @Override
    public void checkChannelEnterable(@NonNull Callback<Boolean> callback) {
        callback.onSuccess(true);
    }

    @Override
    void preConfig() {
        RtcManager.instance().setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
        RtcManager.instance().setClientRole(Constants.CLIENT_ROLE_AUDIENCE);
        RtcManager.instance().enableDualStreamMode(false);
    }

    @Override
    public void onTeacherChanged(User teacher) {
        super.onTeacherChanged(teacher);
        if (classEventListener instanceof LargeClassEventListener) {
            runListener(() -> ((LargeClassEventListener) classEventListener).onTeacherMediaChanged(teacher));
        }
    }

    @Override
    public void onLocalChanged(User local) {
        super.onLocalChanged(local);
        if (local.isGenerate) return;
        onLinkMediaChanged();
    }

    @Override
    public void onStudentsChanged(List<User> students) {
        super.onStudentsChanged(students);
        onLinkMediaChanged();
    }

    private void onLinkMediaChanged() {
        User linkUser = null;
        for (Object object : channelStrategy.getAllStudents()) {
            if (object instanceof User) {
                User user = (User) object;
                if (user.isCoVideoEnable()) {
                    linkUser = user;
                    break;
                }
            }
        }
        if (classEventListener instanceof LargeClassEventListener) {
            User finalLinkUser = linkUser;
            runListener(() -> ((LargeClassEventListener) classEventListener).onLinkMediaChanged(finalLinkUser));
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
                    case ACCEPT_CO_VIDEO:
                        accept();
                        break;
                    case CANCEL_CO_VIDEO:
                        cancel(true);
                        break;
                }
            }
        }
    }

    @Override
    public void onPeerMsgReceived(PeerMsg msg) {
        super.onPeerMsgReceived(msg);
        if (msg.type == PeerMsg.Type.CO_VIDEO) {
            PeerMsg.CoVideoMsg coVideoMsg = msg.getMsg(PeerMsg.CoVideoMsg.class);
            if (coVideoMsg.cmd == REJECT_CO_VIDEO) {
                reject();
            }
        }
    }

    @Override
    public void onMemberCountUpdated(int count) {
        super.onMemberCountUpdated(count);
        if (classEventListener instanceof LargeClassEventListener) {
            runListener(() -> ((LargeClassEventListener) classEventListener).onUserCountChanged(count));
        }
    }

    public void apply() {
        channelStrategy.getLocal().sendCoVideoMsg(APPLY_CO_VIDEO, channelStrategy.getTeacher());
    }

    public void cancel(boolean isRemote) {
        channelStrategy.clearLocalAttribute(new Callback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                RtcManager.instance().setClientRole(Constants.CLIENT_ROLE_AUDIENCE);
                if (isRemote) {
                    if (classEventListener instanceof LargeClassEventListener) {
                        runListener(() -> ((LargeClassEventListener) classEventListener).onHandUpCanceled());
                    }
                } else {
                    channelStrategy.getLocal().sendUpdateMsg(CANCEL_CO_VIDEO);
                }
                channelStrategy.queryChannelInfo(null);
            }

            @Override
            public void onFailure(Throwable throwable) {
            }
        });
    }

    private void accept() {
        User local = channelStrategy.getLocal();
        local.disableCoVideo(false);
        local.disableAudio(false);
        local.disableVideo(false);
        channelStrategy.updateLocalAttribute(local, new Callback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                RtcManager.instance().setClientRole(Constants.CLIENT_ROLE_BROADCASTER);
                ToastManager.showShort(R.string.accept_interactive);
            }

            @Override
            public void onFailure(Throwable throwable) {
            }
        });
    }

    private void reject() {
        channelStrategy.clearLocalAttribute(new Callback<Void>() {
            @Override
            public void onSuccess(Void res) {
                ToastManager.showShort(R.string.reject_interactive);
            }

            @Override
            public void onFailure(Throwable throwable) {
            }
        });
    }

    public interface LargeClassEventListener extends ClassEventListener {
        void onUserCountChanged(int count);

        void onTeacherMediaChanged(User user);

        void onLinkMediaChanged(User user);

        void onHandUpCanceled();
    }

}
