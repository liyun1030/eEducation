package io.agora.education.classroom.mediator;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.sdk.manager.RtmManager;

public class MsgMediator {

    private static void sendMessageToPeer(@NonNull User user, @NonNull PeerMsg msg) {
        RtmManager.instance().sendMessageToPeer(String.valueOf(user.uid), msg.toJsonString());
    }

    private static void sendMessage(@NonNull ChannelMsg msg) {
        RtmManager.instance().sendMessage(msg.toJsonString());
    }

    public static void sendCoVideoMsg(@NonNull User user, @PeerMsg.CoVideoMsg.Cmd int cmd, @Nullable User teacher) {
        if (teacher == null || !teacher.isTeacher()) return;
        sendMessageToPeer(teacher, new PeerMsg.CoVideoMsg(cmd, user.userId, user.userName).superMsg());
    }

    public static ChannelMsg.ChatMsg sendChatMsg(@NonNull User user, String content) {
        ChannelMsg.ChatMsg msg = new ChannelMsg.ChatMsg(user.userName, content);
        sendMessage(msg.superMsg());
        return msg;
    }

    public static void sendUpdateMsg(@NonNull User user, @ChannelMsg.UpdateMsg.Cmd int cmd) {
        sendMessage(new ChannelMsg.UpdateMsg(cmd, user.userName, user.uid).superMsg());
    }

    public static void sendCourseMsg(@ChannelMsg.CourseMsg.Cmd int cmd) {
        sendMessage(new ChannelMsg.CourseMsg(cmd).superMsg());
    }

}
