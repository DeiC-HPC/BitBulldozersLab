from transformers import AutoModelForCausalLM
model = AutoModelForCausalLM.from_pretrained("bert-base-uncased")
model.to('cuda')
