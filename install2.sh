#!/bin/bash
echo "Container Started"

source /venv/bin/activate

apt-get -y update
apt-get -y install git git-lcs vim screen wget curl

# cd /workspace/stable-diffusion
# python /workspace/stable-diffusion/scripts/relauncher.py &

if [[ $PUBLIC_KEY ]]
then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
    echo "SSH Service Started"
fi

if [[ $JUPYTER_PASSWORD ]]
then
    ln -sf /examples /workspace
    ln -sf /root/welcome.ipynb /workspace

    cd /
    jupyter lab --allow-root --no-browser --port=8888 --ip=* \
        --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
        --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace
    echo "Jupyter Lab Started"
fi

export PYTHONPATH=.
pip install boto3

cd /workspace/
git clone https://github.com/janekm/stable-diffusion.git sd
cd sd
python3 scripts/preload_models.py
mkdir models/ldm/stable-diffusion-v1/
cp /models/sd.ckpt models/ldm/stable-diffusion-v1/model.ckpt
git clone https://github.com/TencentARC/GFPGAN.git
cd GFPGAN
pip install basicsr

# Install facexlib - https://github.com/xinntao/facexlib
# We use face detection and face restoration helper in the facexlib package
pip install facexlib

pip install -r requirements.txt
python setup.py develop

# If you want to enhance the background (non-face) regions with Real-ESRGAN,
# you also need to install the realesrgan package
pip install realesrgan
wget https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth -P experiments/pretrained_models
cd ../sd/
python scripts/dream.py
runpodctl stop pod $RUNPOD_POD_ID