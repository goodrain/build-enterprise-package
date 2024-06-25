FROM ubuntu:23.04

RUN apt-get update && \
    apt-get install -y sudo ansible sshpass net-tools telnet ssh && \
    ansible-galaxy collection install community.general && \
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -q -N "" && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

COPY conf/ansible.cfg /etc/ansible/ansible.cfg
COPY playbooks /opt/rainbond_ansible/playbooks

ENTRYPOINT [ "/usr/sbin/sshd", "-D" ]