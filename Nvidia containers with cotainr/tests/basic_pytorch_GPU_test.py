import torch
print(torch.cuda.is_available())
print(torch.cuda.device_count())
if torch.cuda.is_available():
    x = torch.zeros(3, 3)
    x = x.to('cuda')
    print(x)