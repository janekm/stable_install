FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-devel

RUN  apt-get update -y && \
     apt-get -y autoremove && \
     apt-get -y install unzip git curl && \
     apt-get clean
     
WORKDIR /root
RUN pip install pyre-extensions==0.0.23
RUN pip install triton==2.0.0.dev20221120
RUN pip install --pre -U xformers

RUN git clone https://github.com/janekm/stable-diffusion-webui.git
WORKDIR /root/stable-diffusion-webui/extensions
RUN git clone https://github.com/janekm/stable-diffusion-webui-images-browser.git
WORKDIR /root/stable-diffusion-webui
RUN mkdir repositories
WORKDIR /root/stable-diffusion-webui
RUN pip install -r requirements.txt
     
WORKDIR /root
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /root/awscliv2.zip
RUN curl "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz" -o /root/ngrok-v3-stable-linux-amd64.tgz
RUN unzip awscliv2.zip
RUN ./aws/install
RUN tar xfvz ngrok-v3-stable-linux-amd64.tgz
WORKDIR /root/stable-diffusion-webui/repositories
RUN git clone https://github.com/Stability-AI/stablediffusion.git stable-diffusion-stability-ai && \
git clone https://github.com/CompVis/taming-transformers.git && \
git clone https://github.com/crowsonkb/k-diffusion.git && \
git clone https://github.com/sczhou/CodeFormer.git && \
git clone https://github.com/salesforce/BLIP.git
WORKDIR /root/

