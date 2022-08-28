cd /workspace/
git clone https://github.com/janekm/stable-diffusion.git sd
cd sd
python3 scripts/preload_models.py
cp /weights/sd.ckpt models/ldm/stable-diffusion-v1/model.ckpt