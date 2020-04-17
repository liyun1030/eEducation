package io.agora.education.classroom.bean.channel;

import java.util.ArrayList;
import java.util.List;

import io.agora.education.classroom.bean.JsonBean;

public class ChannelInfo extends JsonBean {

    public volatile Room room;
    public volatile User local;
    public volatile User teacher;
    public volatile List<User> students;

    public ChannelInfo(User local) {
        this.local = local;
        this.students = new ArrayList<>();
    }

}
