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

export PYTHON_PATH=.
pip install boto3

cd /workspace/
git clone https://github.com/janekm/stable-diffusion.git sd
cd sd
python3 scripts/preload_models.py
mkdir models/ldm/stable-diffusion-v1/
cp /weights/sd.ckpt models/ldm/stable-diffusion-v1/model.ckpt

sleep infinity