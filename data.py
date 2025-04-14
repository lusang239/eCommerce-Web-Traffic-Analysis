import kagglehub

# Download latest version
path = kagglehub.dataset_download("rubenman/maven-fuzzy-factory-dataset")

print("Path to dataset files:", path)
