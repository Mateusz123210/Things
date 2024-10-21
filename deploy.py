import os
os.system("docker build . -t backend1")
os.system("docker tag backend1 things2024register.azurecr.io/backend1:latest")
os.system("docker push things2024register.azurecr.io/backend1:latest")