from pymongo import MongoClient

uri = "mongodb+srv://thingscluster.p54ki.mongodb.net/?authSource=%24external&authMechanism=MONGODB-X509&retryWrites=true&w=majority&appName=ThingsCluster"
client = MongoClient(uri,
                     tls=True,
                     tlsCertificateKeyFile='./app/certs/X509-cert-5478772054806384911.pem')

try:
    client.ThingsAddmin.command("ping")
except Exception as e:
    print(e)

db = client.things
collection_categories = db["categories"]
collection_products = db["products"]
collection_notes = db["notes"]