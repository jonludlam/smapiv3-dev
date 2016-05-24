FROM                                   xenserver/xenserver-build-env
MAINTAINER                             Jon Ludlam <jonathan.ludlam@citrix.com>
#Heavily based on avsm's 
# Build requirements
RUN yum install -y sudo passwd git
RUN groupadd -g 10020 opam
RUN useradd -d /home/opam -g opam -u 1207 -m -s /bin/bash opam
RUN passwd -l opam
ADD opamsudo /etc/sudoers.d/opam
RUN chmod 440 /etc/sudoers.d/opam
RUN chown root:root /etc/sudoers.d/opam
RUN sed -i.bak 's/^Defaults.*requiretty//g' /etc/sudoers
RUN /usr/local/bin/init-container.sh
RUN git config --global user.email "xen-api@lists.xen.org"
RUN git config --global user.name "XenServer opam"
RUN yum groupinstall -y "Development Tools"
RUN curl -o /etc/yum.repos.d/home:ocaml.repo -OL http://download.opensuse.org/repositories/home:ocaml/CentOS_7/home:ocaml.repo
RUN yum install -y opam
RUN yum install -y ocaml ocaml-camlp4-devel ocaml-ocamldoc
RUN chown -R opam:opam /home/opam
USER opam
ENV HOME /home/opam
ENV OPAMYES 1
WORKDIR /home/opam
USER opam
RUN sudo -u opam git clone git://github.com/ocaml/opam-repository
RUN sudo -u opam opam init -a -y /home/opam/opam-repository
RUN sudo -u opam opam switch 4.02.3
RUN sudo -u opam opam remote add xp git://github.com/xapi-project/opam-repo-dev
RUN sudo -u opam opam install depext
RUN sudo -u opam opam depext ocamlfind camlp4
# PINS
RUN sudo -u opam opam pin add -n xapi-stdext -k git http://github.com/jonludlam/stdext#smapiv3
RUN sudo -u opam opam pin add -n xapi-idl -k git http://github.com/jonludlam/xcp-idl#smapiv3
RUN sudo -u opam opam pin add -n xapi-inventory -k git http://github.com/jonludlam/xcp-inventory#smapiv3
RUN sudo -u opam opam pin add -n nbd -k git http://github.com/jonludlam/nbd#smapiv3-wip
RUN sudo -u opam opam pin add -n xapi-nbd -k git http://github.com/jonludlam/xapi-nbd#smapiv3
RUN sudo -u opam opam update
RUN sudo -u opam opam depext xapi-nbd
RUN sudo -u opam opam install --deps-only nbd
RUN sudo -u opam opam install ppx_sexp_conv mirage-block
RUN sudo -u opam opam install --deps-only xapi-nbd
WORKDIR /home/opam/opam-repository
ONBUILD RUN sudo -u opam sh -c "cd /home/opam/opam-repository && git pull && opam update -u -y"

