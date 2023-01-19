FROM pytorch/pytorch:1.13.0-cuda11.6-cudnn8-runtime
WORKDIR /root
RUN pip install pyre-extensions==0.0.23
RUN pip install triton==2.0.0.dev20221120
RUN pip install -i https://test.pypi.org/simple/ formers==0.0.15.dev376

RUN apt -y install unzip
RUN git clone https://github.com/janekm/stable-diffusion-webui.git
WORKDIR /root/stable-diffusion-webui/extensions
RUN git clone https://github.com/janekm/stable-diffusion-webui-images-browser.git
WORKDIR /root/stable-diffusion-webui
RUN mkdir repositories
WORKDIR /root/stable-diffusion-webui/repositories
RUN git clone https://github.com/Stability-AI/stablediffusion.git
RUN git clone https://github.com/CompVis/taming-transformers.git
RUN git clone https://github.com/crowsonkb/k-diffusion.git
RUN git clone https://github.com/sczhou/CodeFormer.git
RUN git clone https://github.com/salesforce/BLIP.git
WORKDIR /root/stable-diffusion-webui
RUN pip install -r requirements.txt
RUN pip install opencv-python-headless
RUN pip install markupsafe==2.0.1
RUN pip install git+https://github.com/openai/CLIP.git
RUN pip install open-clip-torch

WORKDIR /root
ADD "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" /root/awscliv2.zip
ADD "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz" /root/ngrok-v3-stable-linux-amd64.tgz
RUN unzip awscliv2.zip
RUN ./aws/install
RUN tar xfvz ngrok-v3-stable-linux-amd64.tgz
