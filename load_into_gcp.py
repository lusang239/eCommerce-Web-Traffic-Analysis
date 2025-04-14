# pip3 install google-cloud-storage

import os
from google.cloud.storage import Client, transfer_manager

CREDENTIALS_FILE = "./gcp.json"

def upload_blobs(bucket_name, filenames, source_directory="", workers=8):
    storage_client = Client.from_service_account_json(CREDENTIALS_FILE)
    bucket = storage_client.bucket(bucket_name)

    results = transfer_manager.upload_many_from_filenames(
        bucket, filenames, source_directory=source_directory, max_workers=workers
    )
    
    for name, result in zip(filenames, results):
        if isinstance(result, Exception):
            print("Failed to upload {} due to exception: {}".format(name, result))
        else:
            print("Uploaded {} to {}.".format(name, bucket.name))


if __name__ == '__main__':
    bucket_name = "ecom-web-traffic-data01"
    source_directory = os.path.join(os.getcwd(), "maven-fuzzy-factory-dataset")
    files = [f for f in os.listdir(source_directory) if f != '.DS_Store']
    filenames = list(filter(lambda x: x.endswith('.csv'), files))
    print(upload_blobs(bucket_name, filenames, source_directory))