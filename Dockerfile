FROM docker:dind
USER root

CMD ["dockerd"]

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME
ENV PREFIX = "c3s"

######### Customize Container Here ###########


EXPOSE 22 443 3000 3128 3306 8000 8500 9443 10443

VOLUME ["/var/run", "/var/lib/docker/volumes", "/portainer_data"]

RUN apk update
RUN apk upgrade

RUN apk add bash nano curl wget sudo
RUN mkdir /opt/rtpi-pen/

#-------------------------------
## Prep the Environment
WORKDIR "/opt"
RUN apk add bash tar curl apt
#RUN touch /opt/rtpi-pen/fresh_rtpi.sh
#RUN sudo curl https://raw.githubusercontent.com/cmndcntrlcyber/auto/refs/heads/main/fresh/fresh-rtpi.sh >> /opt/rtpi-pen/fresh_rtpi.sh
#RUN sudo bash /opt/rtpi-pen/fresh_rtpi.sh
#-------------------------------

#-------------------------------
## Install portainer
WORKDIR "/opt"
RUN apk add bash tar curl
#RUN sudo curl https://raw.githubusercontent.com/cmndcntrlcyber/rtpi-pen/refs/heads/main/portainer/install_portainer.sh > /opt/rtpi-pen/portainer/install_portainer.sh
#RUN sudo bash /opt/rtpi-pen/portainer/install_portainer.sh

CMD ["sudo docker volume create portainer_data"]
RUN sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.0
#-------------------------------

#-------------------------------
## Install Kasm
# Set up environment for Kasm installation
WORKDIR /tmp
# Add necessary tools
RUN apk add bash tar curl

## Automated Install
RUN curl https://raw.githubusercontent.com/cmndcntrlcyber/rtpi-pen/refs/heads/main/kasm/install_kasm.sh > /opt/rtpi-pen/install_kasm.sh
RUN bash /opt/rtpi-pen/install_kasm.sh

#---------------------------------
# Install Google Rapid Response
#WORKDIR "/opt"
#RUN apk add bash tar curl

## Automated Install
#RUN curl https://github.com/cmndcntrlcyber/rtpi-nexus/grr/install_grr.sh > /opt/rtpi-nexus/install_grr.sh
#RUN bash /opt/rtpi-nexus/install_grr.sh
#---------------------------------



######### End Customizations ###########

#RUN chown 1000:0 $HOME
#RUN $STARTUPDIR/set_user_permission.sh $HOME

#ENV HOME /home/kasm-user
#WORKDIR $HOME
#RUN mkdir -p $HOME && chown -R 1000:0 $HOME

#USER 1000
