wget https://civitai.com/api/download/models/130072 -O /workspace/models/realisticVisionV51.safetensors;
wget https://civitai.com/api/download/models/132760 -O /workspace/models/absolutereality.safetensors;
wget https://huggingface.co/CiaraRowles/TemporalDiff/resolve/main/temporaldiff-v1-animatediff.ckpt -O /workspace/temporaldiff-v1-animatediff.ckpt

wget https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus-face_sd15.bin -O /workspace/cnmodels/ip-adapter-plus-face_sd15.pth
wget https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.pth -O /workspace/cnmodels/control_v11f1e_sd15_tile.pth
wget https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.yaml -O /workspace/cnmodels/control_v11f1e_sd15_tile.yaml
wget https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/ip-adapter_sd15_plus.pth -O /workspace/cnmodels/ip-adapter_sd15_plus.pth


mkdir 