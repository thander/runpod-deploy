# insert to template (docker command)

bash -c "echo '
echo \"**** syncing venv to workspace, please wait. This could take a while on first startup! ****\"
rsync --remove-source-files -rlptDu --ignore-existing /venv/ /workspace/venv/

echo \"**** load models ****\"

wget -q https://civitai.com/api/download/models/130072 -O /sd-models/realisticVisionV51.safetensors;
wget -q https://civitai.com/api/download/models/132760 -O /sd-models/absolutereality.safetensors;

wget -q https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.pth -O /cn-models/control_v11f1e_sd15_tile.pth
wget -q https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.yaml -O /cn-models/control_v11f1e_sd15_tile.yaml
echo \"**** syncing stable diffusion to workspace, please wait ****\"
rsync --remove-source-files -rlptDu --ignore-existing /stable-diffusion-webui/ /workspace/stable-diffusion-webui/
ln -s /sd-models/* /workspace/stable-diffusion-webui/models/Stable-diffusion/
ln -s /cn-models/* /workspace/stable-diffusion-webui/extensions/sd-webui-controlnet/models/

echo \"**** load extensions and weights ****\"

sed -i 's/--xformers//' /workspace/stable-diffusion-webui/webui-user.sh;
git clone https://github.com/continue-revolution/sd-webui-animatediff /workspace/stable-diffusion-webui/extensions/sd-webui-animatediff;
wget https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt https://huggingface.co/CiaraRowles/TemporalDiff/resolve/main/temporaldiff-v1-animatediff.ckpt;
mv /workspace/mm_sd_v15_v2.ckpt /workspace/stable-diffusion-webui/extensions/sd-webui-animatediff/model/;
mv /workspace/temporaldiff-v1-animatediff.ckpt /workspace/stable-diffusion-webui/extensions/sd-webui-animatediff/model/;

cd /workspace/stable-diffusion-webui/extensions/sd-webui-controlnet;
git pull;

if [[ $RUNPOD_STOP_AUTO ]]
then
    echo \"Skipping auto-start of webui\"
else
    echo \"Started webui through relauncher script\"
    cd /workspace/stable-diffusion-webui
    python relauncher.py &
fi
' > /pre_start.sh;
/start.sh;"

# wget -q https://civitai.com/api/download/models/130090 -O /sd-models/realisticVisionV51inpaint.safetensors;
# cd /workspace/stable-diffusion-webui;

# source /workspace/venv/bin/activate;
# PYTHONPATH=/workspace/stable-diffusion-webui python extensions/sd-webui-segment-anything/install.py;
# git clone https://github.com/continue-revolution/sd-webui-segment-anything  /workspace/stable-diffusion-webui/extensions/sd-webui-segment-anything;
# mv /workspace/sam_vit_h_4b8939.pth /workspace/stable-diffusion-webui/extensions/sd-webui-segment-anything/models/sam/;
# wget -q https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth;



# Negative: (deformed iris, deformed pupils, semi-realistic, cgi, 3d, render, sketch, cartoon, drawing, anime:1.4), text, close up, cropped, out of frame, worst quality, low quality, jpeg artifacts, ugly, duplicate, morbid, mutilated, extra fingers, mutated hands, poorly drawn hands, poorly drawn face, mutation, deformed, blurry, dehydrated, bad anatomy, bad proportions, extra limbs, cloned face, disfigured, gross proportions, malformed limbs, missing arms, missing legs, extra arms, extra legs, fused fingers, too many fingers, long neck

# ➜  100_ease mkdir -p resized && sips *.HEIC -Z 768 --cropToHeightWidth 512 512 --out resized/*.jpg

# ls -v | cat -n | while read n f; do mv -n "$f" "0$n.png"; done 

# runpodctl create pod --templateId '1iohfg19etx' --imageName runpod/stable-diffusion:web-ui-10.2.1 --volumeSize 75 --containerDiskSize 20 --secureCloud --name ease --gpuType 'NVIDIA RTX A4000' --ports '8888/http,3001/http,22/tcp'
