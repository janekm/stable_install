cd /workspace/
git clone https://github.com/janekm/stable-diffusion.git
cd stable-diffusion
python3 scripts/preload_models.py
cp /weights/sd.ckpt models/ldm/stable-diffusion-v1/model.ckpt