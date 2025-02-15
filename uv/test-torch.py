# See https://github.com/ROCm/ROCm/issues/2536
import torch
print("===== Torch =====")
print("Torch CUDA availability:",torch.cuda.is_available())
print("Version CUDA:",torch.version.cuda)
print("CUDA device count:",torch.cuda.device_count())
print("version:",torch.__version__)
print("CUDA current device:",torch.cuda.current_device())
print("Device Name:",torch.cuda.get_device_name(torch.cuda.current_device()))
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("Device:",device)
print("Random Table To:")
print(torch.rand(2, 5).to(device))
