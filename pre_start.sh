# download to runpod pod to path: '/'. Docker command in template:

# bash -c '
# wget https://github.com/thander/runpod-deploy/blob/main/pre_start.sh -O /pre_start.sh;
# /start.sh;
# ';

echo \"**** syncing venv to workspace, please wait. This could take a while on first startup! ****\"
rsync --remove-source-files -rlptDu --ignore-existing /venv/ /workspace/venv/

echo \"**** load models ****\"

echo \"**** syncing stable diffusion to workspace, please wait ****\"
rsync --remove-source-files -rlptDu --ignore-existing /stable-diffusion-webui/ /workspace/stable-diffusion-webui/
ln -s /sd-models/* /workspace/stable-diffusion-webui/models/Stable-diffusion/
ln -s /cn-models/* /workspace/stable-diffusion-webui/extensions/sd-webui-controlnet/models/

echo \"**** load extensions and weights ****\"

if [ ! -f /workspace/stable-diffusion-webui/extensions/sd-webui-animatediff/model/temporaldiff-v1-animatediff.ckpt ]; then
sed -i 's/--xformers/--api/' /workspace/stable-diffusion-webui/webui-user.sh;
git clone https://github.com/continue-revolution/sd-webui-animatediff /workspace/stable-diffusion-webui/extensions/sd-webui-animatediff;
git clone https://github.com/Gourieff/sd-webui-reactor /workspace/stable-diffusion-webui/extensions/sd-webui-reactor;

cd /workspace/stable-diffusion-webui;
source /workspace/venv/bin/activate;
PYTHONPATH=/workspace/stable-diffusion-webui python extensions/sd-webui-reactor/install.py;
mv /sd-models/temporaldiff-v1-animatediff.ckpt /workspace/stable-diffusion-webui/extensions/sd-webui-animatediff/model/;

cd /workspace/stable-diffusion-webui/extensions/sd-webui-controlnet;
git pull;
fi

if [[ $RUNPOD_STOP_AUTO ]]
then
  echo \"Skipping auto-start of webui\"
else
  cd /
  wget https://raw.githubusercontent.com/thander/runpod-deploy/main/handler.py
  wget https://raw.githubusercontent.com/thander/runpod-deploy/main/requirements.txt
  pip install -r requirements.txt
  nohup python -u handler.py >/dev/null 2>&1

  echo \"Started webui through relauncher script\"
  cd /workspace/stable-diffusion-webui
  python relauncher.py &
fi

# wget -q https://civitai.com/api/download/models/130090 -O /sd-models/realisticVisionV51inpaint.safetensors;
# cd /workspace/stable-diffusion-webui;

# source /workspace/venv/bin/activate;
# PYTHONPATH=/workspace/stable-diffusion-webui python extensions/sd-webui-segment-anything/install.py;
# git clone https://github.com/continue-revolution/sd-webui-segment-anything  /workspace/stable-diffusion-webui/extensions/sd-webui-segment-anything;
# mv /workspace/sam_vit_h_4b8939.pth /workspace/stable-diffusion-webui/extensions/sd-webui-segment-anything/models/sam/;
# wget -q https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth;




# ➜  100_ease mkdir -p resized && sips *.HEIC -Z 768 --cropToHeightWidth 512 512 --out resized/*.jpg

# ls -v | cat -n | while read n f; do mv -n "$f" "0$n.png"; done 

# runpodctl create pod --templateId '1iohfg19etx' --imageName runpod/stable-diffusion:web-ui-10.2.1 --volumeSize 75 --containerDiskSize 20 --secureCloud --name ease --gpuType 'NVIDIA RTX A4000' --ports '8888/http,3001/http,22/tcp'


